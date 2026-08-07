import 'package:flutter/material.dart';
import 'package:solicitacoes_v1/screens/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/network_image_with_loading.dart';
import '../helpers/theme_extensions.dart';

class SolicitationDetailsScreen extends StatefulWidget {
  final String solicitationId;

  const SolicitationDetailsScreen({super.key, required this.solicitationId});

  @override
  State<SolicitationDetailsScreen> createState() =>
      _SolicitationDetailsScreenState();
}

class _SolicitationDetailsScreenState extends State<SolicitationDetailsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isSolicitationCanceling = false;
  bool _isSolicitationConcluding = false;
  String? solicitationType;
  String? description;
  String? cep;
  String? uf;
  String? city;
  String? street;
  String? neighborhood;
  String? number;
  String? complement;
  List<dynamic> photosUri = [];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _updateSolicitationStatus(String status) async {
    await _supabase
        .from('solicitacoes')
        .update({'status': status})
        .eq('id', widget.solicitationId);
  }

  Future<bool> _showConfirmDialog(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('solicitacoes')
          .select('*')
          .eq('id', widget.solicitationId)
          .single();
      setState(() {
        solicitationType = response['tipo_solicitacao'];
        description = response['descricao'];
        cep = response['cep'];
        city = response['cidade'];
        uf = response['uf'];
        neighborhood = response['bairro'];
        street = response['rua'];
        number = response['number'];
        complement = response['complemento'];
        photosUri = response['photo_uri'];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _showImagePopup(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: NetworkImageWithLoading(
                  url: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes da solicitação',
          style: TextStyle(color: context.colors.surfaceBright),
        ),
        iconTheme: IconThemeData(color: context.colors.surfaceBright),
        backgroundColor: context.colors.tertiary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Solicitação: $solicitationType',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (photosUri.isNotEmpty)
                    Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: photosUri.length,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              final photoUrl = photosUri[index];
                              return GestureDetector(
                                onTap: () => _showImagePopup(photoUrl),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                            ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            photosUri.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    const Text('Nenhuma foto disponível'),
                  Text(description ?? ''),
                  Text(
                    '$city - $uf | $neighborhood, $street ${number ?? ''} ${(complement != null && complement != '') ? ' | $complement' : ''}',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 64,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_isSolicitationCanceling != true) {
                    final confirmed = await _showConfirmDialog(
                      context,
                      'Deseja realmente cancelar esta solicitação?',
                    );

                    if (!confirmed) return;

                    try {
                      setState(() {
                        _isSolicitationCanceling = true;
                      });
                      await _updateSolicitationStatus('Cancelado');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Solicitação cancelada!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erro: $e',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      setState(() {
                        _isSolicitationCanceling = false;
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: _isSolicitationCanceling
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        'Cancelar solicitação',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_isSolicitationConcluding != true) {
                    final confirmed = await _showConfirmDialog(
                      context,
                      'Deseja realmente concluir esta solicitação?',
                    );

                    if (!confirmed) return;

                    try {
                      setState(() {
                        _isSolicitationConcluding = true;
                      });
                      await _updateSolicitationStatus('Concluido');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Solicitação concluída!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erro: $e',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      setState(() {
                        _isSolicitationConcluding = false;
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: _isSolicitationConcluding
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        'Concluir solicitação',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
