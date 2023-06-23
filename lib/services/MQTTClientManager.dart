import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:vitescopush/services/notifi_service.dart';

class MQTTClientManager {
  MqttServerClient client =
      MqttServerClient.withPort('test.mosquitto.org', '', 1883);

  var pongCount = 0; // Pong counter

  Future<int> connect() async {
    client.logging(on: true);
    client.setProtocolV311();
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 2000;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    print('MQTTClient::Connecting to the MQTT broker...');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('MQTTClient::Client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('MQTTClient::Socket exception - $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTTClient::Connected to the MQTT broker');
    } else {
      print(
          'MQTTClient::ERROR Connection to MQTT broker failed - disconnecting');
      client.disconnect();
      return -1;
    }

    const topic = 'test/lol'; // Not a wildcard topic
    subscribe(topic);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(
          'MQTTClient::Message received - Topic: ${c[0].topic}, Payload: $pt');
      handleReceivedMessage(c[0].topic, pt);
    });

    return 0;
  }

  void disconnect() {
    client.disconnect();
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void onSubscribed(String topic) {
    print('MQTTClient::Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print('MQTTClient::Disconnected');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('MQTTClient::Disconnected callback is solicited, this is correct');
    } else {
      print(
          'MQTTClient::Disconnected callback is unsolicited or none, this is incorrect');
    }
    if (pongCount == 3) {
      print('MQTTClient::Pong count is correct');
    } else {
      print(
          'MQTTClient::Pong count is incorrect, expected 3, actual $pongCount');
    }
  }

  void onConnected() {
    print('MQTTClient::Connected');
  }

  void pong() {
    print('MQTTClient::Ping response received');
    pongCount++;
  }

  void handleReceivedMessage(String topic, String payload) {
    final notification = 'Topic: $topic, Payload: $payload';
    NotificationService().showNotification(
      title: 'New MQTT Message',
      body: notification,
    );
  }
}
