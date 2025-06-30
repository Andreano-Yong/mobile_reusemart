import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'hunterProfil.dart';
import 'package:intl/intl.dart';

class HunterDashboardPage extends StatefulWidget {
  final int idHunter;

  const HunterDashboardPage({super.key, required this.idHunter});

  @override
  State<HunterDashboardPage> createState() => _HunterDashboardPageState();
}

class _HunterDashboardPageState extends State<HunterDashboardPage> {
  int _selectedIndex = 0;
  List<dynamic> _komisiData = [];
  String? _selectedMonth;
  String? _selectedYear;

  List<String> months = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12'
  ];

  List<String> years = List.generate(5, (index) => (DateTime.now().year - index).toString());

  @override
  void initState() {
    super.initState();
    fetchKomisiHistory();
  }

  Future<void> fetchKomisiHistory() async {
    final response = await http.get(Uri.parse(
        'https://reusemartkf.barioth.web.id/api/hunter/komisi/${widget.idHunter}')); // sesuaikan base URL
    if (response.statusCode == 200) {
      setState(() {
        _komisiData = json.decode(response.body)['data'];
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HunterProfilPage(idHunter: widget.idHunter),
        ),
      );
    }
  }

  List<dynamic> getFilteredData() {
    if (_selectedMonth == null || _selectedYear == null) return _komisiData;

    return _komisiData.where((item) {
      final tanggal = item['TANGGAL_DITERIMA'];
      if (tanggal == null) return false;

      try {
        final parsedDate = DateTime.parse(tanggal);
        final month = parsedDate.month.toString().padLeft(2, '0');
        final year = parsedDate.year.toString();
        return month == _selectedMonth && year == _selectedYear;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Widget buildKomisiList() {
    final data = getFilteredData();

    if (data.isEmpty) {
      return const Center(child: Text("Belum ada komisi pada periode ini."));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final tanggal = item['TANGGAL_DITERIMA'] ?? 'Belum diterima';
        final komisi = item['KOMISI_HUNTER']?.toString() ?? '0';
        final List barangList = item['barangs'] ?? [];

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tanggal: $tanggal", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Komisi Hunter: Rp$komisi"),
                const SizedBox(height: 8),
                const Text("Barang terkait:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...barangList.map((b) => Text("- ${b['NAMA_BARANG']}")).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedMonth,
              hint: const Text("Pilih Bulan"),
              items: months.map((m) {
                final monthName = DateFormat('MMMM', 'id_ID').format(DateTime(0, int.parse(m)));
                return DropdownMenuItem(
                  value: m,
                  child: Text(monthName),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedMonth = val),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedYear,
              hint: const Text("Pilih Tahun"),
              items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
              onChanged: (val) => setState(() => _selectedYear = val),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Row(
          children: [
            Icon(Icons.person_search, color: Colors.white),
            SizedBox(width: 8),
            Text('Dashboard Hunter', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? Column(
              children: [
                buildFilterBar(),
                Expanded(child: buildKomisiList()),
              ],
            )
          : const Center(child: Text('')),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History Komisi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil Akun',
          ),
        ],
      ),
    );
  }
}
