import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/token_manager.dart';
import '../models/ws_message_model.dart';

@injectable
class ChatWsDataSource {
  final TokenManager _tokenManager;

  WebSocketChannel? _channel;
  StreamController<WsOutgoingMessage>? _messageController;
  StreamSubscription? _channelSubscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _intentionalClose = false;

  ChatWsDataSource(this._tokenManager);

  Stream<WsOutgoingMessage> get messageStream {
    _messageController ??= StreamController<WsOutgoingMessage>.broadcast();
    return _messageController!.stream;
  }

  bool get isConnected => _channel != null;

  Future<void> connect() async {
    if (_channel != null) return;

    _intentionalClose = false;
    _messageController ??= StreamController<WsOutgoingMessage>.broadcast();

    try {
      final token = await _tokenManager.getValidAccessToken();
      final uri = Uri.parse('${ApiConstants.wsUrl}?token=$token');

      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _channelSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      _reconnectAttempts = 0;
      _startPingTimer();

      if (kDebugMode) {
        debugPrint('[WS] Connected to ${ApiConstants.wsUrl}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WS] Connection failed: $e');
      }
      _scheduleReconnect();
    }
  }

  void sendMessage(WsIncomingMessage message) {
    if (_channel == null) return;
    final json = jsonEncode(message.toJson());
    _channel!.sink.add(json);
    if (kDebugMode) {
      debugPrint('[WS] Sent: $json');
    }
  }

  void sendChatMessage({
    required String conversationId,
    required String content,
    String contentType = 'text',
  }) {
    sendMessage(WsIncomingMessage.chatMessage(
      conversationId: conversationId,
      content: content,
      contentType: contentType,
    ));
  }

  void sendPing() {
    sendMessage(WsIncomingMessage.ping());
  }

  Future<void> disconnect() async {
    _intentionalClose = true;
    _stopPingTimer();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _channelSubscription?.cancel();
    _channelSubscription = null;

    await _channel?.sink.close();
    _channel = null;

    if (kDebugMode) {
      debugPrint('[WS] Disconnected');
    }
  }

  void dispose() {
    disconnect();
    _messageController?.close();
    _messageController = null;
  }

  void _onMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final message = WsOutgoingMessage.fromJson(json);

      if (kDebugMode) {
        debugPrint('[WS] Received: ${message.type}');
      }

      _messageController?.add(message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WS] Parse error: $e');
      }
    }
  }

  void _onError(Object error) {
    if (kDebugMode) {
      debugPrint('[WS] Error: $error');
    }
    _cleanup();
    _scheduleReconnect();
  }

  void _onDone() {
    if (kDebugMode) {
      debugPrint('[WS] Connection closed');
    }
    _cleanup();
    if (!_intentionalClose) {
      _scheduleReconnect();
    }
  }

  void _cleanup() {
    _stopPingTimer();
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel = null;
  }

  void _scheduleReconnect() {
    if (_intentionalClose) return;
    if (_reconnectAttempts >= AppConstants.wsMaxReconnectAttempts) {
      if (kDebugMode) {
        debugPrint('[WS] Max reconnect attempts reached');
      }
      return;
    }

    final delay = Duration(
      milliseconds: AppConstants.wsReconnectBaseDelay.inMilliseconds *
          pow(2, _reconnectAttempts).toInt(),
    );

    if (kDebugMode) {
      debugPrint(
        '[WS] Reconnecting in ${delay.inSeconds}s '
        '(attempt ${_reconnectAttempts + 1}/${AppConstants.wsMaxReconnectAttempts})',
      );
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(AppConstants.wsPingInterval, (_) {
      sendPing();
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }
}
