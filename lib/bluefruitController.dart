import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluefruitController extends StatefulWidget {
  final BluetoothDevice bluefruit;
  final Function setBluefruit;
  final Function printBluefruit;

  BluefruitController(this.bluefruit, this.setBluefruit, this.printBluefruit);

  @override
  _BluefruitControllerState createState() => _BluefruitControllerState();
}

class _BluefruitControllerState extends State<BluefruitController> {
  BluetoothCharacteristic bluefruitInput;
  BluetoothCharacteristic bluefruitOutput;
  String time;
  var decoder = new AsciiCodec();
  TimeOfDay _alarmTime;
  var serialReceived = '';
  List<String> alarmState = new List<String>();
  var clockHour;
  var clockMinute;
  var alarmHour;
  var alarmMinute;
  var alarmArmed;
  var fullSerialReceived = '';

  @override
  void initState() {
    connect().whenComplete(() {
      discoverServices();
    });
    super.initState();
  }

  Future<void> connect() async {
    try {
      print(widget.bluefruit.name);
      return await widget.bluefruit.connect();
    } catch (error) {
      print('Caught error: $error');
    }
  }

  void discoverServices() async {
    List<BluetoothService> services = await widget.bluefruit.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString().substring(4, 8) == '0001') {
        print('found it');
        for (BluetoothCharacteristic char in service.characteristics) {
          if (char.uuid.toString().substring(4, 8) == '0003') {
            print('found the output');
            setState(() {
              bluefruitOutput = char;
            });
          }
          if (char.uuid.toString().substring(4, 8) == '0002') {
            print('found the input');
            setState(() {
              bluefruitInput = char;
            });
          }
        }
      }
    }
  }

  void sendTime() async {
    var now = new DateTime.now();
    var hour = now.hour.toString();
    print('the hour is ${hour}');
    var minute = now.minute.toString();
    var second = now.second.toString();
    if (now.hour < 10) {
      hour = '0' + hour;
    }
    if (now.minute < 10) {
      minute = '0' + minute;
    }
    if (now.second < 10) {
      second = '0' + second;
    }

    print(' ');
    print('hour is ${now.hour}');
    print('hour.toString is ${now.hour.toString()}');

    print(now.toString());
    print('${now.hour} --- ${hour}');
    print('${now.minute} --- ${minute}');
    print('${now.second} --- ${second}');
    print('');

    var encodedString = decoder.encode('SET_TIME${hour}${minute}${second}');
    var response = await bluefruitInput.write(encodedString);
    print(response);
  }

  void sendAlarmTime() async {
    var hour = _alarmTime.hour.toString();
    var minute = _alarmTime.minute.toString();
    if (_alarmTime.hour < 10) {
      hour = '0' + hour;
    }
    if (_alarmTime.minute < 10) {
      minute = '0' + minute;
    }
    var encodedString = decoder.encode('SET_ALARM${hour}${minute}');
    var response = await bluefruitInput.write(encodedString);
    print(response);
  }

  void listenToOutput() async {
    await bluefruitOutput.setNotifyValue(true);
    bluefruitOutput.value.listen((value) {
      var decoded = decoder.decode(value);
      parseOutput(fullSerialReceived + decoded);
    });
  }

  void parseOutput(String message) {
    var truncatedMessage;
    if (message.length > 65) {
      truncatedMessage = message.substring(message.length - 60);
    } else {
      truncatedMessage = message;
    }
    for (int i = 0; i < truncatedMessage.length; i++) {
      try {
        if (truncatedMessage.substring(i, i + 4) == "TIME") {
          print('the time is reading: ${time}');
          try {
            setState(() {
              clockHour = truncatedMessage.substring(i + 4, i + 6);
              clockMinute = truncatedMessage.substring(i + 6, i + 8);
            });
          } catch (error) {}
        }
        if (truncatedMessage.substring(i, i + 5) == "ALARM") {
          try {
            setState(() {
              alarmHour = truncatedMessage.substring(i + 5, i + 7);
              alarmMinute = truncatedMessage.substring(i + 7, i + 9);
            });
          } catch (error) {}
        }
        if (truncatedMessage.substring(i, i + 5) == "ARMED") {
          try {} catch (error) {}
        }
      } catch (error) {}
    }
    setState(() {
      fullSerialReceived = truncatedMessage;
    });
  }

  void disconnect() async {
    await widget.bluefruit.disconnect();
    widget.setBluefruit(null);
  }

  Future<Null> selectTime(BuildContext context) async {
    var tempTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      _alarmTime = tempTime;
    });
    print(_alarmTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text('This is the bluetooth module'),
          RaisedButton(child: Text('send time'), onPressed: sendTime),
          RaisedButton(
            child: Text('set alarm time'),
            onPressed: () {
              selectTime(context);
            },
          ),
          RaisedButton(child: Text('set alarm!'), onPressed: sendAlarmTime),
          RaisedButton(child: Text('read output'), onPressed: listenToOutput),
          Text('the clock time is showing ${clockHour}:${clockMinute}'),
          Text('the alarm time is showing ${alarmHour}:${alarmMinute}'),
          Icon(Icons.access_alarm),
          Text(serialReceived)
        ],
      ),
    );
  }
}
