import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import './bluefruitFinder.dart';
import './bluefruitController.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _bluefruit;
  FlutterBlue flutterBlue = FlutterBlue.instance;

  void setBluefruit(BluetoothDevice device) {
    setState(() {
      _bluefruit = device;
    });
  }

  void printBluefruitName() {
    print(_bluefruit.name);
  }

  void printBluefruit() {
    print(_bluefruit);
  }

  var subscription;
  void findBluefruit() {
    try {
      flutterBlue.startScan(timeout: Duration(seconds: 4));
      print("trying to find bluefruits...");
      subscription = flutterBlue.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.name == 'Adafruit Bluefruit LE') {
            setBluefruit(r.device);
          }
        }
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bluefruit == null) {
      return MaterialApp(
        title: 'Find your JumpStart',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Find your jumpstart'),
          ),
          body: Container(
            child: BluefruitFinder(setBluefruit, findBluefruit, printBluefruit),
          ),
        ),
      );
    } else {
      return MaterialApp(
        title: 'Control your jumpstart',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Control your jumpstart'),
          ),
          body: BluefruitController(_bluefruit, setBluefruit, printBluefruit),
        ),
      );
    }
  }
}
