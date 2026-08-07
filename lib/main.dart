import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solicitacoes_v1/screens/solicitation_details_screen.dart';
import 'package:solicitacoes_v1/screens/tracking_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    publishableKey: dotenv.get('PUBLISHABLE_KEY'),
  );

  runApp(const MyApp());
}

/// Notifier que escuta mudanças de autenticação
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      notifyListeners();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = AuthNotifier();

    final router = GoRouter(
      refreshListenable: authNotifier,
      initialLocation: '/', // rota inicial
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final loggingIn = state.matchedLocation == '/login';

        if (session == null) {
          // não logado → força login
          return loggingIn ? null : '/login';
        }

        // logado → força acompanhamento
        if (loggingIn || state.matchedLocation == '/') return '/tracking_screen';

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            // rota raiz decide com base na sessão
            final session = Supabase.instance.client.auth.currentSession;
            return session == null
                ? const LoginScreen()
                : const TrackingScreen();
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/tracking_screen',
          builder: (context, state) => const TrackingScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Solicitações - Heimdall',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          surface: Colors.grey[300]!,
          surfaceBright: Colors.white,
          primary: Colors.black,
          secondary: Colors.black.withValues(alpha: .8),
          tertiary: Colors.orange,
        ),
      ),
    );
  }
}
