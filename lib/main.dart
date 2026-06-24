import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const PeopleFinderApp());
}

class PeopleFinderApp extends StatelessWidget {
  const PeopleFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'People Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = 'Нажмите кнопку для начала';
  Position? _currentPosition;

  Future<void> _requestPermissions() async {
    setState(() {
      _status = 'Запрашиваем разрешения...';
    });

    // Запрашиваем разрешения
    await Permission.location.request();
    await Permission.camera.request();

    // Проверяем GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _status = 'GPS выключен. Включите в настройках.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _status = 'Разрешение на GPS отклонено';
        });
        return;
      }
    }

    // Получаем текущую позицию
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      _status = 'Позиция: ${position.latitude}, ${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People Finder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _requestPermissions,
                child: const Text('Найти людей рядом'),
              ),
              const SizedBox(height: 20),
              if (_currentPosition != null)
                ElevatedButton(
                  onPressed: () {
                    // TODO: Открыть камеру с AR
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AR камера - в разработке')),
                    );
                  },
                  child: const Text('Открыть AR камеру'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}