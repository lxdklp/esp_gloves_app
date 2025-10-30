import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  ConnectPageState createState() => ConnectPageState();
}

class ConnectPageState extends State<ConnectPage> {
  final TextEditingController _ipController = TextEditingController();

  // 获取配置
  Future<void> _getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('ip') ?? '';
    setState(() {
      _ipController.text = ip;
    });
  }

  // 保存配置
  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', _ipController.text);
    }

  @override
  void initState() {
    super.initState();
    _getConfig();
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('连接设备'),
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP地址',
                hintText: 'esp32 的IP地址',
                border: OutlineInputBorder()
              ),
            ),
          ),
        ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveConfig,
        child: const Icon(Icons.save)
      ),
    );
  }
}