package com.sofrecom.backend.services;


import com.corundumstudio.socketio.BroadcastOperations;
import com.corundumstudio.socketio.SocketIOClient;
import com.corundumstudio.socketio.SocketIOServer;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class SocketIOServiceTest {

    @Mock
    private SocketIOServer server;

    @Mock
    private BroadcastOperations broadcastOperations;

    @Mock
    private SocketIOClient socketIOClient;

    @InjectMocks
    private SocketIOService socketIOService;

    @BeforeEach
    void setUp() {
        // No stubbing here to avoid unnecessary stubbing
    }

    @Test
    void start_ShouldAddListenersAndStartServer() {
        // Arrange
        doNothing().when(server).addConnectListener(any());
        doNothing().when(server).addDisconnectListener(any());
        doNothing().when(server).start();

        // Act
        socketIOService.start();

        // Assert
        verify(server).addConnectListener(any());
        verify(server).addDisconnectListener(any());
        verify(server).start();
    }

    @Test
    void stop_ShouldStopServer() {
        // Arrange
        doNothing().when(server).stop();

        // Act
        socketIOService.stop();

        // Assert
        verify(server).stop();
    }

    @Test
    void sendBookUpdateNotification_ShouldBroadcastEvent() {
        // Arrange
        String bookDetails = "Book updated details";
        when(server.getBroadcastOperations()).thenReturn(broadcastOperations);
        doNothing().when(broadcastOperations).sendEvent("bookUpdated", bookDetails);

        // Act
        socketIOService.sendBookUpdateNotification(bookDetails);

        // Assert
        verify(server).getBroadcastOperations();
        verify(broadcastOperations).sendEvent("bookUpdated", bookDetails);
    }

    @Test
    void sendProcessBorrowRequestNotification_ShouldBroadcastEvent() {
        // Arrange
        Long borrowId = 1L;
        when(server.getBroadcastOperations()).thenReturn(broadcastOperations);
        doNothing().when(broadcastOperations).sendEvent("processBorrowRequest", borrowId);

        // Act
        socketIOService.sendProcessBorrowRequestNotification(borrowId);

        // Assert
        verify(server).getBroadcastOperations();
        verify(broadcastOperations).sendEvent("processBorrowRequest", borrowId);
    }

    @Test
    void sendDemandNotification_ShouldBroadcastEvent() {
        // Arrange
        Long borrowId = 1L;
        when(server.getBroadcastOperations()).thenReturn(broadcastOperations);
        doNothing().when(broadcastOperations).sendEvent("processDemand", borrowId);

        // Act
        socketIOService.sendDemandNotification(borrowId);

        // Assert
        verify(server).getBroadcastOperations();
        verify(broadcastOperations).sendEvent("processDemand", borrowId);
    }

    @Test
    void sendAddReviewNotification_ShouldBroadcastEvent() {
        // Arrange
        Long reviewId = 1L;
        when(server.getBroadcastOperations()).thenReturn(broadcastOperations);
        doNothing().when(broadcastOperations).sendEvent("addReview", reviewId);

        // Act
        socketIOService.sendAddReviewNotification(reviewId);

        // Assert
        verify(server).getBroadcastOperations();
        verify(broadcastOperations).sendEvent("addReview", reviewId);
    }
}