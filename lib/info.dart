import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esp_gloves/function/log.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  InfoPageState createState() => InfoPageState();
}

class InfoPageState extends State<InfoPage> {
  bool _hasIP = false;
  bool _isConnected = false;
  String _ip = '';
  List<dynamic> sensorData1 = ['', '', '', ''];
  List<dynamic> sensorData2 = ['', '', '', ''];
  List<dynamic> sensorData3 = ['', '', '', ''];
  List<dynamic> sensorData4 = ['', '', '', ''];
  List<dynamic> sensorData5 = ['', '', '', ''];

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
        _getsensorData(1);
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
  Future<void> _getsensorData(id) async {
    try {
      final Dio dio = Dio();
      final response = await dio.get('http://$_ip:5000/v1/Info/$id');
      if (response.statusCode == 200) {
        LogUtil.log('获取$id手指数据成功');
        final data = response.data;
        LogUtil.log('手指$id数据: $data');
        if (id == 1) {
          setState(() {
            sensorData1 = data;
          });
        }if (id == 2) {
          setState(() {
            sensorData2 = data;
          });
        }if (id == 3) {
          setState(() {
            sensorData3 = data;
          });
        }if (id == 4) {
          setState(() {
            sensorData4 = data;
          });
        }if (id == 5) {
          setState(() {
            sensorData5 = data;
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
                title: Text('当前动作'),
                subtitle: Text('test'),
              )
            ),Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('手指1'),
                subtitle: Text('id: ${sensorData1[0].toString()} 加速度: ${sensorData1[1].toString()} 角速度: ${sensorData1[2].toString()} 角度: ${sensorData1[3].toString()}'),
              )
            ),Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('手指2'),
                subtitle: Text('id: ${sensorData2[0].toString()} 加速度: ${sensorData2[1].toString()} 角速度: ${sensorData2[2].toString()} 角度: ${sensorData2[3].toString()}'),
              )
            ),Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('手指3'),
                subtitle: Text('id: ${sensorData3[0].toString()} 加速度: ${sensorData3[1].toString()} 角速度: ${sensorData3[2].toString()} 角度: ${sensorData3[3].toString()}'),
              )
            ),Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('手指4'),
                subtitle: Text('id: ${sensorData4[0].toString()} 加速度: ${sensorData4[1].toString()} 角速度: ${sensorData4[2].toString()} 角度: ${sensorData4[3].toString()}'),
              )
            ),Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('手指5'),
                subtitle: Text('id: ${sensorData5[0].toString()} 加速度: ${sensorData5[1].toString()} 角速度: ${sensorData5[2].toString()} 角度: ${sensorData5[3].toString()}'),
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