import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({
    required this.device,
    super.key,
  });

  final BluetoothDevice device;

  @override
  SensorPageState createState() => SensorPageState();
}

class SensorPageState extends State<SensorPage> {
  static final Guid _serviceUuid = Guid('11451419-1981-0114-5141-919810114514');
  static final Guid _characteristicUuid = Guid('736fa207-50a3-401d-994e-dd64937d8c2a');

  BluetoothCharacteristic? _characteristic;
  StreamSubscription<List<int>>? _notifySub;
  List<int>? _rawBytes;
  List<double> _parsedValues = const <double>[];
  String? _statusMessage = '正在连接传感器...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _notifySub?.cancel();
    if (_characteristic != null && _characteristic!.isNotifying) {
      unawaited(_characteristic!.setNotifyValue(false));
    }
    super.dispose();
  }

  // 初始化蓝牙连接和数据订阅
  Future<void> _initialize() async {
    setState(() {
      _statusMessage = '正在发现服务...';
      _errorMessage = null;
    });
    try {
      final services = await widget.device.discoverServices();
      final service = _findService(services);
      if (service == null) {
        if (!mounted) return;
        setState(() {
          _statusMessage = null;
          _errorMessage = '未找到匹配的服务 (${_serviceUuid.toString()})';
        });
        return;
      }
      final characteristic = _findCharacteristic(service);
      if (characteristic == null) {
        if (!mounted) return;
        setState(() {
          _statusMessage = null;
          _errorMessage = '未找到匹配的特征 (${_characteristicUuid.toString()})';
        });
        return;
      }
      _characteristic = characteristic;
      final initialValue = await characteristic.read();
      _handleIncoming(initialValue);
      await characteristic.setNotifyValue(true);
      _notifySub = characteristic.lastValueStream.listen(
        _handleIncoming,
        onError: (Object error, StackTrace stackTrace) {
          if (!mounted) return;
          setState(() {
            _errorMessage = '通知接收失败: $error';
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _statusMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = null;
        _errorMessage = '读取传感器失败: $e';
      });
    }
  }

  // 查找指定服务
  BluetoothService? _findService(List<BluetoothService> services) {
    for (final service in services) {
      if (service.serviceUuid == _serviceUuid) {
        return service;
      }
    }
    return null;
  }

  // 查找指定特征
  BluetoothCharacteristic? _findCharacteristic(BluetoothService service) {
    for (final characteristic in service.characteristics) {
      if (characteristic.characteristicUuid == _characteristicUuid) {
        return characteristic;
      }
    }
    return null;
  }

  // 处理接收到的数据
  Future<void> _handleIncoming(List<int> data) async{
    if (!mounted) {
      return;
    }
    if (data.length != 56) {
      setState(() {
        _statusMessage = null;
        _errorMessage = '收到的数据长度不符 (${data.length} 字节，需 56 字节)';
      });
      return;
    }
    final bytes = Uint8List.fromList(data);
    final buffer = ByteData.sublistView(bytes);
    final values = List<double>.generate(
      14,
      (index) => buffer.getFloat32(index * 4, Endian.little),
    );
    setState(() {
      _statusMessage = null;
      _errorMessage = null;
      _rawBytes = data;
      _parsedValues = values;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildMessage(_errorMessage!, isError: true);
    }
    if (_statusMessage != null) {
      return _buildMessage(_statusMessage!);
    }
    if (_parsedValues.isEmpty) {
      return _buildMessage('等待传感器数据...');
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildValueTile(),
          const SizedBox(height: 16),
          _buildRawSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 构建状态消息组件
  Widget _buildMessage(String message, {bool isError = false}) {
    final color = isError ? Theme.of(context).colorScheme.error : null;
    return Center(
      child: Text(
        message,
        style: TextStyle(color: color),
      ),
    );
  }

  // 构建传感器数值展示组件
  Widget _buildValueTile() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListTile(
          title: const Text('传感器1'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _parsedValues.map((value) {
              return Text('值 ${_parsedValues.indexOf(value) + 1}: ${value.toStringAsFixed(3)}');
            }).toList(),
          ),
        ),
      ),
    );
  }

  // 构建原始数据展示组件
  Widget _buildRawSection() {
    if (_rawBytes == null) {
      return const SizedBox.shrink();
    }
    final hexString = _rawBytes!
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(' ')
        .toUpperCase();
    final floatString = _parsedValues
        .map((value) => value.toStringAsFixed(3))
        .join(', ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('原始数据'),
            const SizedBox(height: 8),
            Text(hexString),
            const SizedBox(height: 8),
            Text('浮点值：$floatString'),
          ],
        ),
      ),
    );
  }
}