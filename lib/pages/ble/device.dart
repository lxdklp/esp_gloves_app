import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:esp_gloves/pages/ble/device/sensor.dart';
import 'package:esp_gloves/pages/ble/device/action.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({
    required this.device,
    super.key,
  });

  final BluetoothDevice device;

  @override
  DevicesPageState createState() => DevicesPageState();
}

class DevicesPageState extends State<DevicesPage> with SingleTickerProviderStateMixin{
  final tabs = [
    const Tab(text: '传感器'),
    const Tab(text: '快捷动作'),
  ];
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('已连接到 ${widget.device.platformName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SensorPage(device: widget.device),
          ActionPage(device: widget.device),
        ],
      )
    );
  }
}