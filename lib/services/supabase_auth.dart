import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SupabaseAuth {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final AuthResponse response = await _supabase.auth.signUp(
      password: password,
      email: email,
      data: {'display_name': displayName},
    );
    return response;
  }

  Future<AuthResponse> loginWithPassword({
    required String email,
    required String password,
  }) async {
    final AuthResponse response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut(scope: SignOutScope.local);
  }

  Future<void> insertUser({
    required String userId,
    required String userEmail,
    required String displayName,
    required String cpf,
    required String birthday,
    String? cep,
    String? uf,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
    String? complement,
  }) async {
    List<String> dateParts = birthday.split('/');
    String birthdayFormated = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}";

    // Cleaning formats
    cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cep != null) {
      cep = cep.replaceAll(RegExp(r'[^\d]'), '');
    }
    await _supabase.from('profiles').insert({
      'id': userId,
      'email': userEmail,
      'display_name': displayName,
      'data_nascimento': birthdayFormated,
      'cpf': cpf,
      'cep': cep ?? '',
      'uf': uf ?? '',
      'cidade': city ?? '',
      'bairro': neighborhood ?? '',
      'rua': street ?? '',
      'numero': (number == null || number.trim().isEmpty)
          ? 0
          : (int.tryParse(number.trim()) ?? 0),
      'complemento': complement ?? '',
    });
  }

  Future<void> editUser({
    required User currentUser,
    required String displayName,
    required String email,
    required String cpf,
    required String birthdate,
    String? cep,
    String? uf,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
    String? complement,
  }) async {
    List<String> dateParts = birthdate.split('/');
    String birthdayFormated = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}";

    // Cleaning formats
    cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cep != null) {
      cep = cep.replaceAll(RegExp(r'[^\d]'), '');
    }
    await _supabase
        .from('profiles')
        .update({
          'display_name': displayName,
          'cpf': cpf,
          'data_nascimento': birthdayFormated,
          'cep': cep ?? '',
          'uf': uf ?? '',
          'cidade': city ?? '',
          'bairro': neighborhood ?? '',
          'rua': street,
          'numero': (number == null || number.trim().isEmpty)
              ? 0
              : (int.tryParse(number.trim()) ?? 0),
          'complemento': complement ?? '',
        })
        .eq('id', currentUser.id);

    await _supabase.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': displayName,
          'name': displayName,
          'display_name': displayName,
        },
      ),
    );
  }

  Future<void> deleteUser({required User currentUser}) async {
    // API
    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    final url = Uri.https('solicitacoesapi.onrender.com', 'api/disable-user');
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });


    if (response.statusCode == 200) {
      // Cancel all the solicitations that the user have
      await _supabase
          .from('solicitacoes')
          .update({'status': 'Cancelado'})
          .eq('id_usuario', currentUser.id)
          .neq('status', 'Concluido')
          .neq('status', 'Cancelado');

      // Sign out
      await signOut();

    } else {
      throw Exception('Falha ao deletar usuário no servidor: ${response.body}');
    }
  }
}
