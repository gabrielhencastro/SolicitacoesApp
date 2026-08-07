import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:open_file/open_file.dart';

class SupabaseFunctions {
  final _supabase = Supabase.instance.client;

  Future<void> createSolicitation({
    required String userId,
    required String solicitationType,
    required String description,
    required String cep,
    required String uf,
    required String city,
    required String neighborhood,
    required String street,
    String? number,
    String? complement,
    required List<String> listPhotoUri,
  }) async {
    // Cleaning formats
    cep = cep.replaceAll(RegExp(r'[^\d]'), '');
    // Executing the insert
    await _supabase.from('solicitacoes').insert({
      'id_usuario': userId,
      'tipo_solicitacao': solicitationType,
      'descricao': description,
      'cep': cep,
      'uf': uf,
      'cidade': city,
      'bairro': neighborhood,
      'rua': street,
      'numero': (number == null || number.trim().isEmpty)
          ? 0
          : (int.tryParse(number.trim()) ?? 0),
      'complemento': complement ?? '',
      'photo_uri': listPhotoUri,
    });
  }

  Future<List<String>> getSolicitationTypeList() async {
    final response = await _supabase.rpc('retorna_tipo_solicitacao_enum');

    return (response as List).cast<String>();
  }

  Future<void> generateReport({
    required String reportType,
    String? solicitationType,
    String? status,
  }) async {
    final url = Uri.https('solicitacoesapi.onrender.com', 'api/relatorio');
    final Map<String, String> body = {
      'tipo_relatorio': reportType,
      if (solicitationType != null) 'tipo_solicitacao': solicitationType,
      if (status != null) 'status_solicitacao': status,
    };

    final directory = await getApplicationDocumentsDirectory();
    final filePath = reportType == '1' ? '${directory.path}/relatorio.xlsx' : '${directory.path}/relatorio.pdf';

    final token = _supabase.auth.currentSession?.accessToken;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if(response.statusCode == 403){
      throw Exception('Sem permissões');
    }

    if(response.statusCode == 200){
      // Bytes da api
      final bytes = response.bodyBytes;
      // Caminho do arquivo
      final file = File(filePath);
      // Salva o arquivo
      await file.writeAsBytes(bytes);
      // Abre o arquivo
      await OpenFile.open(filePath);
    } else {
      throw Exception('Não foi possível gerar o relatório');
    }
  }
}
