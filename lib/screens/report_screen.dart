import 'package:flutter/material.dart';
import 'package:solicitacoes_v1/components/drawer.dart';
import 'package:solicitacoes_v1/services/supabase_functions.dart';
import '../helpers/theme_extensions.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = false;
  String? selectedReportType;
  String? selectedReportStatus;
  String? selectedSolicitationType;

  final List<String> _reportTypeList = ['PDF', 'EXCEL'];
  final List<String> _reportStatusList = ['Em andamento', 'Concluido'];
  List<String> _solicitationTypeList = [];

  @override
  void initState() {
    super.initState();
    _loadSolicitationTypes();
  }

  Future<void> _loadSolicitationTypes() async {
    try {
      final list = await SupabaseFunctions().getSolicitationTypeList();
      setState(() {
        _solicitationTypeList = list;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar tipos: $e')));
    }
  }

  Future<void> _generateReport() async {
    if (selectedReportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo de relatório')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SupabaseFunctions().generateReport(
        reportType: selectedReportType! == 'PDF' ? '2' : '1',
        solicitationType: selectedSolicitationType,
        status: selectedReportStatus,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatórios',
          style: TextStyle(color: context.colors.surfaceBright),
        ),
        iconTheme: IconThemeData(color: context.colors.surfaceBright),
        backgroundColor: context.colors.tertiary,
      ),
      drawer: MyDrawer(telaAtiva: 'Relatórios'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 16,
          children: [
            Text(
              'Filtros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
            DropdownButtonFormField<String>(
              items: _reportTypeList
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedReportType = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tipo de relatório obrigatório';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Tipo de relatório *',
                hintStyle: TextStyle(
                  color: context.colors.primary.withValues(alpha: 0.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.primary.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.colors.primary),
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              items: _solicitationTypeList
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedSolicitationType = value),
              decoration: InputDecoration(
                hintText: 'Tipo de solicitação',
                hintStyle: TextStyle(
                  color: context.colors.primary.withValues(alpha: 0.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.primary.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.colors.primary),
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              items: _reportStatusList
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedReportStatus = value),
              decoration: InputDecoration(
                hintText: 'Status',
                hintStyle: TextStyle(
                  color: context.colors.primary.withValues(alpha: 0.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.primary.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.colors.primary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: context.colors.tertiary,
                ),
                onPressed: _isLoading ? null : _generateReport,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Gerar relatório',
                        style: TextStyle(color: context.colors.surfaceBright),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
