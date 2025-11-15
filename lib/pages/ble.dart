import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:esp_gloves/pages/ble/device.dart';

class BLEPage extends StatefulWidget {
  const BLEPage({super.key});

  @override
  BLEPageState createState() => BLEPageState();
}

class BLEPageState extends State<BLEPage> {
  // 过滤条件
  static const int targetManufacturerId = 0xFFFF; // 公司ID
  static const String targetDeviceName = "ESP Gloves"; // 设备名称
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  StreamSubscription? scanSubscription;
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  StreamSubscription? adapterStateSubscription;

  @override
  void initState() {
    super.initState();
    // 监听蓝牙适配器状态
    adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        adapterState = state;
      });
    });
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    adapterStateSubscription?.cancel();
    super.dispose();
  }

  // 开始扫描
  Future<void> startScan() async {
    if (adapterState != BluetoothAdapterState.on) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先打开蓝牙')),
      );
      return;
    }
    setState(() {
      scanResults.clear();
      isScanning = true;
    });
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
      );
      // 监听扫描结果
      scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        final filteredResults = results.where((result) {
          final manufacturerData = result.advertisementData.manufacturerData;
          if (!manufacturerData.containsKey(targetManufacturerId)) {
            return false;
          }
          final data = manufacturerData[targetManufacturerId];
          if (data == null || data.isEmpty) {
            return false;
          }
          try {
            final dataString = String.fromCharCodes(data);
            return dataString.contains(targetDeviceName);
          } catch (e) {
            return false;
          }
        }).toList();
        setState(() {
          scanResults = filteredResults;
        });
      });
      // 监听扫描状态
      FlutterBluePlus.isScanning.listen((scanning) {
        setState(() {
          isScanning = scanning;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('扫描错误: $e')),
      );
      setState(() {
        isScanning = false;
      });
    }
  }

  // 停止扫描
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  // 连接设备
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // 连接到设备
      await device.connect();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DevicesPage(device: device),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已连接到 ${device.platformName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('连接失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('蓝牙设备扫描'),
        actions: [
          // 蓝牙状态指示器
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              adapterState == BluetoothAdapterState.on
                  ? Icons.bluetooth
                  : Icons.bluetooth_disabled,
              color: adapterState == BluetoothAdapterState.on
                  ? Colors.blue
                  : Colors.grey,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('正在扫描目标设备...'),
                ],
              ),
            ),
          // 设备列表
          Expanded(
            child: scanResults.isEmpty
                ? Center(
                    child: Text(
                      isScanning ? '扫描中...' : '点击"开始扫描"以查找蓝牙设备',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: scanResults.length,
                    itemBuilder: (context, index) {
                      final result = scanResults[index];
                      final device = result.device;
                      final rssi = result.rssi;
                      final advName = result.advertisementData.advName;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            advName.isNotEmpty ? advName : device.platformName.isNotEmpty
                                ? device.platformName
                                : '未知设备',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('ID: ${device.remoteId}'),
                              const SizedBox(height: 2),
                              Text('信号强度: $rssi dBm'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.link),
                            onPressed: () => connectToDevice(device),
                            tooltip: '连接设备',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isScanning ? stopScan : startScan,
        tooltip: isScanning ? '停止扫描' : '开始扫描',
        child: Icon(isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}