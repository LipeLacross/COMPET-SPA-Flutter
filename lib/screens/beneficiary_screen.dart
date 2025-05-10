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
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

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

  List<File> _photos = [];
  String _photosMessage = '';  // Variável para armazenar a mensagem sobre fotos semanais
  List<String> _areaOptions = []; // Lista para armazenar as áreas cobertas
  String? _selectedArea; // Variável para armazenar a área selecionada

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

  // Função para verificar se o usuário tem 3 fotos registradas
  Future<void> _checkPhotos() async {
    if (_photos.length < 3) {
      setState(() {
        _photosMessage = 'Você precisa tirar 3 fotos semanais para registrar a atividade.';
      });
    } else {
      setState(() {
        _photosMessage = ''; // Limpar mensagem quando houver 3 fotos
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
  }

  // Função para salvar a atividade
  Future<void> _saveActivity() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Descrição é obrigatória!')));
      return;
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;

    _currentPos = await _geo.getUserLocation();
    if (_currentPos == null) return;

    File imageFile = File(picked.path);

    // Salvar a foto na raiz do projeto
    final directory = await getApplicationDocumentsDirectory();
    final localPath = '${directory.path}/activity_images/';
    await Directory(localPath).create(recursive: true); // Cria a pasta se não existir
    final newFile = File('$localPath${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageFile.copy(newFile.path);

    // Verificar os metadados EXIF da foto
    try {
      final exif = await Exif.fromPath(newFile.path);
      final gpsLatitude = await exif.getAttribute("GPSLatitude");
      final gpsLongitude = await exif.getAttribute("GPSLongitude");
      print("GPS Latitude: $gpsLatitude, GPS Longitude: $gpsLongitude");
      await exif.close();
    } catch (e) {
      print("Erro ao ler dados EXIF: $e");
    }

    // Adicionar a foto à lista
    _photos.add(imageFile);

    // Verificar se há 3 fotos
    await _checkPhotos();

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
        'imagePath': newFile.path,
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
                CustomButton(label: 'Tirar Foto e Registrar', onPressed: _saveActivity),
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
                        leading: Image.file(File(r.payload['imagePath']), width: 50, fit: BoxFit.cover),
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
