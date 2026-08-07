import 'package:flutter/material.dart';
import 'package:solicitacoes_v1/screens/edit_account_screen.dart';
import 'package:solicitacoes_v1/services/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/drawer.dart';
import '../helpers/theme_extensions.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _supabaseAuth = SupabaseAuth();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sua conta',
          style: TextStyle(color: context.colors.surfaceBright),
        ),
        iconTheme: IconThemeData(color: context.colors.surfaceBright),
        backgroundColor: context.colors.tertiary,
      ),
      drawer: MyDrawer(telaAtiva: 'Minha conta'),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Configurações da conta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: context.colors.surfaceBright,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('Editar conta'),
                leading: const Icon(Icons.edit),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAccountScreen(),
                    ),
                  );
                },
              ),
            ),
            Card(
              color: context.colors.surfaceBright,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('Sair'),
                leading: const Icon(Icons.logout),
                onTap: () async {
                  try {
                    await _supabaseAuth.signOut();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao sair: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
            Card(
              color: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  _loading ? 'Excluindo conta...' : 'Excluir conta',
                  style: const TextStyle(color: Colors.white),
                ),
                leading: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete, color: Colors.white),
                onTap: _loading
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                        });
                        try {
                          await _supabaseAuth.deleteUser(
                            currentUser:
                                Supabase.instance.client.auth.currentUser!,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Conta deletada com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao excluir conta: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _loading = false;
                            });
                          }
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
