import 'package:flutter/material.dart';
import 'package:vitescopush/services/notifi_service.dart';
import 'package:vitescopush/services/MQTTClientManager.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MQTTClientManager mqttClientManager = MQTTClientManager();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    mqttClientManager.connect().then((value) {
      if (value == 0) {
        print('MQTTClient::Connected to the MQTT broker');
      } else {
        print('MQTTClient::Failed to connect to the MQTT broker');
      }
    });
  }

  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }

  void _showNotification(String message) {
    NotificationService().showNotification(
      title: 'New MQTT Message',
      body: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              mqttClientManager.publishMessage(
                'test/lol',
                'Hello from Flutter!',
              );
            },
            child: Text('Publish MQTT Message'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
