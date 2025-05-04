import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/report_service.dart';
import '../models/report.dart';

class ReportEditScreen extends StatefulWidget {
  final Report? report; // se null, criamos novo
  const ReportEditScreen({super.key, this.report});

  @override
  State<ReportEditScreen> createState() => _ReportEditScreenState();
}

class _ReportEditScreenState extends State<ReportEditScreen> {
  final _titleCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _service = ReportService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      _titleCtrl.text = widget.report!.title;
      _dateCtrl.text = DateFormat('dd/MM/yyyy').format(widget.report!.date);
      _urlCtrl.text = widget.report!.url;
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);

    // Conversão de data de DD/MM/YYYY para DateTime
    final parts = _dateCtrl.text.split('/');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    // Criação do objeto Report
    final rep = Report(
      id: widget.report?.id ?? '', // Se for um novo relatório, o ID será vazio
      title: _titleCtrl.text.trim(),
      date: date,
      url: _urlCtrl.text.trim(),
    );

    // Verifica se é para criar ou atualizar o relatório
    if (widget.report == null) {
      // Quando não existe um relatório, criamos um novo
      await _service.createReport(rep.toMap());
    } else {
      // Quando existe um relatório, atualizamos o existente
      await _service.updateReport(rep.id, rep.toMap());
    }

    setState(() => _loading = false);
    Navigator.pop(context, rep); // Retorna o relatório atualizado/criado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null ? 'Novo Relatório' : 'Editar Relatório'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomInput(label: 'Título', controller: _titleCtrl),
            const SizedBox(height: 12),
            CustomInput(
              label: 'Data (DD/MM/AAAA)',
              controller: _dateCtrl,
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            CustomInput(label: 'URL do Relatório', controller: _urlCtrl),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : CustomButton(label: 'Salvar', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
