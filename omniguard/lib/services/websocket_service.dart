import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {

  late WebSocketChannel channel;

  WebSocketService() {

    channel = WebSocketChannel.connect(
      Uri.parse(
        "ws://127.0.0.1:8000/ws/anomalies",
      ),
    );
  }

  Stream<Map<String, dynamic>> get stream {

  return channel.stream.map((event) {

    print("WS EVENT => $event");

    if (event is String) {
      return jsonDecode(event);
    }

    return Map<String, dynamic>.from(event);
  });
}

  void dispose() {
    channel.sink.close();
  }
}