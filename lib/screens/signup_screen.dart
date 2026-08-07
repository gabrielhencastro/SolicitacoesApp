import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import '../components/text_input.dart';
import '../helpers/theme_extensions.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solicitacoes_v1/services/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _cepIsValid = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _cepController = TextEditingController();
  final _ufController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabaseAuth = SupabaseAuth();

  // Variável para capturar e printar o erro da data
  String? _erroDataNascimento;

  final _maskcpf = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _maskcep = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _maskdata = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _cepController.dispose();
    _ufController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
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
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
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
                          const SizedBox(height: 8),
                          Text(
                            'Dados de Acesso (${_currentStep + 1}/3)',
                            style: TextStyle(
                              fontSize: 18,
                              color: context.colors.secondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Form(
                            key: _formKey,
                            child: ExpandablePageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                // Primeiro formulario: Identificação Pessoal
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 12,
                                  children: [
                                    MyTextInput(
                                      controller: _nameController,
                                      hintText: 'Nome',
                                      readOnly: false,
                                      validator: (value) {
                                        if (_currentStep != 0) return null;
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Nome inválido';
                                        }
                                        if (value.length < 3) {
                                          return 'Nome deve ter mais de 3 caracteres';
                                        }
                                        if (value.length > 20) {
                                          return 'Nome deve ter menos de 20 caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                    MyTextInput(
                                      controller: _cpfController,
                                      hintText: 'CPF',
                                      inputFormatters: [_maskcpf],
                                      maxLength: 14,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (_currentStep != 0) return null;
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'CPF é obrigatório';
                                        }
                                        bool validCpf = CPFValidator.isValid(
                                          value,
                                        );
                                        if (validCpf == false) {
                                          return 'CPF inválido';
                                        }
                                        return null;
                                      },
                                      readOnly: false,
                                    ),
                                    MyTextInput(
                                      controller: _dataNascimentoController,
                                      hintText: 'Data de nascimento',
                                      inputFormatters: [_maskdata],
                                      keyboardType: TextInputType.datetime,
                                      validator: (value) {
                                        if (_currentStep != 0) return null;

                                        if (value == null || value.isEmpty) {
                                          _erroDataNascimento =
                                              'Por favor, insira sua data de nascimento';
                                          return _erroDataNascimento;
                                        }
                                        final dataLimpa = value.trim();

                                        if (dataLimpa.length < 10) {
                                          _erroDataNascimento =
                                              'Insira uma data completa';
                                          return _erroDataNascimento;
                                        }

                                        final parts = dataLimpa.split('/');
                                        final day = int.tryParse(parts[0]);
                                        final month = int.tryParse(parts[1]);
                                        final year = int.tryParse(parts[2]);

                                        if (day == null ||
                                            month == null ||
                                            year == null) {
                                          _erroDataNascimento = 'Data inválida';
                                          return _erroDataNascimento;
                                        }

                                        if (month < 1 || month > 12) {
                                          _erroDataNascimento = 'Mês inválido';
                                          return _erroDataNascimento;
                                        }
                                        if (year < 1900 ||
                                            year > DateTime.now().year) {
                                          _erroDataNascimento = 'Ano inválido';
                                          return _erroDataNascimento;
                                        }

                                        final dateVerification = DateTime(
                                          year,
                                          month,
                                          day,
                                        );
                                        if (dateVerification.day != day ||
                                            dateVerification.month != month ||
                                            dateVerification.year != year) {
                                          _erroDataNascimento =
                                              'Esta data não existe no calendário';
                                          return _erroDataNascimento;
                                        }

                                        _erroDataNascimento =
                                            null; // Tudo válido
                                        return null;
                                      },
                                      readOnly: false,
                                    ),
                                  ],
                                ),
                                // Segundo formulario: Credenciais
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 12,
                                  children: [
                                    MyTextInput(
                                      controller: _emailController,
                                      hintText: 'Email',
                                      readOnly: false,
                                      validator: (value) {
                                        if (_currentStep != 1) return null;
                                        if (value == null ||
                                            !value.contains('@')) {
                                          return 'E-mail inválido';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      validator: (value) {
                                        if (_currentStep != 1) return null;
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Preencha a senha!';
                                        }
                                        if (value.length < 6) {
                                          return 'A senha deve conter mais de 6 digitos!';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Senha',
                                        hintStyle: TextStyle(
                                          color: context.colors.secondary
                                              .withValues(alpha: 0.5),
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: true,
                                      validator: (value) {
                                        if (_currentStep != 1) return null;
                                        if (value != _passwordController.text) {
                                          return 'Senhas diferentes!';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Confirmar senha',
                                        hintStyle: TextStyle(
                                          color: context.colors.secondary
                                              .withValues(alpha: 0.5),
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                                // Terceiro formulario: Endereço
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 12,
                                  children: [
                                    Row(
                                      spacing: 16,
                                      children: [
                                        Expanded(
                                          child: MyTextInput(
                                            controller: _cepController,
                                            maxLength: 9,
                                            inputFormatters: [_maskcep],
                                            hintText: 'Cep',
                                            keyboardType: TextInputType.number,
                                            readOnly: false,
                                            // Executa sempre que o usuário digita/altera o campo de CEP
                                            onChanged: (value) {
                                              setState(() {
                                                _cityController.text = '';
                                                _ufController.text = '';
                                                _neighborhoodController.text =
                                                    '';
                                                _streetController.text = '';
                                                _cepIsValid = false;
                                              });
                                            },
                                            validator: (value) {
                                              if (_currentStep != 2) {
                                                return null;
                                              }

                                              // Se o campo estiver totalmente vazio, passa direto (é opcional)
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return null;
                                              }

                                              // Se tiver texto mas NÃO foi validado com sucesso pela API, barra o avanço
                                              if (!_cepIsValid) {
                                                return 'Valide o CEP ou limpe o campo para prosseguir';
                                              }

                                              return null;
                                            },
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Remove tudo o que não for número (pontos, traços, etc.)
                                            final cep = _cepController.text
                                                .replaceAll(
                                                  RegExp(r'[^\d]'),
                                                  '',
                                                )
                                                .trim();
                                            if (cep.length != 8) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Digite um CEP válido com 8 dígitos',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            final urlHttp = Uri.parse(
                                              'https://viacep.com.br/ws/$cep/json/',
                                            );

                                            http
                                                .get(urlHttp)
                                                .then((val) {
                                                  final data = jsonDecode(
                                                    val.body,
                                                  );

                                                  // Verifica se a API do ViaCEP retornou erro de CEP inválido/inexistente
                                                  if (data['erro'] == true ||
                                                      data['erro'] == 'true') {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'CEP não encontrado na base de dados!',
                                                        ),
                                                      ),
                                                    );
                                                    setState(() {
                                                      _cepIsValid = false;
                                                    });
                                                    return; // Para a execução aqui e não preenche nada
                                                  }

                                                  // Preenchimento com sucesso
                                                  setState(() {
                                                    _cityController.text =
                                                        data['localidade'] ??
                                                        '';
                                                    _ufController.text =
                                                        data['uf'] ?? '';
                                                    _neighborhoodController
                                                            .text =
                                                        data['bairro'] ?? '';
                                                    _streetController.text =
                                                        data['logradouro'] ??
                                                        '';
                                                    _cepIsValid =
                                                        true; // CEP validado!
                                                  });
                                                })
                                                .catchError((e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Erro de conexão ao buscar o CEP',
                                                      ),
                                                    ),
                                                  );
                                                  setState(() {
                                                    _cityController.text = '';
                                                    _ufController.text = '';
                                                    _neighborhoodController
                                                            .text =
                                                        '';
                                                    _streetController.text = '';
                                                    _cepIsValid = false;
                                                  });
                                                });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                context.colors.tertiary,
                                            padding: const EdgeInsets.all(16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Buscar',
                                            style: TextStyle(
                                              color:
                                                  context.colors.surfaceBright,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 16,
                                      children: [
                                        Expanded(
                                          child: MyTextInput(
                                            controller: _cityController,
                                            hintText: 'Cidade',
                                            inputFormatters: [],
                                            maxLength: 14,
                                            readOnly: true,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 75,
                                          ),
                                          child: MyTextInput(
                                            controller: _ufController,
                                            hintText: 'UF',
                                            inputFormatters: [],
                                            maxLength: 14,
                                            readOnly: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    MyTextInput(
                                      controller: _neighborhoodController,
                                      hintText: 'Bairro',
                                      inputFormatters: [],
                                      readOnly: true,
                                    ),
                                    Row(
                                      spacing: 16,
                                      children: [
                                        Expanded(
                                          child: MyTextInput(
                                            controller: _streetController,
                                            hintText: 'Rua',
                                            inputFormatters: [],
                                            readOnly: true,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 95,
                                          ),
                                          child: MyTextInput(
                                            controller: _numberController,
                                            hintText: 'Número',
                                            inputFormatters: [],
                                            maxLength: 14,
                                            keyboardType: TextInputType.number,
                                            readOnly: false,
                                            validator: (value) {
                                              if (_currentStep != 2) {
                                                return null;
                                              }
                                              if (!_cepIsValid) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  return 'Preencha o CEP!';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    MyTextInput(
                                      controller: _complementController,
                                      hintText: 'Complemento',
                                      inputFormatters: [],
                                      readOnly: false,
                                      validator: (value) {
                                        if (_currentStep != 2) {
                                          return null;
                                        }
                                        if (!_cepIsValid) {
                                          if (value != null &&
                                              value.isNotEmpty) {
                                            return 'Preencha o CEP!';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            spacing: 8,
                            children: [
                              if (_currentStep > 0)
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.colors.secondary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _previousStep,
                                    child: Text(
                                      'Voltar',
                                      style: TextStyle(
                                        color: context.colors.surfaceBright,
                                      ),
                                    ),
                                  ),
                                ),
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
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          // Valida apenas a página atual na árvore de componentes
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (_currentStep < 2) {
                                              _nextStep();
                                            } else {
                                              if (_cepIsValid == true ||
                                                  _cepController.text.isEmpty) {
                                                setState(
                                                  () => _isLoading = true,
                                                );

                                                try {
                                                  final response =
                                                      await _supabaseAuth.signUp(
                                                        email: _emailController
                                                            .text,
                                                        password:
                                                            _passwordController
                                                                .text,
                                                        displayName:
                                                            _nameController
                                                                .text,
                                                      );

                                                  final user = response.user;

                                                  if (user == null) {
                                                    throw Exception(
                                                      'Erro ao criar usuário. Tente novamente.',
                                                    );
                                                  }

                                                  if (!mounted) return;

                                                  try {
                                                    await _supabaseAuth.insertUser(
                                                      userId: user.id,
                                                      userEmail:
                                                          user.email ??
                                                          _emailController.text,
                                                      displayName:
                                                          _nameController.text,
                                                      cpf: _cpfController.text,
                                                      birthday:
                                                          _dataNascimentoController
                                                              .text,
                                                      cep: _cepController.text,
                                                      uf: _ufController.text,
                                                      city:
                                                          _cityController.text,
                                                      neighborhood:
                                                          _neighborhoodController
                                                              .text,
                                                      street: _streetController
                                                          .text,
                                                      number: _numberController
                                                          .text,
                                                      complement:
                                                          _complementController
                                                              .text,
                                                    );
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Erro: $e',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }

                                                  Navigator.pop(context);
                                                } on AuthException catch (e) {
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content:
                                                          e.message ==
                                                              'User already registered'
                                                          ? Text(
                                                              'Email já cadastrado',
                                                            )
                                                          : Text(e.message),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                } catch (e) {
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Erro inesperado: $e',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                } finally {
                                                  if (mounted) {
                                                    setState(
                                                      () => _isLoading = false,
                                                    );
                                                  }
                                                }
                                              }
                                            }
                                          } else {
                                            if (_currentStep == 0 &&
                                                _erroDataNascimento != null) {}
                                          }
                                        },
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
                                          _currentStep == 2
                                              ? 'Cadastrar'
                                              : 'Avançar',
                                          style: TextStyle(
                                            color: context.colors.surfaceBright,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_currentStep == 0) ...[
                            Text(
                              'Já possui uma conta?',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.colors.secondary,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.tertiary,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: context.colors.surfaceBright,
                                ),
                              ),
                            ),
                          ],
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
