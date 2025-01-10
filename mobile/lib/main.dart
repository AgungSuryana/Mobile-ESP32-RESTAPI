import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'history.dart';
import 'dart:async';
import 'chart_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Battery Visualization',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SensorDataScreen(),
    const HistoryPage(),
    const ChartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.battery_std),
            label: 'Visualization',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Chart', // Tambahkan menu Chart
          ),
        ],
      ),
    );
  }
}

class SensorDataScreen extends StatefulWidget {
  const SensorDataScreen({super.key});

  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  double gasLevel = 0.0;
  bool isLoading = true;
  Timer? timer;

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://restapi-js.vercel.app/api'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Urutkan data berdasarkan timestamp jika data tersedia
        data.sort((a, b) {
          return DateTime.parse(b['timestamp'])
              .compareTo(DateTime.parse(a['timestamp']));
        });

        setState(() {
          gasLevel = data.isNotEmpty
              ? double.parse(
                  data.first['gasLevel'].toString()) // Ambil data terbaru
              : 0.0;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        gasLevel = 0.0;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    // Timer untuk melakukan polling data setiap 10 detik
    timer =
        Timer.periodic(const Duration(seconds: 2), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    // Hentikan timer saat widget dihapus
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gas Level: ${gasLevel.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBatteryIndicator(),
                ],
              ),
      ),
    );
  }

  Widget _buildBatteryIndicator() {
    double batteryHeight = 200.0;
    double batteryWidth = 100.0;
    double levelHeight = (gasLevel / 300) * batteryHeight;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: batteryHeight,
          width: batteryWidth,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: levelHeight,
          width: batteryWidth - 6,
          decoration: BoxDecoration(
            color: gasLevel > 100
                ? Colors.red
                : gasLevel > 60
                    ? Colors.yellow
                    : Colors.green,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(7)),
          ),
        ),
        Positioned(
          top: -10,
          child: Container(
            height: 10,
            width: batteryWidth / 2,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
}
