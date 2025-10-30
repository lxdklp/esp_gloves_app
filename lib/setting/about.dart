import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {

  String _appVersion = "unknown";

  Future<void> _loadAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    setState(() {
      _appVersion = appVersion;
    });
  }

  // 打开URL
  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法打开链接: $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发生错误: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '\n本项目使用GPL3.0协议开源,使用过程中请遵守GPL3.0协议\n',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Image.asset(
                            'assets/img/logo/flutter.png',
                            height: 150,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'esp gloves $_appVersion',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Copyright © 2025 lxdklp. All rights reserved\n',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: const Text('官网'),
              subtitle: const Text('https://esp_gloves.lxdklp.top'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://esp_gloves.lxdklp.top'),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: const Text('Github'),
              subtitle: const Text('https://github.com/lxdklp/esp_gloves_app'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://github.com/lxdklp/esp_gloves_app'),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: const Text('BUG反馈与APP建议'),
              subtitle: const Text('https://github.com/lxdklp/esp_gloves_app/issues'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchURL('https://github.com/lxdklp/esp_gloves_app/issues'),
            ),
          ),
          Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('许可'),
                subtitle: Text('感谢各位依赖库的贡献者'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => showLicensePage(context: context)
              ),
            ),
        ],
      ),
    );
  }
}