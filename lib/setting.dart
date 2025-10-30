import 'package:flutter/material.dart';
import 'package:esp_gloves/setting/theme.dart';
import 'package:esp_gloves/setting/connect.dart';
import 'package:esp_gloves/setting/log_viewer.dart';
import 'package:esp_gloves/setting/about.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APP设置'),
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('\n主题设置\n'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThemePage()),
              );
            },
          ),
          ),Card(
            child: ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('\n连接设置\n'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConnectPage()),
              );
            },
          ),
          ),Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('\n日志查看\n'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogViewerPage()),
              );
            },
          ),
          ),Card(
            child: ListTile(
              leading: Icon(Icons.info),
              title: const Text('\n关于\n'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          )
        ],
      ),
    );
  }
}