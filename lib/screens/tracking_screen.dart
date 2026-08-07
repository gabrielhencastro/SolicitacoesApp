import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/drawer.dart';
import '../helpers/theme_extensions.dart';

final _supabase = Supabase.instance.client;

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _future = _supabase
          .from('solicitacoes')
          .select('*')
          .eq('id_usuario', _supabase.auth.currentUser!.id)
          .inFilter('status', ['Em andamento', 'Concluido'])
          .order('criado_em', ascending: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Acompanhamento',
          style: TextStyle(color: context.colors.surfaceBright),
        ),
        iconTheme: IconThemeData(color: context.colors.surfaceBright),
        backgroundColor: context.colors.tertiary,
      ),
      drawer: MyDrawer(telaAtiva: 'Acompanhamento'),
      body: RefreshIndicator(
        color: context.colors.tertiary,
        onRefresh: _loadData,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Suas solicitações',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
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
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          final createdAt = DateTime.parse(item['criado_em']);
                          final createdAtFormatted =
                              "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}";

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              color: context.colors.surfaceBright,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    if (item['photo_uri'][0] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item['photo_uri'][0],
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return SizedBox(
                                              height: 150,
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress
                                                      .expectedTotalBytes !=
                                                      null
                                                      ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const SizedBox(
                                              height: 150,
                                              child: Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
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
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: _isLoading
                                                  ? const CircularProgressIndicator()
                                                  : const Icon(Icons.delete),
                                              onPressed: () async {
                                                if (item['status'] != 'Concluido') {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Confirmar exclusão'),
                                                      content: const Text(
                                                        'Tem certeza que deseja cancelar esta solicitação?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.of(context).pop(false),
                                                          child: const Text('Não'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () => Navigator.of(context).pop(true),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                          ),
                                                          child: const Text('Sim'),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (confirm == true) {
                                                    try {
                                                      setState(() {
                                                        _isLoading = true;
                                                      });
                                                      await _supabase
                                                          .from('solicitacoes')
                                                          .update({'status': 'Cancelado'})
                                                          .eq('id', item['id']);
                                                      setState(() {
                                                        data.removeAt(index);
                                                        _isLoading = false;
                                                      });
                                                    } catch (e) {
                                                      if (!mounted) return;
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Erro $e'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Solicitação já concluída, não é possível excluir',
                                                      ),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
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
      ),
    );
  }
}
