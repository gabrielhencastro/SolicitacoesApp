import 'package:flutter/material.dart';
import 'package:solicitacoes_v1/helpers/theme_extensions.dart';
import 'package:solicitacoes_v1/screens/signup_screen.dart';
import 'package:solicitacoes_v1/services/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); //

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseAuth = SupabaseAuth();
  bool _keepConnected = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Força o container a ter no mínimo a altura total da tela disponível
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  // Garante a centralização vertical em telas grandes
                  child: Center(
                    child: Container(
                      // Impede que o card estique excessivamente em telas de Tablets ou Web
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceBright,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            spreadRadius: 4,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Image(
                            image: AssetImage('lib/assets/simple_logo.png'),
                            width: 128,
                            alignment: Alignment.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sistema Inteligente de Protocolos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.colors.primary,
                            ),
                          ),
                          const SizedBox(),
                          Text(
                            'Iniciar Sessão',
                            style: TextStyle(
                              fontSize: 18,
                              color: context.colors.secondary,
                            ),
                          ),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                color: context.colors.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: context.colors.secondary.withValues(
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
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Senha',
                              hintStyle: TextStyle(
                                color: context.colors.secondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: context.colors.secondary.withValues(
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
                          SizedBox(height: 16,),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.colors.tertiary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    try {
                                      await _supabaseAuth.loginWithPassword(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      );
                                    } on AuthException catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.message ==
                                                    'Invalid login credentials'
                                                ? 'Credenciais inválidas'
                                                : e.message,
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Erro inesperado: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Entrar',
                                    style: TextStyle(
                                      color: context.colors.surfaceBright,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ainda não tem uma conta?',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.secondary,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.tertiary,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Cadastrar-se',
                              style: TextStyle(
                                color: context.colors.surfaceBright,
                              ),
                            ),
                          ),
                          // Direitos autorais
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.copyright,
                                size: 14,
                                color: context.colors.secondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              Text(
                                ' 2026 Heimdall Solutions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.secondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Gabriel Castro',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.secondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
