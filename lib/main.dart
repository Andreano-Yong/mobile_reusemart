import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


import 'hunterDashboard.dart';
import 'kurirDashboard.dart';
import 'login_page.dart';
import 'pembeliDasboard.dart';
import 'tamuDashboard.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReuseMart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/tamuDashboard':
            return MaterialPageRoute(builder: (_) => const TamuDashboardPage());
          case '/pembeliDashboard':
            return MaterialPageRoute(builder: (_) => const PembeliDashboardPage());
          case '/hunterDashboard':
            final idHunter = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => HunterDashboardPage(idHunter: idHunter),
            );
          case '/kurirDashboard':
            final idKurir = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => KurirDashboardPage(idKurir: idKurir),
            );
          default:
            return null;
        }
      },
    );
  }
}
