import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import '../components/text_input.dart';
import '../helpers/theme_extensions.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../services/supabase_auth.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final PageController _pageController = PageController();
  final _supabaseAuth = SupabaseAuth();
  int _currentStep = 0;
  bool _cepIsValid = true;
  bool _isLoading = false;
  bool _isLoadingData = false;

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
  final _supabase = Supabase.instance.client;

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _nextStep() {
    if (_currentStep < 1) {
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

  Future<void> _loadUserData() async {
    final userData = _supabase.auth.currentUser!;
    final userId = userData.id;

    setState(() {
      _isLoadingData = true;
    });

    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single();

      // Formatting
      final parsedBirthday = DateTime.parse(response['data_nascimento']);
      final formattedBirthday = DateFormat('dd/MM/yyyy').format(parsedBirthday);
      final rawCpf = response['cpf'];
      final formattedCpf = _maskcpf.maskText(rawCpf);
      final rawCep = response['cep'] ?? '';
      final formattedCep = _maskcep.maskText(rawCep);

      // Updating data
      _emailController.text = userData.email!;
      _nameController.text = response['display_name'];
      _cpfController.text = formattedCpf;
      _dataNascimentoController.text = formattedBirthday;
      _cepController.text = formattedCep;
      _ufController.text = response['uf'] ?? '';
      _cityController.text = response['cidade'] ?? '';
      _neighborhoodController.text = response['bairro'] ?? '';
      _streetController.text = response['rua'] ?? '';
      _numberController.text = response['numero'] ?? '';
      _complementController.text = response['complemento'] ?? '';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar conta',
          style: TextStyle(color: context.colors.surfaceBright),
        ),
        iconTheme: IconThemeData(color: context.colors.surfaceBright),
        backgroundColor: context.colors.tertiary,
      ),
      body: _isLoadingData
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
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
                                const SizedBox(height: 8),
                                Text(
                                  'Editar conta',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Dados da conta (${_currentStep + 1}/2)',
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                              if (_currentStep != 0)
                                                return null;
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
                                            controller: _emailController,
                                            hintText: 'Email',
                                            readOnly: true,
                                            validator: (value) {
                                              if (_currentStep != 0)
                                                return null;
                                              if (value == null ||
                                                  !value.contains('@')) {
                                                return 'E-mail inválido';
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
                                              if (_currentStep != 0)
                                                return null;
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'CPF é obrigatório';
                                              }
                                              bool validCpf =
                                                  CPFValidator.isValid(value);
                                              if (validCpf == false) {
                                                return 'CPF inválido';
                                              }
                                              return null;
                                            },
                                            readOnly: false,
                                          ),
                                          MyTextInput(
                                            controller:
                                                _dataNascimentoController,
                                            hintText: 'Data de nascimento',
                                            inputFormatters: [_maskdata],
                                            keyboardType:
                                                TextInputType.datetime,
                                            validator: (value) {
                                              if (_currentStep != 0)
                                                return null;

                                              if (value == null ||
                                                  value.isEmpty) {
                                                _erroDataNascimento =
                                                    'Data inválida!';
                                                return _erroDataNascimento;
                                              }
                                              final dataLimpa = value.trim();

                                              if (dataLimpa.length < 10) {
                                                _erroDataNascimento =
                                                    'Insira uma data completa';
                                                return _erroDataNascimento;
                                              }

                                              final parts = dataLimpa.split(
                                                '/',
                                              );
                                              final day = int.tryParse(
                                                parts[0],
                                              );
                                              final month = int.tryParse(
                                                parts[1],
                                              );
                                              final year = int.tryParse(
                                                parts[2],
                                              );

                                              if (day == null ||
                                                  month == null ||
                                                  year == null) {
                                                _erroDataNascimento =
                                                    'Data inválida';
                                                return _erroDataNascimento;
                                              }

                                              if (month < 1 || month > 12) {
                                                _erroDataNascimento =
                                                    'Mês inválido';
                                                return _erroDataNascimento;
                                              }
                                              if (year < 1900 ||
                                                  year > DateTime.now().year) {
                                                _erroDataNascimento =
                                                    'Ano inválido';
                                                return _erroDataNascimento;
                                              }

                                              final dateVerification = DateTime(
                                                year,
                                                month,
                                                day,
                                              );
                                              if (dateVerification.day != day ||
                                                  dateVerification.month !=
                                                      month ||
                                                  dateVerification.year !=
                                                      year) {
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
                                      // Segundo formulario: Endereço
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
                                                  keyboardType:
                                                      TextInputType.number,
                                                  readOnly: false,
                                                  // Executa sempre que o usuário digita/altera o campo de CEP
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _cityController.text = '';
                                                      _ufController.text = '';
                                                      _neighborhoodController
                                                              .text =
                                                          '';
                                                      _streetController.text =
                                                          '';
                                                      _cepIsValid = false;
                                                    });
                                                  },
                                                  validator: (value) {
                                                    if (_currentStep != 1) {
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
                                                  final cep = _cepController
                                                      .text
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
                                                        if (data['erro'] ==
                                                                true ||
                                                            data['erro'] ==
                                                                'true') {
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
                                                              data['bairro'] ??
                                                              '';
                                                          _streetController
                                                                  .text =
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
                                                          _cityController.text =
                                                              '';
                                                          _ufController.text =
                                                              '';
                                                          _neighborhoodController
                                                                  .text =
                                                              '';
                                                          _streetController
                                                                  .text =
                                                              '';
                                                          _cepIsValid = false;
                                                        });
                                                      });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      context.colors.tertiary,
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Buscar',
                                                  style: TextStyle(
                                                    color: context
                                                        .colors
                                                        .surfaceBright,
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
                                                constraints:
                                                    const BoxConstraints(
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
                                                constraints:
                                                    const BoxConstraints(
                                                      maxWidth: 95,
                                                    ),
                                                child: MyTextInput(
                                                  controller: _numberController,
                                                  hintText: 'Número',
                                                  inputFormatters: [],
                                                  maxLength: 14,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  readOnly: false,
                                                  validator: (value) {
                                                    if (_currentStep != 1) {
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
                                              if (_currentStep != 1) {
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
                                            backgroundColor:
                                                context.colors.secondary,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: _previousStep,
                                          child: Text(
                                            'Voltar',
                                            style: TextStyle(
                                              color:
                                                  context.colors.surfaceBright,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              context.colors.tertiary,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: _isLoading
                                            ? null
                                            : () async {
                                                // Valida apenas a página atual na árvore de componentes
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  if (_currentStep < 1) {
                                                    _nextStep();
                                                  } else {
                                                    if (_cepIsValid == true ||
                                                        _cepController
                                                            .text
                                                            .isEmpty) {
                                                      setState(
                                                        () => _isLoading = true,
                                                      );

                                                      try {
                                                        await _supabaseAuth.editUser(
                                                          currentUser: _supabase
                                                              .auth
                                                              .currentUser!,
                                                          displayName:
                                                              _nameController
                                                                  .text,
                                                          email:
                                                              _emailController
                                                                  .text,
                                                          cpf: _cpfController
                                                              .text,
                                                          birthdate:
                                                              _dataNascimentoController
                                                                  .text,
                                                          cep: _cepController
                                                              .text,
                                                          uf: _ufController
                                                              .text,
                                                          city: _cityController
                                                              .text,
                                                          neighborhood:
                                                              _neighborhoodController
                                                                  .text,
                                                          street:
                                                              _streetController
                                                                  .text,
                                                          number:
                                                              _numberController
                                                                  .text,
                                                          complement:
                                                              _complementController
                                                                  .text,
                                                        );

                                                        setState(() {

                                                        });
                                                        if (!mounted) return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Dados alterados com sucesso!',
                                                            ),
                                                            backgroundColor:
                                                                Colors.green,
                                                          ),
                                                        );
                                                        if (!mounted) return;
                                                        Navigator.pop(context);
                                                      } catch (e) {
                                                        if (!mounted) return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Erro ao editar conta: $e',
                                                            ),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      } finally {
                                                        if (mounted) {
                                                          setState(
                                                            () => _isLoading =
                                                                false,
                                                          );
                                                        }
                                                      }
                                                    }
                                                  }
                                                } else {
                                                  if (_currentStep == 0 &&
                                                      _erroDataNascimento !=
                                                          null) {}
                                                }
                                              },
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : Text(
                                                _currentStep == 1
                                                    ? 'Editar'
                                                    : 'Avançar',
                                                style: TextStyle(
                                                  color: context
                                                      .colors
                                                      .surfaceBright,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.copyright,
                                      size: 14,
                                      color: context.colors.secondary
                                          .withValues(alpha: 0.5),
                                    ),
                                    Text(
                                      ' 2026 Heimdall Solutions',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.colors.secondary
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
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
