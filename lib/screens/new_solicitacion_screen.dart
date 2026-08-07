import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:solicitacoes_v1/components/text_input.dart';
import 'package:solicitacoes_v1/services/supabase_functions.dart';
import '../components/drawer.dart';
import '../helpers/theme_extensions.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewSolicitacionScreen extends StatefulWidget {
  const NewSolicitacionScreen({super.key});

  @override
  State<NewSolicitacionScreen> createState() => _NewSolicitacionScreen();
}

class _NewSolicitacionScreen extends State<NewSolicitacionScreen> {
  final PageController _pageController = PageController();
  final _descriptionController = TextEditingController();
  final _cepController = TextEditingController();
  final _ufController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  String? _selectedType;

  int _currentStep = 0;
  bool _cepIsValid = false;

  final _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  final _supabaseFunctions = SupabaseFunctions();
  final List<String> _fileNames = [];
  final List<PlatformFile> _selectedFiles = [];
  List<String> _solicitationTypeList = [];

  final _maskcep = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    _cepController.dispose();
    _ufController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (bytes / 1024).floor() == 0
        ? 0
        : (bytes.toString().length - 1) ~/ 3;
    double num = bytes / (1024 * i);
    return "${num.toStringAsFixed(1)} ${suffixes[i]}";
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image, // restringe a imagens
        allowMultiple: true,
      );

      if (result != null) {
        const int maxSizeBytes = 5 * 1024 * 1024; // limite de 5MB
        List<PlatformFile> validFiles = [];
        bool excedeuLimite = false;

        for (var file in result.files) {
          // valida extensão manualmente
          final ext = file.name.split('.').last.toLowerCase();
          if (!['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Arquivo inválido: ${file.name}'),
                backgroundColor: Colors.redAccent,
              ),
            );
            continue;
          }

          // valida tamanho
          if (file.size <= maxSizeBytes) {
            validFiles.add(file);
          } else {
            excedeuLimite = true;
          }
        }

        setState(() {
          _selectedFiles.addAll(validFiles);
        });

        if (excedeuLimite) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Algumas imagens eram maiores que 5MB e não foram adicionadas.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Erro ao selecionar arquivos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar arquivos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<String>> _uploadFiles() async {
    List<String> photosUriList = [];
    try {
      for (final file in _selectedFiles) {
        final bytes = await File(file.path!).readAsBytes();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

        await _supabase.storage
            .from('solicitation_photos')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(upsert: false),
            );

        final publicUrl = _supabase.storage
            .from('solicitation_photos')
            .getPublicUrl(fileName);

        photosUriList.add(publicUrl);
        _fileNames.add(fileName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar arquivos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return photosUriList;
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

  @override
  void initState() {
    super.initState();
     _loadSolicitationTypes();
  }

  Future<void> _loadSolicitationTypes() async {
    try {
      final solicitationTypeList = await _supabaseFunctions.getSolicitationTypeList();
      setState(() {
        _solicitationTypeList = solicitationTypeList;
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nova solicitação',
          style: TextStyle(color: context.colors.surfaceBright),
        ),
        iconTheme: IconThemeData(color: context.colors.surfaceBright),
        backgroundColor: context.colors.tertiary,
      ),
      drawer: MyDrawer(telaAtiva: 'Nova solicitação'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                          'Nova solicitação (${_currentStep + 1}/2)',
                          style: TextStyle(
                            fontSize: 18,
                            color: context.colors.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Form(
                          key: _formKey,
                          child: ExpandablePageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              // Primeiro formulario: Tipo, descrição e anexo
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                spacing: 12,
                                children: [
                                  DropdownButtonFormField<String>(
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    initialValue: _selectedType,
                                    decoration: InputDecoration(
                                      hintText: 'Tipo de solicitação',
                                      hintStyle: TextStyle(
                                        color: context.colors.primary
                                            .withValues(alpha: 0.5),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      border: const OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: context.colors.primary
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: context.colors.primary,
                                        ),
                                      ),
                                    ),
                                    items:
                                         _solicitationTypeList.map<DropdownMenuItem<String>>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Selecione um tipo de solicitação';
                                      }
                                      return null;
                                    },
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedType = newValue;
                                      });
                                    },
                                  ),
                                  MyTextInput(
                                    controller: _descriptionController,
                                    hintText: 'Descrição',
                                    readOnly: false,
                                    minLines: 5,
                                    maxLines: 5,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Preencha a descrição';
                                      }
                                      if (value.length < 15) {
                                        return 'Minímo de 15 caracteres';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Campo Anexo de Arquivos Estilizado + Lista Dinâmica
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Anexar arquivos',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: context.colors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: () {
                                          if (_selectedFiles.length >= 3) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Limite de arquivos atingido!',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          _pickFile();
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: context.colors.primary
                                                  .withValues(alpha: 0.3),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(7),
                                                        bottomLeft:
                                                            Radius.circular(7),
                                                      ),
                                                  border: Border(
                                                    right: BorderSide(
                                                      color: context
                                                          .colors
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Selecionar',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                      ),
                                                  child: Text(
                                                    _selectedFiles.isEmpty
                                                        ? 'Nenhum arquivo selecionado'
                                                        : '${_selectedFiles.length} arquivo(s) selecionado(s)',
                                                    style: TextStyle(
                                                      color:
                                                          _selectedFiles
                                                              .isNotEmpty
                                                          ? Colors.black87
                                                          : Colors
                                                                .grey
                                                                .shade600,
                                                      fontSize: 14,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Lista de arquivos selecionados com botão de remoção
                                      if (_selectedFiles.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Column(
                                          children: _selectedFiles.asMap().entries.map((
                                            entry,
                                          ) {
                                            int index = entry.key;
                                            PlatformFile file = entry.value;

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey.shade200,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    file.extension == 'pdf'
                                                        ? Icons
                                                              .picture_as_pdf_outlined
                                                        : Icons.image_outlined,
                                                    color:
                                                        context.colors.primary,
                                                    size: 24,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          file.name,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          _formatBytes(
                                                            file.size,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.redAccent,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _selectedFiles.removeAt(
                                                          index,
                                                        );
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              // Terceiro formulario: endereco
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
                                              _neighborhoodController.text = '';
                                              _streetController.text = '';
                                              _cepIsValid = false;
                                            });
                                          },
                                          validator: (value) {
                                            // Se tiver texto mas NÃO foi validado com sucesso pela API, barra o avanço
                                            if (!_cepIsValid) {
                                              return 'Valide o CEP!';
                                            }

                                            return null;
                                          },
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Remove tudo o que não for número (pontos, traços, etc.)
                                          final cep = _cepController.text
                                              .replaceAll(RegExp(r'[^\d]'), '')
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
                                                      data['localidade'] ?? '';
                                                  _ufController.text =
                                                      data['uf'] ?? '';
                                                  _neighborhoodController.text =
                                                      data['bairro'] ?? '';
                                                  _streetController.text =
                                                      data['logradouro'] ?? '';
                                                  _cepIsValid =
                                                      true; // CEP validado!
                                                  _formKey.currentState!
                                                      .validate();
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
                                                  _neighborhoodController.text =
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Buscar',
                                          style: TextStyle(
                                            color: context.colors.surfaceBright,
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
                                        ),
                                      ),
                                    ],
                                  ),
                                  MyTextInput(
                                    controller: _complementController,
                                    hintText: 'Complemento',
                                    inputFormatters: [],
                                    readOnly: false,
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
                                        if (_formKey.currentState!.validate()) {
                                          if (_currentStep < 1) {
                                            if (_selectedFiles.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Envia no minímo uma foto!',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                            _nextStep();
                                          } else {
                                            final photosUriList =
                                                await _uploadFiles();
                                            if (photosUriList.isNotEmpty) {
                                              try {
                                                await _supabaseFunctions
                                                    .createSolicitation(
                                                      userId: _supabase
                                                          .auth
                                                          .currentUser!
                                                          .id,
                                                      solicitationType:
                                                          _selectedType!,
                                                      description:
                                                          _descriptionController
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
                                                      listPhotoUri:
                                                          photosUriList,
                                                    );

                                                if (!mounted) return;

                                                Navigator.of(context).pop();
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Solicitação criada com sucesso!',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              } catch (e) {
                                                // The application may not create
                                                // the solicitation
                                                // in this cases, the uploaded photos
                                                // will be removed from the bucket
                                                for (final file in _fileNames) {
                                                  try {
                                                    await _supabase.storage
                                                        .from(
                                                          'solicitation_photos',
                                                        )
                                                        .remove([file]);
                                                  } catch (removeError) {
                                                    debugPrint(
                                                      'Erro ao remover arquivo $file: $removeError',
                                                    );
                                                  }
                                                }
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Erro: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }
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
                                        _currentStep == 1 ? 'Criar' : 'Avançar',
                                        style: TextStyle(
                                          color: context.colors.surfaceBright,
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
          );
        },
      ),
    );
  }
}
