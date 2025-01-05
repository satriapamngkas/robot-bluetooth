import 'dart:convert';
import 'package:flutter_application/pages/control.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateFormat dateFormat;

  final _bluetooth = FlutterBluetoothSerial.instance;
  bool _bluetoothState = false;
  bool _isConnecting = false;
  // bool _isConnected = false;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _deviceConnected;
  int times = 0;

  void _getDevices() async {
    var res = await _bluetooth.getBondedDevices();
    setState(() => _devices = res);
  }

  // void _receiveData() {
  //   _connection?.input?.listen((event) {
  //     if (String.fromCharCodes(event) == "p") {
  //       setState(() => times = times + 1);
  //     }
  //   });
  // }

  void _sendData(String data) {
    if (_connection?.isConnected ?? false) {
      _connection?.output.add(ascii.encode(data));
    }
  }

  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  @override
  void initState() {
    super.initState();
    dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    // initializeDateFormatting();

    _requestPermission();

    _bluetooth.state.then((state) {
      setState(() => _bluetoothState = state.isEnabled);
    });

    _bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BluetoothState.STATE_OFF:
          setState(() => _bluetoothState = false);
          break;
        case BluetoothState.STATE_ON:
          setState(() => _bluetoothState = true);
          break;
        // case BluetoothState.STATE_TURNING_OFF:
        //   break;
        // case BluetoothState.STATE_TURNING_ON:
        //   break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  !_bluetoothState
                      ? _controlBT()
                      : Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            _infoDevice(),
                            const SizedBox(
                              height: 20,
                            ),
                            SafeArea(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: const Color.fromRGBO(
                                        18, 132, 233, 0.65)),
                                width: MediaQuery.of(context).size.width * 0.9,
                                // height: MediaQuery.of(context).size.height * 0.1,
                                child: _listDevices(),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _controlBT() {
    return IconButton(
      onPressed: () {
        setState(() async {
          await _bluetooth.requestEnable();
        });
      },
      icon: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color.fromRGBO(18, 132, 233, 0.90),
          ),
          width: MediaQuery.of(context).size.width * 0.6,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(0, 82, 246, 1),
                ),
                child: const Icon(
                  Icons.bluetooth,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Nyalakan\nBluetooth!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              )
            ],
          )
          // child: SwitchListTile(
          //   // activeColor: Color.fromRGBO(48, 23, 242, 1),
          //   value: _bluetoothState,
          //   onChanged: (bool value) async {
          //     if (value) {
          //       await _bluetooth.requestEnable();
          //     } else {
          //       await _bluetooth.requestDisable();
          //     }
          //   },
          //   // tileColor: Colors.green,
          //   title: Text(
          //     _bluetoothState ? "Bluetooth aktif" : "Bluetooth mati",
          //     style: const TextStyle(color: Colors.white),
          //   ),
          // ),
          ),
    );
  }

  Widget _infoDevice() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color.fromRGBO(18, 132, 233, 0.94)),
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListTile(
        tileColor: Colors.black12,
        title: Text(
          "Device: ${_deviceConnected?.name ?? "Belum terhubung"}",
          style: const TextStyle(color: Colors.white),
        ),
        trailing: _connection?.isConnected ?? false
            ? TextButton(
                onPressed: () async {
                  // await _connection?.finish();
                  // setState(() => _deviceConnected = null);
                  Navigator.pushReplacement<void, void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => Control(
                        deviceConnected: _deviceConnected!,
                        bluetooth: _bluetooth,
                        connection: _connection!,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Control",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : TextButton(
                onPressed: _getDevices,
                child: const Text(
                  "Detect Device",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }

  Widget _listDevices() {
    return _isConnecting
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Container(
              color: const Color.fromRGBO(30, 144, 243, 94),
              child: Column(
                children: [
                  ...[
                    for (final device in _devices)
                      ListTile(
                        title: Text(
                          device.name ?? device.address,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: TextButton(
                          child: const Text(
                            'Hubungkan',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            setState(() => _isConnecting = true);

                            final connection =
                                await BluetoothConnection.toAddress(
                                    device.address);
                            _deviceConnected = device;
                            _devices = [];
                            // _isConnecting = false;

                            setState(() {
                              _connection = connection;
                              // _isConnected = connection.isConnected;
                              _isConnecting = false;
                            });

                            // _receiveData();

                            // setState(() {
                            //   _isConnecting = false;
                            //   Navigator.pushReplacement<void, void>(
                            //     context,
                            //     MaterialPageRoute<void>(
                            //       builder: (BuildContext context) =>
                            //           const Control(),
                            //     ),
                            //   );
                            // });
                          },
                        ),
                      )
                  ]
                ],
              ),
            ),
          );
  }

  Widget _inputSerial() {
    return ListTile(
      trailing: TextButton(
        child: const Text('Reload'),
        onPressed: () => setState(() => times = 0),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "Tekan Button (x$times)",
          style: const TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
