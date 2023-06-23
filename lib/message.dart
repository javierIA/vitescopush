import 'package:mqtt_client/mqtt_client.dart' as mqtt;

class Messages {
  final String topic;
  final String message;
  final mqtt.MqttQos qos;

  Messages({required this.topic, required this.message, required this.qos});
}
