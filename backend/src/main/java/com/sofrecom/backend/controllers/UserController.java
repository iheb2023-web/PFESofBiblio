package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.AuthenticationRequest;
import com.sofrecom.backend.dtos.AuthenticationResponse;
import com.sofrecom.backend.dtos.RegisterRequest;
import com.sofrecom.backend.dtos.UserDto;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.services.AuthenticationService;
import com.sofrecom.backend.services.IUserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
@Tag(name = "User API", description = "Endpoints for managing users")
public class UserController {
    private final IUserService userService;
    private final AuthenticationService authenticationService;


    @Operation(summary = "Add user", description = "Add new user")
    @PostMapping("")
    public ResponseEntity<AuthenticationResponse> addUser(
            @RequestBody RegisterRequest request
    ) {
        return ResponseEntity.ok(this.userService.addUser(request));
    }

    @Operation(summary = "Login", description = "Login")
    @PostMapping("/login")
    public ResponseEntity<AuthenticationResponse> authenticate(
            @RequestBody AuthenticationRequest request
    ) {
        return ResponseEntity.ok(authenticationService.authenticate(request));
    }

    @Operation(summary = "Get all users", description = "Retrieve a list of all users")
    @GetMapping
    public Page<UserDto> getUsers(@RequestParam(defaultValue = "0") int page,
                                  @RequestParam(defaultValue = "5") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return userService.getUsers(pageable);
    }







}
