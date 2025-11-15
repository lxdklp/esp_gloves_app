import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({
    required this.device,
    super.key,
  });

  final BluetoothDevice device;

  @override
  ActionPageState createState() => ActionPageState();
}

class ActionPageState extends State<ActionPage> {
  static final Guid _targetCharacteristicUuid = Guid('847fb318-61b4-502e-aa5f-ee75a48e9c3b');

  BluetoothCharacteristic? _characteristic;
  String? _statusMessage = '正在发现动作特征...';
  String? _errorMessage;
  bool _isWriting = false;
  final TextEditingController _writeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _writeController.dispose();
    super.dispose();
  }

  // 初始化蓝牙连接和动作特征
  Future<void> _initialize() async {
    setState(() {
      _statusMessage = '正在发现动作特征...';
      _errorMessage = null;
    });
    try {
      final services = await widget.device.discoverServices();
      final characteristic = _locateCharacteristic(services);
      if (characteristic == null) {
        if (!mounted) return;
        setState(() {
          _statusMessage = null;
          _errorMessage = '未找到特征 ${_targetCharacteristicUuid.toString()}';
        });
        return;
      }
      _characteristic = characteristic;
      if (!mounted) return;
      setState(() {
        _statusMessage = null;
      });
      await _readValue();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = null;
        _errorMessage = '初始化动作页失败: $e';
      });
    }
  }

  // 定位目标特征
  BluetoothCharacteristic? _locateCharacteristic(List<BluetoothService> services) {
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.characteristicUuid == _targetCharacteristicUuid) {
          return characteristic;
        }
      }
    }
    return null;
  }

  // 读取特征值
  Future<void> _readValue() async {
    final characteristic = _characteristic;
    if (characteristic == null) {
      setState(() {
        _errorMessage = '动作特征尚未就绪';
      });
      return;
    }
    setState(() {
      _errorMessage = null;
    });
    try {
      final raw = await characteristic.read();
      final value = utf8.decode(raw, allowMalformed: true);
      if (!mounted) return;
      setState(() {
        _writeController.text = value;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '读取失败: $e';
      });
    }
  }

  // 写入特征值
  Future<void> _writeValue() async {
    final characteristic = _characteristic;
    if (characteristic == null) {
      setState(() {
        _errorMessage = '动作特征尚未就绪';
      });
      return;
    }
    final text = _writeController.text;
    setState(() {
      _isWriting = true;
      _errorMessage = null;
    });
    try {
      final payload = utf8.encode(text);
      await characteristic.write(payload, withoutResponse: false);
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '写入失败: $e';
      });
    } finally {
      setState(() {
        _isWriting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildStatus(message: _errorMessage!, isError: true);
    }
    if (_statusMessage != null) {
      return _buildStatus(message: _statusMessage!);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('写入新值:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _writeController,
            maxLines: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '输入要写入设备的 UTF-8 字符串',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isWriting ? null : _writeValue,
            icon: _isWriting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: const Text('写入设备'),
          ),
        ],
      ),
    );
  }

  // 构建状态消息组件
  Widget _buildStatus({required String message, bool isError = false}) {
    final color = isError ? Theme.of(context).colorScheme.error : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, style: TextStyle(color: color)),
      ),
    );
  }
}