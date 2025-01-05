import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Control extends StatefulWidget {
  const Control({
    required this.connection,
    required this.deviceConnected,
    required this.bluetooth,
    super.key,
  });

  final BluetoothConnection connection;
  final BluetoothDevice deviceConnected;
  final FlutterBluetoothSerial bluetooth;

  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> {
  String currentColor = 'Tidak ada';
  int sortedRed = 0;
  int sortedGreen = 0;
  int sortedBlue = 0;

  late DateFormat dateFormat;

  bool isManual = false;
  bool isGrab = false;
  String receivedData = '';
  int times = 0;
  String buffer = '';

  @override
  void initState() {
    dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    initializeDateFormatting();
    _startReceivingData();
    super.initState();
  }

  void _startReceivingData() {
    print('start receiving data');
    widget.connection.input!.listen(
      (event) {
        buffer += String.fromCharCodes(event);
        print('####### $buffer');
        if (buffer.contains('\n')) {
          _processReceivedData(buffer.trim());
          buffer = '';
        }
        // buffer = String.fromCharCodes(event).trim();
        // _processReceivedData(buffer);
      },
      onDone: () {
        print('Bluetooth connection closed.');
      },
      onError: (error) {
        print('Error receiving data: $error');
      },
      cancelOnError: true,
    );
  }

  void _processReceivedData(String data) {
    print('start processing data');
    // Pisahkan string berdasarkan delimiter '#'
    List<String> parts = data.split('#');
    if (parts.length == 4) {
      setState(() {
        currentColor = parts[0];
        sortedRed = int.tryParse(parts[1]) ?? 1;
        sortedGreen = int.tryParse(parts[2]) ?? 1;
        sortedBlue = int.tryParse(parts[3]) ?? 1;
      });

      if (kDebugMode) {
        print(
            'Color: $currentColor, Value1: $sortedRed, Value2: $sortedGreen, Value3: $sortedBlue');
      }
    } else {
      if (kDebugMode) {
        print('Format data tidak sesuai: $data');
      }
    }
  }

  void _sendData(String data) async {
    if (!(widget.connection.isConnected)) {
      if (kDebugMode) {
        print('Bluetooth belum terhubung.');
      }
      return;
    }
    try {
      widget.connection.output.add(ascii.encode(data));
      await widget.connection.output.allSent;
      if (kDebugMode) {
        print('Data sent: $data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Gagal mengirim data: $e');
      }
    }
  }

  void _handleModeChange(bool value) {
    setState(() {
      isManual = value;
      if (isManual) {
        _sendData('M');
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
      } else {
        _sendData('A');
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

        // Mulai kembali menerima data jika beralih ke mode otomatis
        // _startReceivingData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var dateTime = DateTime.now();
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
          toolbarHeight: isManual ? 24 : 50,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ZonaSort',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dateFormat.format(dateTime),
                style: const TextStyle(
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
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 7,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color.fromRGBO(18, 132, 233, 0.65),
                      ),
                      width: isManual ? size.width * 0.5 : size.width * 0.9,
                      height: isManual ? size.height * 0.15 : size.height * 0.1,
                      child: SwitchListTile(
                        // activeColor: Color.fromRGBO(48, 23, 242, 1),
                        value: isManual,
                        onChanged: _handleModeChange,
                        // tileColor: Colors.green,
                        title: Row(
                          children: [
                            Image.asset(
                              'assets/controller.png',
                              height: isManual ? 35 : 70,
                              // width: 70,
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              isManual ? "Mode Manual" : "Mode Otomatis",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    // _inputSerial(),
                    isManual ? pressButton() : sortedAmount(),
                  ],
                ),
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
        // height: size.height * 0.7,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 30,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(36, 51, 44, 71),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'RODA',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => _sendData('F'),
                  icon: Image.asset(
                    'assets/up.png',
                    height: 60,
                    width: 60,
                    color: const Color.fromRGBO(4, 42, 27, 1),
                  ),
                ),
                // const SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => _sendData('L'),
                      icon: Image.asset(
                        'assets/left.png',
                        height: 60,
                        width: 60,
                        color: const Color.fromRGBO(4, 42, 27, 1),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _sendData('S'),
                      icon: const Icon(
                        Icons.pause,
                        size: 70,
                        color: Color.fromRGBO(4, 42, 27, 1),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _sendData('R'),
                      icon: Image.asset(
                        'assets/right.png',
                        height: 60,
                        width: 60,
                        color: const Color.fromRGBO(4, 42, 27, 1),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _sendData('B'),
                  icon: Image.asset(
                    'assets/down.png',
                    height: 60,
                    width: 60,
                    color: const Color.fromRGBO(4, 42, 27, 1),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 30,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(36, 51, 44, 71),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Tangan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                IconButton(
                  onPressed: () => _sendData('1'),
                  icon: Image.asset(
                    'assets/up.png',
                    height: 60,
                    width: 60,
                    color: const Color.fromRGBO(4, 42, 27, 1),
                  ),
                ),
                // const SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => _sendData('2'),
                      icon: Image.asset(
                        'assets/left.png',
                        height: 60,
                        width: 60,
                        color: const Color.fromRGBO(4, 42, 27, 1),
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () => _sendData('5'),
                    //   icon: const Icon(
                    //     Icons.pause,
                    //     size: 70,
                    //     color: Color.fromRGBO(4, 42, 27, 1),
                    //   ),
                    // ),
                    IconButton(
                      onPressed: () {
                        _sendData(isGrab ? '5' : '6');
                        isGrab = !isGrab;
                      },
                      icon: Container(
                        height: 30,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(36, 51, 44, 71),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'CAPIT',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () => _sendData('3'),
                      icon: Image.asset(
                        'assets/right.png',
                        height: 60,
                        width: 60,
                        color: const Color.fromRGBO(4, 42, 27, 1),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _sendData('4'),
                  icon: Image.asset(
                    'assets/down.png',
                    height: 60,
                    width: 60,
                    color: const Color.fromRGBO(4, 42, 27, 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget sortedAmount() {
    // _startReceivingData();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          buildSortedCard(
            color: currentColor == 'Merah'
                ? Colors.red
                : currentColor == 'Biru'
                    ? Colors.blue
                    : currentColor == 'Hijau'
                        ? Colors.green
                        : null,
            title: 'Warna saat ini',
            value: currentColor,
          ),
          buildSortedCard(
            color: Colors.red,
            title: 'Merah yang telah disortir',
            value: '$sortedRed',
          ),
          buildSortedCard(
            color: Colors.green,
            title: 'Hijau yang telah disortir',
            value: '$sortedGreen',
          ),
          buildSortedCard(
            color: Colors.blue,
            title: 'Biru yang telah disortir',
            value: '$sortedBlue',
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  Widget buildSortedCard({
    required Color? color,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color.fromRGBO(18, 132, 233, 0.65),
      ),
      width: 250, // Tetapkan ukuran lebar yang lebih kecil
      height: 300, // Tetapkan tinggi tetap
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/sortir_icon.png',
            color: color,
            height: 150,
            width: 150,
          ),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color.fromRGBO(147, 207, 249, 0.71),
            ),
            child: Text(
              '$title\n$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: GoogleFonts.inter().fontFamily,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
