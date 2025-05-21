import 'dart:async';
import 'package:app/config/app_config.dart';
import 'package:app/imports.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  IO.Socket? _socket;
  final _isConnected = false.obs; // Nouvelle propriété RxBool

  final _borrowRequestSubject = BehaviorSubject<dynamic>();
  final _demandSubject = BehaviorSubject<dynamic>();
  final _reviewSubject = BehaviorSubject<dynamic>();

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  final String _wsUrl;

  SocketService({bool isPhysicalDevice = false})
    : _wsUrl =
          isPhysicalDevice
              ? AppConfig.SocketwsUrlPhysical
              : AppConfig.SocketUrlEmulator;

  // Getter pour l'état de connexion
  bool get isConnected => _isConnected.value;
  Stream<bool> get connectionStatus => _isConnected.stream;

  void connect() {
    _connect();
  }

  void _connect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        print(
          ' SocketService: Nombre max de tentatives atteint ($_maxReconnectAttempts)',
        );
      }
      return;
    }

    if (kDebugMode) {
      print(
        ' SocketService: Connexion à $_wsUrl (tentative ${_reconnectAttempts + 1})',
      );
    }

    try {
      _socket = IO.io(
        _wsUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        _reconnectAttempts = 0;
        _isConnected.value = true; // Mise à jour de l'état
        if (kDebugMode) print(' WebSocket connecté');
      });

      // Écouteurs d'événements
      _socket!.on('processBorrowRequest', (data) {
        if (kDebugMode) print('📦 processBorrowRequest reçu: $data');
        _borrowRequestSubject.add(data);
      });

      _socket!.on('processDemand', (data) {
        if (kDebugMode) print('📦 processDemand reçu: $data');
        _demandSubject.add(data);
      });

      _socket!.on('addReview', (data) {
        if (kDebugMode) print('📦 addReview reçu: $data');
        _reviewSubject.add(data);
      });

      _socket!.onError((error) {
        _isConnected.value = false;
        if (kDebugMode) print(' Erreur WebSocket: $error');
        _scheduleReconnect();
      });

      _socket!.onDisconnect((_) {
        _isConnected.value = false;
        if (kDebugMode) print(' Déconnecté du WebSocket');
        _scheduleReconnect();
      });
    } catch (e) {
      _isConnected.value = false;
      if (kDebugMode) print(' Erreur de connexion WebSocket: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectAttempts++;
    if (kDebugMode) {
      print(' Reconnexion prévue dans 5 sec (tentative $_reconnectAttempts)');
    }

    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (kDebugMode) print('🔁 Tentative de reconnexion...');
      _connect();
    });
  }

  Stream<dynamic> listenForBorrowRequestUpdates() {
    return _borrowRequestSubject.stream;
  }

  Stream<dynamic> listenForDemandUpdates() {
    return _demandSubject.stream;
  }

  Stream<dynamic> listenForReviewUpdates() {
    return _reviewSubject.stream;
  }

  void disconnect() {
    try {
      _reconnectTimer?.cancel();
      _socket?.disconnect();
      _socket?.dispose();
      _isConnected.value = false;

      _borrowRequestSubject.close();
      _demandSubject.close();
      _reviewSubject.close();

      if (kDebugMode) {
        print('Déconnexion et nettoyage du WebSocket terminés');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur pendant la déconnexion: $e');
      }
    }
  }
}
