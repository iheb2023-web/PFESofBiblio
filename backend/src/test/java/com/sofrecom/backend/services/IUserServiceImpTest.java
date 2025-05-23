package com.sofrecom.backend.services;


import com.sofrecom.backend.config.JwtService;
import com.sofrecom.backend.dtos.*;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.enums.Role;
import com.sofrecom.backend.exceptions.EmailAlreadyExistsException;
import com.sofrecom.backend.exceptions.ResourceNotFoundException;
import com.sofrecom.backend.repositories.UserRepository;
import jakarta.mail.MessagingException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class IUserServiceImpTest {

    @Value("${JWT_SECRET_KEY}")
    private String password;

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @Mock
    private EmailService emailService;

    @InjectMocks
    private IUserServiceImp userService;

    private User user;
    private RegisterRequest registerRequest;
    private UserUpdateDto userUpdateDto;
    private Pageable pageable;

    @SuppressWarnings("squid:S2068")
    @BeforeEach
    void setUp() {
        user = User.builder()
                .id(1L)
                .firstname("John")
                .lastname("Doe")
                .email("john.doe@example.com")
                .password(password)
                .role(Role.Administrateur)
                .hasPreference(false)
                .hasSetPassword(false)
                .build();

        registerRequest = new RegisterRequest();
        registerRequest.setFirstname("John");
        registerRequest.setLastname("Doe");
        registerRequest.setEmail("john.doe@example.com");
        registerRequest.setRole(Role.Administrateur);

        userUpdateDto = new UserUpdateDto();
        userUpdateDto.setFirstname("Jane");
        userUpdateDto.setLastname("Smith");
        userUpdateDto.setEmail("jane.smith@example.com");

        pageable = PageRequest.of(0, 10);
    }

    @Test
    void getAllUsers_ShouldReturnAllUsers() {
        List<User> users = Arrays.asList(user);
        when(userRepository.findAll()).thenReturn(users);

        List<User> result = userService.getAllUsers();

        assertEquals(1, result.size());
        assertEquals(user, result.get(0));
        verify(userRepository).findAll();
    }

    @Test
    void addUser_NewUser_ShouldSaveAndSendEmail() throws MessagingException {
        when(userRepository.existsByEmail("john.doe@example.com")).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(user);
        when(jwtService.generateToken(any(User.class))).thenReturn("jwtToken");
        doNothing().when(emailService).sendEmail(anyString(), anyString(), anyString());

        AuthenticationResponse response = userService.addUser(registerRequest);

        assertNotNull(response);
        assertEquals("jwtToken", response.getAccessToken());
        verify(userRepository).save(any(User.class));
        verify(emailService).sendEmail(eq("john.doe@example.com"), eq("Default password"), anyString());
        verify(jwtService).generateToken(any(User.class));
    }

    @Test
    void addUser_EmailExists_ShouldThrowException() throws MessagingException {
        when(userRepository.existsByEmail("john.doe@example.com")).thenReturn(true);

        EmailAlreadyExistsException exception = assertThrows(EmailAlreadyExistsException.class, () ->
                userService.addUser(registerRequest));
        assertEquals("Email already exists in the database", exception.getMessage());
        verify(userRepository, never()).save(any());
        verify(emailService, never()).sendEmail(anyString(), anyString(), anyString());
    }

    @Test
    void getUsers_WithSearchTerm_ShouldReturnPagedUsers() {
        UserDto userDto = new UserDto();
        Page<UserDto> userPage = new PageImpl<>(Arrays.asList(userDto));
        when(userRepository.findBySearchTerm("John", pageable)).thenReturn(userPage);

        Page<UserDto> result = userService.getUsers(pageable, "John");

        assertEquals(1, result.getContent().size());
        verify(userRepository).findBySearchTerm("John", pageable);
    }

    @Test
    void getUsers_WithoutSearchTerm_ShouldReturnAllPagedUsers() {
        UserDto userDto = new UserDto();
        Page<UserDto> userPage = new PageImpl<>(Arrays.asList(userDto));
        when(userRepository.findAllUsers(pageable)).thenReturn(userPage);

        Page<UserDto> result = userService.getUsers(pageable, null);

        assertEquals(1, result.getContent().size());
        verify(userRepository).findAllUsers(pageable);
    }

    @Test
    void deleteUser_ShouldDeleteById() {
        userService.deleteUser(1L);

        verify(userRepository).deleteById(1L);
    }

    @Test
    void getUserMinInfo_ShouldReturnMinInfo() {
        UserMinDto userMinDto = new UserMinDto();
        when(userRepository.findUserMinInfo("john.doe@example.com")).thenReturn(userMinDto);

        UserMinDto result = userService.getUserMinInfo("john.doe@example.com");

        assertNotNull(result);
        verify(userRepository).findUserMinInfo("john.doe@example.com");
    }

    @Test
    void updateUser_ExistingUser_ShouldUpdateFields() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenReturn(user);

        User result = userService.updateUser(1L, userUpdateDto);

        assertEquals("Jane", result.getFirstname());
        assertEquals("Smith", result.getLastname());
        assertEquals("jane.smith@example.com", result.getEmail());
        verify(userRepository).save(user);
    }

    @Test
    void updateUser_NonExistingUser_ShouldThrowException() {
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        RuntimeException exception = assertThrows(RuntimeException.class, () ->
                userService.updateUser(1L, userUpdateDto));
        assertEquals("User not found", exception.getMessage());
        verify(userRepository, never()).save(any());
    }

    @Test
    void getUserById_ExistingUser_ShouldReturnUserDto() {
        UserUpdateDto userDto = new UserUpdateDto();
        when(userRepository.findUserUpdateDtoById(1L)).thenReturn(Optional.of(userDto));

        UserUpdateDto result = userService.getUserById(1L);

        assertNotNull(result);
        verify(userRepository).findUserUpdateDtoById(1L);
    }

    @Test
    void getUserById_NonExistingUser_ShouldThrowException() {
        when(userRepository.findUserUpdateDtoById(1L)).thenReturn(Optional.empty());

        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () ->
                userService.getUserById(1L));
        assertEquals("User not found with id: 1", exception.getMessage());
    }

    @Test
    void findById_ExistingUser_ShouldReturnUser() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        User result = userService.findById(1L);

        assertNotNull(result);
        assertEquals(user, result);
        verify(userRepository).findById(1L);
    }

    @Test
    void findById_NonExistingUser_ShouldReturnNull() {
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        User result = userService.findById(1L);

        assertNull(result);
        verify(userRepository).findById(1L);
    }

    @Test
    void getIdFromEmail_ShouldReturnId() {
        when(userRepository.findIdByEmail("john.doe@example.com")).thenReturn(1L);

        Long result = userService.getIdFromEmail("john.doe@example.com");

        assertEquals(1L, result);
        verify(userRepository).findIdByEmail("john.doe@example.com");
    }

    @Test
    void hasSetPassword_ExistingUser_ShouldUpdateAndReturnTrue() {
        when(userRepository.findByEmail("john.doe@example.com")).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenReturn(user);

        ResponseEntity<Boolean> result = userService.hasSetPassword("john.doe@example.com");

        assertTrue(result.getBody());
        assertEquals(HttpStatus.OK, result.getStatusCode());
        verify(userRepository).save(user);
    }

    @Test
    void hasSetPassword_NonExistingUser_ShouldReturnFalse() {
        when(userRepository.findByEmail("john.doe@example.com")).thenReturn(Optional.empty());

        ResponseEntity<Boolean> result = userService.hasSetPassword("john.doe@example.com");

        assertFalse(result.getBody());
        assertEquals(HttpStatus.NOT_FOUND, result.getStatusCode());
        verify(userRepository, never()).save(any());
    }

    @Test
    void numberOfBorrowsByUser_ShouldReturnCount() {
        when(userRepository.numbreOfBorrowsByUser("john.doe@example.com")).thenReturn(5L);

        Long result = userService.numberOfBorrowsByUser("john.doe@example.com");

        assertEquals(5L, result);
        verify(userRepository).numbreOfBorrowsByUser("john.doe@example.com");
    }

    @Test
    void numberOfBooksByUser_ShouldReturnCount() {
        when(userRepository.numbreOfBooksByUser("john.doe@example.com")).thenReturn(3L);

        Long result = userService.numberOfBooksByUser("john.doe@example.com");

        assertEquals(3L, result);
        verify(userRepository).numbreOfBooksByUser("john.doe@example.com");
    }
}