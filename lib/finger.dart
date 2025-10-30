import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esp_gloves/function/log.dart';

class FingerPage extends StatefulWidget {
  const FingerPage({super.key});

  @override
  FingerPageState createState() => FingerPageState();
}

class FingerPageState extends State<FingerPage> {
  bool _hasIP = false;
  bool _isConnected = false;
  String _ip = '';
  List<dynamic> fingerData1 = ['', '', '', ''];

  // 获取配置
  Future<void> _getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('ip') ?? '';
    if (ip.isEmpty) {
      LogUtil.log('请先配置IP地址');
      setState(() {
        _hasIP = false;
      });
      return;
    }
    setState(() {
      _hasIP = true;
      _ip = ip;
    });
    _checkConnection();
  }

  // 连接检查
  Future<void> _checkConnection() async {
    try {
      final Dio dio = Dio();
      final response = await dio.get('http://$_ip:5000/v1/status');
      if (response.statusCode == 200) {
        LogUtil.log('连接成功');
        _getFingerData(1);
        setState(() {
          _isConnected = true;
        });
      } else {
        LogUtil.log('连接失败');
      }
    } catch (e) {
      LogUtil.log('连接失败: $e');
    }
  }

  // 获取手指数据
  Future<void> _getFingerData(id) async {
    try {
      final Dio dio = Dio();
      final response = await dio.get('http://$_ip:5000/v1/finger/$id');
      if (response.statusCode == 200) {
        LogUtil.log('获取$id手指数据成功');
        final data = response.data;
        LogUtil.log('手指$id数据: $data');
        if (id == 1) {
          setState(() {
            fingerData1 = data;
          });
        }
      } else {
        LogUtil.log('获取$id手指数据失败');
      }
    } catch (e) {
      LogUtil.log('获取$id手指数据失败: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Column(
        children: [
          if (_hasIP)
            if (_isConnected)  ... [
              Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                    '已连接',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ))
              )
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('手指1'),
                subtitle: Text('id: ${fingerData1[0].toString()} 加速度: ${fingerData1[1].toString()} 角速度: ${fingerData1[2].toString()} 角度: ${fingerData1[3].toString()}'),
              )
            ),
            ]
            else
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      '\n无法连接,请检查日志\n',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                )
            )
          else
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    '\n请前往设置配置IP地址\n',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              )
            )
        ],
      )
    );
  }
}