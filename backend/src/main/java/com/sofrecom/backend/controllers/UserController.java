package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.AuthenticationRequest;
import com.sofrecom.backend.dtos.AuthenticationResponse;
import com.sofrecom.backend.dtos.RegisterRequest;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.services.AuthenticationService;
import com.sofrecom.backend.services.IUserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
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

    @Operation(summary = "Get all users", description = "Retrieve a list of all users")
    @GetMapping("")
    public List<User> getAllUsers()
    {
        return this.userService.getAllUsers();
    }
    @PostMapping("")
    public ResponseEntity<AuthenticationResponse> addUser(
            @RequestBody RegisterRequest request
    ) {
        return ResponseEntity.ok(this.userService.addUser(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthenticationResponse> authenticate(
            @RequestBody AuthenticationRequest request
    ) {
        return ResponseEntity.ok(authenticationService.authenticate(request));
    }





}
