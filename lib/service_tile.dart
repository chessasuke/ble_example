import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'utils.dart';

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
            Text(
              service.uuid.toString().guidNum,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(color: Theme.of(context).textTheme.caption?.color),
            )
          ],
        ),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: const Text('Service'),
        subtitle: Text(service.uuid.toString().guidNum),
      );
    }
  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  const CharacteristicTile({
    Key? key,
    required this.characteristic,
  }) : super(key: key);

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
            leading: Column(
              children: [
                Text(
                    'Characteristic - ${characteristic.uuid.toString().guidNum}'),
                Text('lastValue: ${value.toString()}')
              ],
            ),
            contentPadding: const EdgeInsets.all(0.0),
          ),
          children: <Widget>[
            if (characteristic.properties.read)
              CharacteristicProperty(
                property: Property.read,
                operation: () async =>
                    await getOperation(context, Property.read),
              ),
            if (characteristic.properties.write)
              CharacteristicProperty(
                property: Property.write,
                operation: () async =>
                    await getOperation(context, Property.write),
              ),
            if (characteristic.properties.writeWithoutResponse)
              CharacteristicProperty(
                property: Property.writeWithOutResponse,
                operation: () async =>
                    await getOperation(context, Property.writeWithOutResponse),
              ),
            if (characteristic.properties.notify ||
                characteristic.properties.indicate)
              CharacteristicProperty(
                isNotifying: characteristic.isNotifying,
                property: Property.notify,
                operation: () async => await getOperation(context, Property.notify),
              ),
          ],
        );
      },
    );
  }

  Future<void> getOperation(BuildContext context, Property property) async {
    switch (property) {
      case Property.read:
        try {
          final bytes = await characteristic.read();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(bytes.toString())));
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
        break;
      case Property.write:
        try {
          characteristic.write([9]);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Sent 9!')));
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
        break;

      case Property.writeWithOutResponse:
        try {
          characteristic.write([9]);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Sent 9!')));
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
        break;
      case Property.notify:
      case Property.indicate:
        try {
          final value =
              await characteristic.setNotifyValue(!characteristic.isNotifying);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Is notifying: $value')));
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
    }
  }
}

enum Property {
  read,
  write,
  writeWithOutResponse,
  notify,
  indicate;

  IconData getIcon() {
    switch (this) {
      case Property.read:
        return Icons.file_download;
      case Property.write:
        return Icons.file_upload;
      case Property.writeWithOutResponse:
        return Icons.file_upload;
      case Property.notify:
        return Icons.notification_important;
      case Property.indicate:
        return Icons.notifications_active;
    }
  }
}

class CharacteristicProperty extends StatelessWidget {
  const CharacteristicProperty({
    required this.property,
    required this.operation,
    this.isNotifying,
    Key? key,
  }) : super(key: key);

  final Property property;
  final bool? isNotifying;
  final VoidCallback operation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: property != Property.notify && property != Property.indicate
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  property.name.toUpperCase(),
                  overflow: TextOverflow.clip,
                ),
                IconButton(
                  icon: Icon(property.getIcon()),
                  onPressed: operation,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  property.name.toUpperCase(),
                  overflow: TextOverflow.clip,
                ),
                Text(isNotifying! ? 'Notifying' : 'Not Notifying'),
                IconButton(
                  icon: Icon(property.getIcon()),
                  onPressed: operation,
                )
              ],
            ),
    );
  }
}
