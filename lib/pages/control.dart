import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';

class Control extends StatefulWidget {
  const Control({super.key});

  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> {
  bool _manualState = false;
  final _bluetooth = FlutterBluetoothSerial.instance;
  bool _bluetoothState = false;
  bool _isConnecting = false;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _deviceConnected;
  int times = 0;

  void _sendData(String data) {
    if (_connection?.isConnected ?? false) {
      _connection?.output.add(ascii.encode(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/robot_arm_not_hd.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ZonaSort',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Kamis, 5 Desember 2024',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.0),
                  // Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Color.fromRGBO(18, 132, 233, 0.65)),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: SwitchListTile(
                      // activeColor: Color.fromRGBO(48, 23, 242, 1),
                      value: _manualState,
                      onChanged: (bool value) {
                        setState(() {
                          _manualState = value;
                        });
                      },
                      // tileColor: Colors.green,
                      title: Row(
                        children: [
                          Image.asset(
                            'assets/controller.png',
                            height: 70,
                            // width: 70,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            _manualState ? "Mode Manual" : "Mode Otomatis",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // _inputSerial(),
                  _manualState ? pressButton() : sortedAmount(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget pressButton() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color.fromRGBO(18, 132, 233, 0.80)),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          children: [
            IconButton(
              onPressed: () => _sendData("1"),
              icon: Image.asset(
                'assets/up.png',
                height: 60,
                width: 60,
              ),
            ),
            // const SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _sendData("2"),
                  icon: Image.asset(
                    'assets/left.png',
                    height: 60,
                    width: 60,
                  ),
                ),
                IconButton(
                  onPressed: () => _sendData("5"),
                  icon: const Icon(
                    Icons.pause,
                    size: 70,
                    color: Color.fromRGBO(217, 217, 217, 1),
                  ),
                ),
                IconButton(
                  onPressed: () => _sendData("3"),
                  icon: Image.asset(
                    'assets/right.png',
                    height: 60,
                    width: 60,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => _sendData("3"),
              icon: Image.asset(
                'assets/down.png',
                height: 60,
                width: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sortedAmount() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color.fromRGBO(18, 132, 233, 0.65)),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          children: [
            Image.asset(
              'assets/sortir_icon.png',
              height: 150,
              width: 150,
            ),
            Container(
              padding: EdgeInsets.all(13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color.fromRGBO(217, 217, 217, 1),
              ),
              child: Column(
                children: [
                  Text(
                    '10.000',
                    style: TextStyle(
                      fontFamily: GoogleFonts.inter().fontFamily,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'Barang disortir',
                    style: TextStyle(
                      fontFamily: GoogleFonts.inter().fontFamily,
                      fontSize: 24,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
