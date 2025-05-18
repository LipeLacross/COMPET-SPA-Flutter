import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:competspa/components/custom_input.dart';
import 'package:competspa/components/custom_button.dart';
import 'package:competspa/services/geolocation_service.dart';
import 'package:competspa/services/local_storage_service.dart';
import 'package:competspa/services/report_service.dart';
import 'package:competspa/models/offline_record.dart';
import 'package:competspa/models/report.dart';
import 'package:competspa/utils/date_helper.dart';
import 'package:competspa/services/session_manager.dart';
import 'package:competspa/services/notification_service.dart';
import 'package:competspa/services/api_service.dart';
import 'package:path_provider/path_provider.dart';

class BeneficiaryScreen extends StatefulWidget {
  const BeneficiaryScreen({super.key});

  @override
  State<BeneficiaryScreen> createState() => _BeneficiaryScreenState();
}

class _BeneficiaryScreenState extends State<BeneficiaryScreen> with SingleTickerProviderStateMixin {
  final SessionManager _sm = SessionManager();
  final GeolocationService _geo = GeolocationService();
  final LocalStorageService _store = LocalStorageService();
  final ReportService _reportSvc = ReportService();
  final NotificationService _notif = NotificationService();
  final ApiService _api = ApiService();

  TabController? _tabController;

  final _areaTotalController = TextEditingController();
  final _areaAppController = TextEditingController();
  final _descriptionAreaController = TextEditingController();
  final _addressController = TextEditingController();
  final _forestTypeController = TextEditingController();
  final _animalsController = TextEditingController();
  final _humanResourcesController = TextEditingController();
  final _otherResourcesController = TextEditingController();
  final _descController = TextEditingController();

  File? _pickedImage;
  Position? _currentPos;
  List<OfflineRecord> _records = [];
  List<Report> _payments = [];

