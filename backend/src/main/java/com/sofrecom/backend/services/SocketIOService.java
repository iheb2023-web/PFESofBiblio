package com.sofrecom.backend.services;

import com.corundumstudio.socketio.SocketIOServer;
import com.corundumstudio.socketio.listener.ConnectListener;
import com.corundumstudio.socketio.listener.DisconnectListener;
import com.sofrecom.backend.entities.Borrow;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;

@Service
public class SocketIOService {

    private final SocketIOServer server;

    @Autowired
    public SocketIOService(SocketIOServer server) {
        this.server = server;
    }

    @PostConstruct
    public void start() {
        server.addConnectListener(client -> System.out.println("Client connected: " + client.getSessionId()));
        server.addDisconnectListener(client -> System.out.println("Client disconnected: " + client.getSessionId()));
        server.start();
    }

    @PreDestroy
    public void stop() {
        server.stop();
    }

    // Method to broadcast book update notification
    public void sendBookUpdateNotification(String bookDetails) {
        server.getBroadcastOperations().sendEvent("bookUpdated", bookDetails);
    }


    public void sendProcessBorrowRequestNotification(Long borrowId) {
        server.getBroadcastOperations().sendEvent("processBorrowRequest", borrowId);
    }


}