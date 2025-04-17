import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  IO.Socket? _socket;
  final _borrowRequestSubject = BehaviorSubject<dynamic>();
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const String _wsUrlEmulator = 'http://10.0.2.2:9092';
  static const String _wsUrlPhysical = 'http://192.168.1.100:9092';
  static const int _maxReconnectAttempts = 10;
  final String _wsUrl;

  SocketService({bool isPhysicalDevice = false})
    : _wsUrl = isPhysicalDevice ? _wsUrlPhysical : _wsUrlEmulator;

  void connect() {
    _connect();
  }

  void _connect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        print(
          'SocketService: Nombre maximum de tentatives de reconnexion atteint ($_maxReconnectAttempts)',
        );
      }
      return;
    }

    if (kDebugMode) {
      print(
        'SocketService: Tentative de connexion au WebSocket $_wsUrl (Tentative ${_reconnectAttempts + 1}/$_maxReconnectAttempts)',
      );
    }

    try {
      _socket = IO.io(
        _wsUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Forcer WebSocket
            .disableAutoConnect() // Désactiver la connexion automatique
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        _reconnectAttempts = 0; // Réinitialiser après une connexion réussie
        if (kDebugMode) {
          print('SocketService: Connexion WebSocket établie');
        }
      });

      _socket!.on('processBorrowRequest', (data) {
        if (kDebugMode) {
          print('SocketService: Données reçues: $data');
        }
        try {
          _borrowRequestSubject.add(data);
        } catch (e) {
          if (kDebugMode) {
            print('SocketService: Erreur lors du traitement des données: $e');
          }
        }
      });

      _socket!.onError((error) {
        if (kDebugMode) {
          print('SocketService: Erreur WebSocket: $error');
        }
        _scheduleReconnect();
      });

      _socket!.onDisconnect((_) {
        if (kDebugMode) {
          print('SocketService: Connexion WebSocket fermée');
        }
        _scheduleReconnect();
      });
    } catch (e) {
      if (kDebugMode) {
        print('SocketService: Échec de la connexion WebSocket: $e');
      }
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;
    _reconnectAttempts++;
    if (kDebugMode) {
      print(
        'SocketService: Planification de la reconnexion dans 5 secondes (Tentative $_reconnectAttempts/$_maxReconnectAttempts)',
      );
    }
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (kDebugMode) {
        print('SocketService: Tentative de reconnexion');
      }
      _connect();
    });
  }

  Stream<dynamic> listenForBorrowRequestUpdates() {
    if (kDebugMode) {
      print(
        'SocketService: Écoute du flux des mises à jour de demandes d\'emprunt',
      );
    }
    return _borrowRequestSubject.stream;
  }

  void disconnect() {
    if (kDebugMode) {
      print('SocketService: Déconnexion du WebSocket');
    }
    try {
      _reconnectTimer?.cancel();
      _socket?.disconnect();
      _socket?.dispose();
      _borrowRequestSubject.close();
      if (kDebugMode) {
        print('SocketService: WebSocket et BehaviorSubject fermés');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SocketService: Erreur lors de la déconnexion: $e');
      }
    }
  }
}
