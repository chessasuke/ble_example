import 'dart:math';

import 'package:ble_example/scan_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile(
      {Key? key, required this.service, required this.characteristicTiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.isNotEmpty) {
      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Service'),
            Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: Theme.of(context).textTheme.caption?.color))
          ],
        ),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: const Text('Service'),
        subtitle:
            Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'),
      );
    }
  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final Future<void> Function(BluetoothCharacteristic, BuildContext)?
      onReadPressed;
  final void Function(BuildContext)? onWritePressed;
  final VoidCallback? onNotificationPressed;

  const CharacteristicTile(
      {Key? key,
      required this.characteristic,
      required this.descriptorTiles,
      this.onReadPressed,
      this.onWritePressed,
      this.onNotificationPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<int> _getRandomBytes() {
      final math = Random();
      return [
        math.nextInt(255),
        math.nextInt(255),
        math.nextInt(255),
        math.nextInt(255)
      ];
    }

    return StreamBuilder<List<int>>(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        return ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Characteristic'),
                Text(
                    '0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}',
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Theme.of(context).textTheme.caption?.color))
              ],
            ),
            subtitle: Text('lastValue: ${value.toString()}'),
            contentPadding: const EdgeInsets.all(0.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.file_download,
                  color: Colors.red,
                ),
                onPressed: () async {
                  try {
                    final readBytes = await characteristic.read();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(readBytes.toString())));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(' ERROR: ${e.toString()}')));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.file_upload, color: Colors.blue),
                onPressed: () async {
                  try {
                    print(' --- onWritePressed');
                    await characteristic.write([9]);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('onWritePressed, sent: [9]')));
                  } catch (e) {
                    print(' --- error: ${e.toString()}');

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(' ERROR: ${e.toString()}')));
                  }
                },
              ),
              IconButton(
                icon: Icon(
                    characteristic.isNotifying
                        ? Icons.sync_disabled
                        : Icons.sync,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                onPressed: () async {
                  await characteristic
                      .setNotifyValue(!characteristic.isNotifying);
                  await characteristic.read();
                },
              )
            ],
          ),
          children: descriptorTiles,
        );
      },
    );
  }
}
