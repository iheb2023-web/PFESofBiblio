package com.sofrecom.backend.services;

import com.sofrecom.backend.config.JwtService;
import com.sofrecom.backend.dtos.AuthenticationResponse;
import com.sofrecom.backend.dtos.RegisterRequest;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.repositories.UserRepository;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class IUserServiceImp implements IUserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;


    @Override
    public List<User> getAllUsers() {
        return this.userRepository.findAll();
    }

    @Override
    public AuthenticationResponse addUser(RegisterRequest request) {
        String password = getPassword();
        var user = User.builder()
                .firstname(request.getFirstname())
                .lastname(request.getLastname())
                .email(request.getEmail())
                .password(passwordEncoder.encode(password))
                .role(request.getRole())
                .build();
        var savedUser = userRepository.save(user);
        var jwtToken = jwtService.generateToken(user);
        try {
            emailService.sendEmail(request.getEmail(), "Default password", password);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
        return AuthenticationResponse.builder()
                .accessToken(jwtToken)
                .build();
    }

    private String getPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random random = new Random();
        StringBuilder password = new StringBuilder(8);

        for (int i = 0; i < 8; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        return password.toString();
    }

}
