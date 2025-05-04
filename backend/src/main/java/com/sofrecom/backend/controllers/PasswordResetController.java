package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.PasswordResetResponse;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.repositories.UserRepository;
import com.sofrecom.backend.services.PasswordResetService;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.UUID;

import java.util.Optional;
@RequiredArgsConstructor
@RestController
@RequestMapping("/password-reset")
@CrossOrigin(origins = "*")
public class PasswordResetController {


    private final PasswordResetService passwordResetService;
    private final UserRepository userRepository;

    @PostMapping("/request")
    public ResponseEntity<String> requestPasswordReset(@RequestParam("email") String email) throws MessagingException {
        Optional<User> user = userRepository.findByEmail(email);
        if (user == null) {
            return ResponseEntity.badRequest().body("User not found");
        }else {
            String token = UUID.randomUUID().toString();
            passwordResetService.createPasswordResetTokenForUser(user.get(), token);
            passwordResetService.sendPasswordResetEmail(email, token);

            return ResponseEntity.ok("Password reset email sent successfully");

        }

    }

    @PutMapping("/reset")
    public ResponseEntity<PasswordResetResponse> resetPassword(@RequestParam("token") String token, @RequestParam("password") String newPassword) {
        return ResponseEntity.ok(passwordResetService.resetPassword(token,newPassword));
    }


}