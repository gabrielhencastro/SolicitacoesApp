import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:solicitacoes_v1/screens/new_solicitacion_screen.dart';
import 'package:solicitacoes_v1/screens/report_screen.dart';
import 'package:solicitacoes_v1/screens/tracking_screen.dart';
import '../helpers/theme_extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/account_screen.dart';
import '../screens/dashboard_screen.dart';

class MyDrawer extends StatefulWidget {
  final String telaAtiva;
  const MyDrawer({super.key, required this.telaAtiva});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String? nivelAcesso;

  @override
  void initState() {
    super.initState();
    _loadNivelAcesso();
  }

  Future<void> _loadNivelAcesso() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => nivelAcesso = 'cidadao');
      return;
    }

    final response = await Supabase.instance.client
        .from('profiles')
        .select('nivel_acesso')
        .eq('id', user.id)
        .maybeSingle();

    setState(() {
      nivelAcesso = response?['nivel_acesso'] ?? 'cidadao';
    });
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;

    final words = text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).toList();

    return capitalizedWords.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = user?.userMetadata?['display_name'] ?? 'Visitante';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: context.colors.tertiary),
            child: Column(
              spacing: 16,
              children: [
                Image(
                  image: AssetImage('lib/assets/simple_logo.png'),
                  width: 80,
                  alignment: Alignment.center,
                ),
                Flexible(
                  child: Text(
                    'Olá, ${capitalize(displayName)}!',
                    style: TextStyle(
                      color: context.colors.surfaceBright,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (nivelAcesso != 'cidadao') ...[
            ListTile(
              leading: FaIcon(FontAwesomeIcons.chartBar),
              title: const Text('Dashboard'),
              selected: widget.telaAtiva == 'Dashboard',
              selectedTileColor: context.colors.secondary.withValues(alpha: 0.1),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.fileLines),
              title: const Text('Relatórios'),
              selected: widget.telaAtiva == 'Relatórios',
              selectedTileColor: context.colors.secondary.withValues(alpha: 0.1),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReportScreen()));
              },
            ),
          ],
          ListTile(
            leading: FaIcon(FontAwesomeIcons.plus),
            title: const Text('Nova solicitação'),
            selected: widget.telaAtiva == 'Nova solicitação',
            selectedTileColor: context.colors.secondary.withValues(alpha: 0.1),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NewSolicitacionScreen()));
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.envelope),
            title: const Text('Acompanhamento'),
            selected: widget.telaAtiva == 'Acompanhamento',
            selectedTileColor: context.colors.secondary.withValues(alpha: 0.1),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TrackingScreen()));
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.user),
            title: const Text('Conta'),
            selected: widget.telaAtiva == 'Conta',
            selectedTileColor: context.colors.secondary.withValues(alpha: 0.1),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen()));
            },
          ),
        ],
      ),
    );
  }
}
