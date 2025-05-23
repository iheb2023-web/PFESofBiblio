package com.sofrecom.backend.services;

import com.sofrecom.backend.config.JwtService;
import com.sofrecom.backend.dtos.*;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.exceptions.EmailAlreadyExistsException;
import com.sofrecom.backend.exceptions.EmailSendingException;
import com.sofrecom.backend.exceptions.ResourceNotFoundException;
import com.sofrecom.backend.repositories.UserRepository;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.security.SecureRandom;
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
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new EmailAlreadyExistsException("Email already exists in the database");
        }
        String password = getPassword();
        var user = User.builder()
                .firstname(request.getFirstname())
                .lastname(request.getLastname())
                .job(request.getJob())
                .birthday(request.getBirthday())
                .number(request.getNumber())
                .email(request.getEmail())
                .image(request.getImage())
                .hasPreference(false)
                .hasSetPassword(false)
                .password(passwordEncoder.encode(password))
                .role(request.getRole())
                .build();

        var savedUser = userRepository.save(user);
        var jwtToken = jwtService.generateToken(user);
        try {
            emailService.sendEmail(request.getEmail(), "Default password", password);
        } catch (MessagingException e) {
            throw new EmailSendingException("Failed to send registration email. Please try again later.", e);
            }
        return AuthenticationResponse.builder()
                .accessToken(jwtToken)
                .build();
    }



    @Override
    public Page<UserDto> getUsers(Pageable pageable, String searchTerm) {
        if (StringUtils.hasText(searchTerm)) {
            // If search term is provided, use the search method
            return userRepository.findBySearchTerm(searchTerm, pageable);
        } else {
            // Otherwise, return all users with pagination
            return userRepository.findAllUsers(pageable);
        }
    }

    @Override
    public void deleteUser(Long id) {
        this.userRepository.deleteById(id);
    }

    @Override
    public UserMinDto getUserMinInfo(String email) {
        return this.userRepository.findUserMinInfo(email);
    }

    public User updateUser(Long id, UserUpdateDto userDto) {
        User existingUser = userRepository.findById(id).orElseThrow(() -> new RuntimeException("User not found"));

        if (userDto.getFirstname() != null) {
            existingUser.setFirstname(userDto.getFirstname());
        }
        if (userDto.getLastname() != null) {
            existingUser.setLastname(userDto.getLastname());
        }
        if (userDto.getEmail() != null) {
            existingUser.setEmail(userDto.getEmail());
        }
        if (userDto.getImage() != null) {
            existingUser.setImage(userDto.getImage());
        }
        if (userDto.getJob() != null) {
            existingUser.setJob(userDto.getJob());
        }
        if (userDto.getBirthday() != null) {
            existingUser.setBirthday(userDto.getBirthday());
        }
        if (userDto.getNumber() != null) {
            existingUser.setNumber(userDto.getNumber());
        }
        if (userDto.getRole() != null) {
            existingUser.setRole(userDto.getRole());
        }

        if (userDto.getHasPreference() != null) {
            existingUser.setHasPreference(userDto.getHasPreference());
        }
        if (userDto.getHasSetPassword() != null) {
            existingUser.setHasSetPassword(userDto.getHasSetPassword());
        }

        return userRepository.save(existingUser);
    }

    @Override
    public UserUpdateDto getUserById(Long id) {
        return userRepository.findUserUpdateDtoById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
    }

    private String getPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder password = new StringBuilder(12);

        for (int i = 0; i < 12; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        return password.toString();
    }
    @Override
    public User findById(Long id) {
        return userRepository.findById(id).orElse(null);
    }

    @Override
    public Long getIdFromEmail(String email) {
        return this.userRepository.findIdByEmail(email);
    }
    @Override
    public ResponseEntity<Boolean> hasSetPassword(String email) {
        User user = this.userRepository.findByEmail(email).orElse(null);
        if (user != null) {
            user.setHasSetPassword(true);
            this.userRepository.save(user);
            return new ResponseEntity<>(true, HttpStatus.OK);
        }
        return  new ResponseEntity<>(false, HttpStatus.NOT_FOUND);
    }

    @Override
    public Long numberOfBorrowsByUser(String email) {
        return this.userRepository.numbreOfBorrowsByUser(email);
    }
    @Override
    public Long numberOfBooksByUser(String email) {
        return this.userRepository.numbreOfBooksByUser(email);
    }

    @Override
    public List<Top5Dto> getTop5Borrowers() {
        Pageable topFive = Pageable.ofSize(5);
        return userRepository.findTop5Borrowers(topFive);
    }

    @Override
    public List<Top5Dto> getTop10Borrowers() {
        Pageable topFive = Pageable.ofSize(10);
        return userRepository.findTop5Borrowers(topFive);
    }


}
