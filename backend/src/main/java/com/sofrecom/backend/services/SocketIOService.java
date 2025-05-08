package com.sofrecom.backend.services;

import com.corundumstudio.socketio.SocketIOServer;
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
        server.addConnectListener(client -> {
            System.out.println("Backend: Client connecté: " + client.getSessionId());
        });
        server.addDisconnectListener(client -> {
            System.out.println("Backend: Client déconnecté: " + client.getSessionId());
        });
        server.start();
        System.out.println("Backend: Serveur WebSocket démarré sur le port 9092");
    }

    @PreDestroy
    public void stop() {
        server.stop();
        System.out.println("Backend: Serveur WebSocket arrêté");
    }

    // Method to broadcast book update notification
    public void sendBookUpdateNotification(String bookDetails) {
        server.getBroadcastOperations().sendEvent("bookUpdated", bookDetails);
    }


    public void sendProcessBorrowRequestNotification(Long borrowId) {
        //server.getBroadcastOperations().sendEvent("processBorrowRequest", borrowId);
        System.out.println("Backend: Envoi de l'événement processBorrowRequest avec borrowId: " + borrowId);
        server.getBroadcastOperations().sendEvent("processBorrowRequest", borrowId);
        System.out.println("Backend: Événement processBorrowRequest envoyé");
    }

    public void sendDemandNotification(Long borrowId) {
        server.getBroadcastOperations().sendEvent("processDemand", borrowId);
    }

    public void sendAddReviewNotification(Long reviewId) {
        server.getBroadcastOperations().sendEvent("addReview", reviewId);
    }


}