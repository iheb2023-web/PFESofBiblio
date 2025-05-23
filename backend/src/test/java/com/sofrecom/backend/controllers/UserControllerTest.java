package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.*;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.enums.Role;
import com.sofrecom.backend.services.AuthenticationService;
import com.sofrecom.backend.services.CloudinaryService;
import com.sofrecom.backend.services.IUserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserControllerTest {

    @Mock
    private IUserService userService;

    @Mock
    private AuthenticationService authenticationService;

    @Mock
    private CloudinaryService cloudinaryService;

    @InjectMocks
    private UserController userController;

    private User user;
    private UserDto userDto;
    private UserUpdateDto userUpdateDto;
    private AuthenticationResponse authResponse;
    private RegisterRequest registerRequest;
    private AuthenticationRequest authRequest;
    private UserMinDto userMinDto;
    private Top5Dto top5Dto;
    private MultipartFile file;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");

        userDto = new UserDto(1L, "John", "Doe", "test@example.com", "http://image.url", "Engineer", Role.Collaborateur);
        userUpdateDto = new UserUpdateDto();
        userUpdateDto.setEmail("test@example.com");
        userUpdateDto.setFirstname("John");
        userUpdateDto.setLastname("Doe");
        userUpdateDto.setJob("Engineer");

        authResponse = AuthenticationResponse.builder()
                .accessToken("jwt-token")
                .build();

        registerRequest = new RegisterRequest();
        registerRequest.setEmail("test@example.com");

        authRequest = new AuthenticationRequest();
        authRequest.setEmail("test@example.com");
        authRequest.setPassword("password");

        userMinDto = new UserMinDto();
        userMinDto.setEmail("test@example.com");

        top5Dto = new Top5Dto(1L, "John", "Doe", "test@example.com", 10L);

        file = mock(MultipartFile.class);
    }

    @Test
    void registerUser_Success() {
        when(userService.addUser(any(RegisterRequest.class))).thenReturn(authResponse);

        ResponseEntity<AuthenticationResponse> response = userController.registerUser(registerRequest);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertEquals("jwt-token", response.getBody().getAccessToken());
        verify(userService).addUser(any(RegisterRequest.class));
    }

    @Test
    void authenticate_Success() {
        when(authenticationService.authenticate(any(AuthenticationRequest.class))).thenReturn(authResponse);

        ResponseEntity<AuthenticationResponse> response = userController.authenticate(authRequest);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("jwt-token", response.getBody().getAccessToken());
        verify(authenticationService).authenticate(any(AuthenticationRequest.class));
    }

    @Test
    void getUsers_WithSearch_Success() {
        Page<UserDto> userPage = new PageImpl<>(Collections.singletonList(userDto));
        when(userService.getUsers(any(Pageable.class), eq("test"))).thenReturn(userPage);

        Page<UserDto> result = userController.getUsers(0, 5, "test");

        assertEquals(1, result.getContent().size());
        assertEquals("test@example.com", result.getContent().get(0).getEmail());
        assertEquals("John", result.getContent().get(0).getFirstname());
        assertEquals("Doe", result.getContent().get(0).getLastname());
        assertEquals("Engineer", result.getContent().get(0).getJob());
        assertEquals("http://image.url", result.getContent().get(0).getImage());
        assertEquals(Role.Collaborateur, result.getContent().get(0).getRole());
        verify(userService).getUsers(any(Pageable.class), eq("test"));
    }

    @Test
    void getUsers_WithoutSearch_Success() {
        Page<UserDto> userPage = new PageImpl<>(Collections.singletonList(userDto));
        when(userService.getUsers(any(Pageable.class), isNull())).thenReturn(userPage);

        Page<UserDto> result = userController.getUsers(0, 5, null);

        assertEquals(1, result.getContent().size());
        assertEquals("test@example.com", result.getContent().get(0).getEmail());
        assertEquals("John", result.getContent().get(0).getFirstname());
        assertEquals("Doe", result.getContent().get(0).getLastname());
        verify(userService).getUsers(any(Pageable.class), isNull());
    }

    @Test
    void getUserMinInfo_Success() {
        when(userService.getUserMinInfo("test@example.com")).thenReturn(userMinDto);

        UserMinDto result = userController.getUserMinInfo("test@example.com");

        assertEquals("test@example.com", result.getEmail());
        verify(userService).getUserMinInfo("test@example.com");
    }

    @Test
    void uploadImage_Success() throws Exception {
        when(cloudinaryService.uploadImage(any(MultipartFile.class))).thenReturn("http://image.url");

        String result = userController.uploadImage(file);

        assertEquals("http://image.url", result);
        verify(cloudinaryService).uploadImage(any(MultipartFile.class));
    }

    @Test
    void updateUser_Success() {
        when(userService.updateUser(eq(1L), any(UserUpdateDto.class))).thenReturn(user);

        ResponseEntity<User> response = userController.updateUser(1L, userUpdateDto);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("test@example.com", response.getBody().getEmail());
        verify(userService).updateUser(eq(1L), any(UserUpdateDto.class));
    }

    @Test
    void getUserDetail_Success() {
        when(userService.getUserById(1L)).thenReturn(userUpdateDto);

        ResponseEntity<UserUpdateDto> response = userController.getuserdetail(1L);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("test@example.com", response.getBody().getEmail());
        assertEquals("John", response.getBody().getFirstname());
        assertEquals("Doe", response.getBody().getLastname());
        assertEquals("Engineer", response.getBody().getJob());
        verify(userService).getUserById(1L);
    }

    @Test
    void deleteUser_Success() {
        doNothing().when(userService).deleteUser(1L);

        userController.deleteUser(1L);

        verify(userService).deleteUser(1L);
    }

    @Test
    void getIdFromEmail_Success() {
        when(userService.getIdFromEmail("test@example.com")).thenReturn(1L);

        Long result = userController.getIdFromEmail("test@example.com");

        assertEquals(1L, result);
        verify(userService).getIdFromEmail("test@example.com");
    }

    @Test
    void numberOfBorrowsByUser_Success() {
        when(userService.numberOfBorrowsByUser("test@example.com")).thenReturn(5L);

        Long result = userController.numberOfBorrowsByUser("test@example.com");

        assertEquals(5L, result);
        verify(userService).numberOfBorrowsByUser("test@example.com");
    }

    @Test
    void numberOfBooksByUser_Success() {
        when(userService.numberOfBooksByUser("test@example.com")).thenReturn(3L);

        Long result = userController.numberOfBooksByUser("test@example.com");

        assertEquals(3L, result);
        verify(userService).numberOfBooksByUser("test@example.com");
    }

    @Test
    void hasSetPassword_Success() {
        when(userService.hasSetPassword("test@example.com")).thenReturn(ResponseEntity.ok(true));

        ResponseEntity<Boolean> response = userController.hasSetPassword("test@example.com");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.getBody());
        verify(userService).hasSetPassword("test@example.com");
    }

    @Test
    void getTop5Borrowers_Success() {
        List<Top5Dto> top5List = Collections.singletonList(top5Dto);
        when(userService.getTop5Borrowers()).thenReturn(top5List);

        ResponseEntity<List<Top5Dto>> response = userController.getTop5Borrowers();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(1, response.getBody().size());
        assertEquals("test@example.com", response.getBody().get(0).getEmail());
        assertEquals("John", response.getBody().get(0).getFirstname());
        assertEquals("Doe", response.getBody().get(0).getLastname());
        assertEquals(10L, response.getBody().get(0).getNbEmprunts());
        verify(userService).getTop5Borrowers();
    }

    @Test
    void getTop5Borrowers_EmptyList_ReturnsEmpty() {
        when(userService.getTop5Borrowers()).thenReturn(Collections.emptyList());

        ResponseEntity<List<Top5Dto>> response = userController.getTop5Borrowers();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.getBody().isEmpty());
        verify(userService).getTop5Borrowers();
    }
}