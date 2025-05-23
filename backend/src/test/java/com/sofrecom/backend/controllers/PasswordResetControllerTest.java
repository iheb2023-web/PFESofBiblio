package com.sofrecom.backend.controllers;


import com.sofrecom.backend.dtos.PasswordResetResponse;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.repositories.UserRepository;
import com.sofrecom.backend.services.PasswordResetService;
import jakarta.mail.MessagingException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PasswordResetControllerTest {

    @Mock
    private PasswordResetService passwordResetService;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private PasswordResetController passwordResetController;

    private User user;
    private PasswordResetResponse passwordResetResponse;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");

        passwordResetResponse = new PasswordResetResponse("Password reset successfully");

    }

    @Test
    void requestPasswordReset_Success() throws MessagingException {
        when(userRepository.findByEmail(eq("test@example.com"))).thenReturn(Optional.of(user));
        doNothing().when(passwordResetService).createPasswordResetTokenForUser(any(User.class), anyString());
        doNothing().when(passwordResetService).sendPasswordResetEmail(eq("test@example.com"), anyString());

        ResponseEntity<String> response = passwordResetController.requestPasswordReset("test@example.com");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Password reset email sent successfully", response.getBody());
        verify(userRepository).findByEmail(eq("test@example.com"));
        verify(passwordResetService).createPasswordResetTokenForUser(any(User.class), anyString());
        verify(passwordResetService).sendPasswordResetEmail(eq("test@example.com"), anyString());
    }



    @Test
    void getPasswordResetCode_Success() {
        when(passwordResetService.getTokenByEmail(eq("test@example.com"))).thenReturn("reset-token");

        String result = passwordResetController.getPasswordResetCode("test@example.com");

        assertEquals("reset-token", result);
        verify(passwordResetService).getTokenByEmail(eq("test@example.com"));
    }

    @Test
    void resetPassword_Success() {
        when(passwordResetService.resetPassword(eq("reset-token"), eq("newPassword"))).thenReturn(passwordResetResponse);

        ResponseEntity<PasswordResetResponse> response = passwordResetController.resetPassword("reset-token", "newPassword");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Password reset successfully", response.getBody().getStatus());
        verify(passwordResetService).resetPassword(eq("reset-token"), eq("newPassword"));
    }

    @Test
    void changePassword_Success() {
        when(passwordResetService.changePassword(eq("test@example.com"), eq("newPassword"))).thenReturn(passwordResetResponse);

        ResponseEntity<PasswordResetResponse> response = passwordResetController.changePassword("test@example.com", "newPassword");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Password reset successfully", response.getBody().getStatus());
        verify(passwordResetService).changePassword(eq("test@example.com"), eq("newPassword"));
    }
}