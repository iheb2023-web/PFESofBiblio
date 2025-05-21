package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.PasswordResetResponse;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.repositories.UserRepository;
import com.sofrecom.backend.services.PasswordResetService;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Optional;

@RequiredArgsConstructor
@RestController
@RequestMapping("/password-reset")
public class PasswordResetController {

    private final PasswordResetService passwordResetService;
    private final UserRepository userRepository;

    @PostMapping("/request")
    public ResponseEntity<String> requestPasswordReset(@RequestParam("email") String email) throws MessagingException {
        Optional<User> user = userRepository.findByEmail(email);
        if (user == null) {
            return ResponseEntity.badRequest().body("User not found");
        } else {
            // Generate a secure token
            SecureRandom secureRandom = new SecureRandom();
            byte[] randomBytes = new byte[32];
            secureRandom.nextBytes(randomBytes);
            String token = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
            passwordResetService.createPasswordResetTokenForUser(user.get(), token);
            passwordResetService.sendPasswordResetEmail(email, token);

            return ResponseEntity.ok("Password reset email sent successfully");
        }
    }

    @GetMapping("/getTokenByEmail/{email}")
    public String getPasswordResetCode(@PathVariable("email") String email) {
        return this.passwordResetService.getTokenByEmail(email);
    }

    @PutMapping("/reset")
    public ResponseEntity<PasswordResetResponse> resetPassword(@RequestParam("token") String token,
                                                               @RequestParam("password") String newPassword) {
        return ResponseEntity.ok(passwordResetService.resetPassword(token, newPassword));
    }

    @PutMapping("/changePassword")
    public ResponseEntity<PasswordResetResponse> changePassword(@RequestParam("email") String email,
                                                                @RequestParam("password") String newPassword) {
        return ResponseEntity.ok(passwordResetService.changePassword(email, newPassword));
    }
}