import 'package:flutter/material.dart';
import 'package:solicitacoes_v1/components/drawer.dart';
import 'package:solicitacoes_v1/screens/solicitation_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/theme_extensions.dart';
import '../services/supabase_functions.dart';

final _supabase = Supabase.instance.client;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Map<String, dynamic>>> _future = _supabase
      .from('solicitacoes')
      .select('*')
      .eq('status', 'Em andamento')
      .order('criado_em', ascending: false);

  bool _isFilterLoading = false;
  bool _isStaticsLoading = true;
  String? selectedSolicitationType;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  List<String> _solicitationTypeList = [];
  int? solicitationsInProgress;
  int? solicitationsConcluded;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _loadSolicitationTypes() async {
    try {
      final list = await SupabaseFunctions().getSolicitationTypeList();
      setState(() {
        _solicitationTypeList = list;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar filtros: $e')));
    }
  }

  Future<void> _loadSolicitationStatics() async {
    try {
      final r1 = await _supabase
          .from('solicitacoes')
          .count(CountOption.exact)
          .eq('status', 'Em andamento');
      final r2 = await _supabase
          .from('solicitacoes')
          .count(CountOption.exact)
          .eq('status', 'Concluido');
      setState(() {
        solicitationsInProgress = r1;
        solicitationsConcluded = r2;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar estatísticas: $e')),
      );
    } finally {
      _isStaticsLoading = false;
    }
  }

  void _applyFilters() {
    dynamic query = _supabase.from('solicitacoes').select('*');

    query = query.eq('status', 'Em andamento');

    if (selectedSolicitationType != null) {
      query = query.eq('tipo_solicitacao', selectedSolicitationType);
    }

    if (selectedStartDate != null) {
      query = query.gte('criado_em', selectedStartDate!.toIso8601String());
    }

    if (selectedEndDate != null) {
      query = query.lte('criado_em', selectedEndDate!.toIso8601String());
    }

    setState(() {
      _future = query.order('criado_em', ascending: false);
    });
  }

  @override
  void initState() {
    super.initState();
    _applyFilters();
    _loadSolicitationStatics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(color: context.colors.surfaceBright),
        ),
        actions: [
          IconButton(
            icon: _isFilterLoading
                ? CircularProgressIndicator(
                    color: context.colors.surfaceBright,
                    strokeWidth: 2,
                  )
                : const Icon(Icons.more_vert),
            onPressed: () async {
              setState(() {
                _isFilterLoading = true;
              });
              await _loadSolicitationTypes();
              if (!mounted) return;
              setState(() {
                _isFilterLoading = false;
              });

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      return AlertDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Filtros'),
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  selectedSolicitationType = null;
                                  selectedStartDate = null;
                                  selectedEndDate = null;
                                  _startDateController.clear();
                                  _endDateController.clear();
                                });
                                setState(() {
                                  selectedSolicitationType = null;
                                  selectedStartDate = null;
                                  selectedEndDate = null;
                                  _applyFilters();
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Limpar'),
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: selectedSolicitationType,
                              items: _solicitationTypeList
                                  .map(
                                    (tipo) => DropdownMenuItem(
                                      value: tipo,
                                      child: Text(tipo),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setModalState(
                                  () => selectedSolicitationType = value,
                                );
                                setState(
                                  () => selectedSolicitationType = value,
                                );
                              },
                              decoration: InputDecoration(
                                hintText: 'Tipo de solicitação',
                                hintStyle: TextStyle(
                                  color: context.colors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: context.colors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: context.colors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _startDateController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Data inicial',
                                suffixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      selectedStartDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    selectedStartDate = picked;
                                    _startDateController.text =
                                        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                                  });
                                  setState(() {
                                    selectedStartDate = picked;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _endDateController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Data final',
                                suffixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      selectedEndDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    selectedEndDate = picked;
                                    _endDateController.text =
                                        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                                  });
                                  setState(() {
                                    selectedEndDate = picked;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _applyFilters();
                            },
                            child: const Text('Aplicar'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
        backgroundColor: context.colors.tertiary,
        iconTheme: IconThemeData(color: context.colors.surfaceBright),
      ),
      drawer: MyDrawer(telaAtiva: 'Dashboard'),
      body: Container(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          spacing: 24,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.tertiary,
                    borderRadius: BorderRadiusGeometry.circular(16),
                  ),
                  width: 150,
                  height: 81,
                  padding: EdgeInsets.all(16),
                  child: _isStaticsLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Column(
                          children: [
                            Text(
                              '$solicitationsInProgress',
                              style: TextStyle(
                                color: context.colors.surfaceBright,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Em andamento',
                              style: TextStyle(
                                color: context.colors.surfaceBright,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.tertiary,
                    borderRadius: BorderRadiusGeometry.circular(16),
                  ),
                  width: 150,
                  height: 81,
                  padding: EdgeInsets.all(16),
                  child: _isStaticsLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Column(
                          children: [
                            Text(
                              '$solicitationsConcluded',
                              style: TextStyle(
                                color: context.colors.surfaceBright,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Concluidas',
                              style: TextStyle(
                                color: context.colors.surfaceBright,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            Text(
              'Solicitações em andamento',
              style: TextStyle(
                color: context.colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma solicitação encontrada'),
                    );
                  } else {
                    final data = snapshot.data!;
                    // Listview de cada item
                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 16),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        final createdAt = DateTime.parse(item['criado_em']);
                        final createdAtFormatted =
                            "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}";
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SolicitationDetailsScreen(
                                    solicitationId: item['id'],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: context.colors.surfaceBright,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['tipo_solicitacao'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: context.colors.primary,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          item['status'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: context.colors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${item['cidade']} - ${item['uf']}',
                                          style: TextStyle(
                                            color: context.colors.primary,
                                          ),
                                        ),
                                        Text(
                                          '${item['bairro']}',
                                          style: TextStyle(
                                            color: context.colors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Criado em: $createdAtFormatted',
                                          style: TextStyle(
                                            color: context.colors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
