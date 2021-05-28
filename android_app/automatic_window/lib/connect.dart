import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ir_sensor_plugin/ir_sensor_plugin.dart';

class SendSignal extends StatefulWidget {
  @override
  _SendSignalState createState() => _SendSignalState();
}

class _SendSignalState extends State<SendSignal> {
  String _platformVersion = 'Unknown';
  bool _hasIrEmitter = false;
  String _getCarrierFrequencies = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    bool hasIrEmitter;
    String getCarrierFrequencies;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await IrSensorPlugin.platformVersion;
      hasIrEmitter = await IrSensorPlugin.hasIrEmitter;
      getCarrierFrequencies = await IrSensorPlugin.getCarrierFrequencies;
    } on PlatformException {
      platformVersion = 'Failed to get data in a platform.';
      hasIrEmitter = false;
      getCarrierFrequencies = 'None';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _hasIrEmitter = hasIrEmitter;
      _getCarrierFrequencies = getCarrierFrequencies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automatic Window'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/close.png",
                width: 50, fit: BoxFit.fitHeight),
            SizedBox(
              height: 15.0,
            ),
            FormSpecificCode(),
            Text('Running on: $_platformVersion\n'),
            Text('Has Ir Emitter: $_hasIrEmitter\n'),
            Text('IR Carrier Frequencies:$_getCarrierFrequencies'),
          ],
        ),
      ),
    );
  }
}

class FormSpecificCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          ElevatedButton(
              child: Text("Open"),
              onPressed: () async {
                final String result =
                    await IrSensorPlugin.transmitString(pattern: "1111");
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Opened')));
              }),
          Spacer(),
          ElevatedButton(
              child: Text("Close"),
              onPressed: () async {
                final String result =
                    await IrSensorPlugin.transmitString(pattern: "0000");
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Closed')));
              }),
        ],
      ),
      Container(
        height: 15.0,
      ),
    ]);
  }
}
