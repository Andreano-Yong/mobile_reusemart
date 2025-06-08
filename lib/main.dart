import 'package:flutter/material.dart';

import 'login_page.dart';
import 'pembeliDasboard.dart';
import 'tamuDashboard.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReuseMart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/tamuDashboard': (context) => const TamuDashboardPage(),
        '/pembeliDashboard': (context) => const PembeliDashboardPage(),
      },
    );
  }
}