  final List<File> _photos = [];
  String _photosMessage = '';  // Variável para armazenar a mensagem sobre fotos semanais
  List<String> _areaOptions = []; // Lista para armazenar as áreas cobertas
  String? _selectedArea; // Variável para armazenar a área selecionada
  int _photoCount = 0;
  int _videoCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final role = await _sm.getUserRole();
    if (role != 'beneficiary') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(context: context, barrierDismissible: false, builder: (_) {
          return AlertDialog(
            title: const Text('Acesso Negado'),
            content: const Text('Você não tem autorização para acessar esta área.\nSolicite permissão na tela de Administração.'),
            actions: [TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), child: const Text('OK'))],
          );
        });
      });
    } else {
      await _loadRecords();
      await _loadPayments();
      await _loadAreas(); // Carregar áreas cobertas
      _notif.init();
      setState(() {});
    }
  }

  Future<void> _loadRecords() async {
    _records = await _store.fetchQueue();
    setState(() {});
  }

  Future<void> _loadPayments() async {
    try {
      _payments = await _reportSvc.fetchReports();
      setState(() {});
    } catch (_) {
      print("Erro ao carregar pagamentos");
    }
  }

  Future<void> _loadAreas() async {
    // Carregar áreas cobertas para a lista suspensa (seleção de área)
    final areas = await _store.fetchAreas();  // Agora a função retorna uma lista de Strings
    setState(() {
      _areaOptions = areas;  // Atribui a lista de áreas à variável _areaOptions
    });
  }

  // Função para verificar se o usuário tem 10 fotos e 3 vídeos registrados
  Future<void> _checkMedia() async {
    if (_photoCount < 10) {
      setState(() {
        _photosMessage = 'Você precisa tirar no mínimo 10 fotos e 3 vídeos de 1 minuto cada semana para cada território.';
      });
    } else if (_videoCount < 3) {
      setState(() {
        _photosMessage = 'Você precisa enviar 3 vídeos de no mínimo 1 minuto cada semana para cada território.';
      });
    } else {
      setState(() {
        _photosMessage = ''; // Limpar mensagem quando as exigências forem cumpridas
      });
    }
  }

  // Função para salvar a área coberta
  Future<void> _saveArea() async {
    final total = double.tryParse(_areaTotalController.text);
    final app = double.tryParse(_areaAppController.text);
    final hr = int.tryParse(_humanResourcesController.text);

    if (total == null || app == null || hr == null) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Dados Inválidos'),
          content: const Text('Preencha corretamente:\n- Área Total e Área APP com números válidos\n- Recursos Humanos com número inteiro'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Endereço é obrigatório!')));
      return;
    }

    final beneficiaryId = await _sm.getBeneficiaryId();
    final beneficiaryName = await _sm.getBeneficiaryName();
    final rec = OfflineRecord(
      id: DateTime.now().toIso8601String(),
      beneficiaryId: beneficiaryId ?? 'unknown',
      beneficiaryName: beneficiaryName ?? 'unknown',
      latitude: 0,
      longitude: 0,
      createdAt: DateTime.now(),
      timestamp: DateTime.now(),
      report: 'Área Coberta',
      status: 'Pendente',
      payload: {
        'type': 'area',
        'areaTotal': total,
        'areaApp': app,
        'description': _descriptionAreaController.text,
        'address': _addressController.text,
        'forestType': _forestTypeController.text,
        'animals': _animalsController.text,
        'humanResources': hr,
        'otherResources': _otherResourcesController.text,
        'date': DateHelper.formatDate(DateTime.now()),
        'territory': _selectedArea, // Adiciona a área selecionada
      },
    );

    await _store.saveRecord(rec, XFile(rec.id));

    try {
      if (rec.payload.containsKey('propertyId')) {
        bool validCar = await _api.validateCAR(rec.payload['propertyId']);
        if (!validCar) throw Exception('CAR inválido');
      }
      await _api.post('areas', rec.payload..addAll({'id': rec.id}));
      await _store.deleteRecord(rec.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Área sincronizada com sucesso.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Área salva offline. Erro de sync: $e')));
    }

    _clearAreaInputs();
    await _loadRecords();
  }

  // Função para limpar os campos de área
  void _clearAreaInputs() {
    _areaTotalController.clear();
    _areaAppController.clear();
    _descriptionAreaController.clear();
    _addressController.clear();
    _forestTypeController.clear();
    _animalsController.clear();
    _humanResourcesController.clear();
    _otherResourcesController.clear();
    _selectedArea = null; // Limpar a seleção da área
  }

  // Função para salvar a atividade
  Future<void> _saveActivity(String mediaType) async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Descrição é obrigatória!')));
      return;
    }

    File? mediaFile;
    if (mediaType == 'photo') {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked == null) return;
      mediaFile = File(picked.path);
      _photoCount++;  // Incrementa o contador de fotos
    } else if (mediaType == 'video') {
      final picked = await ImagePicker().pickVideo(source: ImageSource.camera);
      if (picked == null) return;
      mediaFile = File(picked.path);
      _videoCount++;  // Incrementa o contador de vídeos
    }

    if (mediaFile == null) return;

    _currentPos = await _geo.getUserLocation();
    if (_currentPos == null) return;

    // Salvar o arquivo na raiz do projeto
    final directory = await getApplicationDocumentsDirectory();
    final localPath = '${directory.path}/activity_media/';
    await Directory(localPath).create(recursive: true);
    final newFile = File('$localPath${DateTime.now().millisecondsSinceEpoch}.jpg');  // Usar .mp4 para vídeos
    await mediaFile.copy(newFile.path);

    // Criar o registro de atividade
    final rec = OfflineRecord(
      id: DateTime.now().toIso8601String(),
      beneficiaryId: await _sm.getBeneficiaryId() ?? 'unknown',
      beneficiaryName: await _sm.getBeneficiaryName() ?? 'unknown',
      latitude: _currentPos!.latitude,
      longitude: _currentPos!.longitude,
      createdAt: DateTime.now(),
      timestamp: DateTime.now(),
      report: _descController.text,
      status: 'Pendente',
      payload: {
        'type': 'activity',
        'description': _descController.text,
        'mediaPath': newFile.path,
        'mediaType': mediaType,  // Foto ou vídeo
        'date': DateHelper.formatDate(DateTime.now()),
      },
    );

    await _store.saveRecord(rec, XFile(rec.id));

    // Tentando salvar a atividade via API ou offline
    try {
      await _api.postWithFile(
        path: 'activities',
        data: {
          'id': rec.id,
          'report': rec.report,
          'status': rec.status,
          'beneficiaryId': rec.beneficiaryId,
        },
        file: newFile,
        latitude: rec.latitude,
        longitude: rec.longitude,
      );
      await _store.deleteRecord(rec.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atividade enviada com sucesso.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Atividade salva offline. Erro de sync: $e')));
    }

    _descController.clear();
    _pickedImage = null;
    _currentPos = null;
    await _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Beneficiário'),
        bottom: TabBar(
          controller: _tabController!,
          tabs: const [
            Tab(text: 'Área Coberta'),
            Tab(text: 'Atividades'),
            Tab(text: 'Pagamentos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                CustomInput(label: 'Área Total', controller: _areaTotalController),
                CustomInput(label: 'Área APP', controller: _areaAppController),
                CustomInput(label: 'Descrição', controller: _descriptionAreaController),
                CustomInput(label: 'Endereço', controller: _addressController),
                CustomInput(label: 'Tipo de Floresta', controller: _forestTypeController),
                CustomInput(label: 'Animais', controller: _animalsController),
                CustomInput(label: 'Recursos Humanos', controller: _humanResourcesController),
                CustomInput(label: 'Outros Recursos', controller: _otherResourcesController),
                DropdownButton<String>(
                  value: _selectedArea,
                  hint: const Text('Selecione a área'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedArea = newValue;
                    });
                  },
                  items: _areaOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                CustomButton(label: 'Salvar Área', onPressed: _saveArea),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomInput(label: 'Descrição da Atividade *', controller: _descController),
                const SizedBox(height: 12),
                CustomButton(label: 'Tirar Foto', onPressed: () => _saveActivity('photo')),
                const SizedBox(height: 12),
                CustomButton(label: 'Gravar Vídeo', onPressed: () => _saveActivity('video')),
                const SizedBox(height: 20),
                if (_photosMessage.isNotEmpty)
                  Text(
                    _photosMessage,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                Expanded(
                  child: ListView(
                    children: _records
                        .where((r) => r.payload['type'] == 'activity')
                        .map((r) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Image.file(File(r.payload['mediaPath']), width: 50, fit: BoxFit.cover),
                        title: Text(r.payload['description']),
                        subtitle: Text('Em ${r.payload['date']}'),
                        trailing: const Icon(Icons.location_on, color: Colors.green),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _payments.isEmpty
                ? const Center(child: Text('Nenhum pagamento registrado'))
                : ListView(
              children: _payments.map((p) {
                return ListTile(
                  leading: const Icon(Icons.payment_outlined, color: Colors.green),
                  title: Text(p.title),
                  subtitle: Text(DateHelper.formatDate(p.date)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
