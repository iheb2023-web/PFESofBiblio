package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.*;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.services.AuthenticationService;
import com.sofrecom.backend.services.CloudinaryService;
import com.sofrecom.backend.services.IUserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/users")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
@Tag(name = "User API", description = "Endpoints for managing users")
public class UserController {
    private final IUserService userService;
    private final AuthenticationService authenticationService;
    private final CloudinaryService cloudinaryService;

    @Operation(summary = "Add user", description = "Add new user")
    @PostMapping("")
    public ResponseEntity<AuthenticationResponse> registerUser(@RequestBody RegisterRequest request) {
        AuthenticationResponse response = userService.addUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
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
                                  @RequestParam(defaultValue = "5") int size,  @RequestParam(required = false) String search) {
        Pageable pageable = PageRequest.of(page, size);
        return userService.getUsers(pageable, search);
    }

    @GetMapping("/usermininfo/{email}")
    public UserMinDto getUserMinInfo(@PathVariable String email) {
        return this.userService.getUserMinInfo(email);
    }

    @PostMapping("/upload")
    public String uploadImage(@RequestParam("file") MultipartFile file) {
        try {
            String imageUrl = cloudinaryService.uploadImage(file);
            return imageUrl;
        } catch (IOException e) {
            return "error";
        }
    }

    @PatchMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody UserUpdateDto user) {
        User updatedUser = userService.updateUser(id, user);
        return ResponseEntity.ok(updatedUser);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserUpdateDto> getuserdetail(@PathVariable Long id) {
        UserUpdateDto updatedUser = userService.getUserById(id);
        return ResponseEntity.ok(updatedUser);
    }

    @DeleteMapping("/{id}")
    public void deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
    }

    @GetMapping("/getIdFromEmail/{email}")
    public Long getIdFromEmail(@PathVariable String email)
    {
        return this.userService.getIdFromEmail(email);
    }

    @GetMapping("/numberOfBorrows/{email}")
    public Long numberOfBorrowsByUser(@PathVariable String email)
    {
        return this.userService.numberOfBorrowsByUser(email);
    }

    @GetMapping("/numberOfBooks/{email}")
    public Long numberOfBooksByUser(@PathVariable String email)
    {
        return this.userService.numberOfBooksByUser(email);
    }


    @PostMapping("/hasSetPassword/{email}")
    public ResponseEntity<Boolean> hasSetPassword(@PathVariable String email) {
        return this.userService.hasSetPassword(email);
    }
    @Operation(summary = "Top 5 des emprunteurs", description = "Retourne les 5 utilisateurs ayant effectué le plus d'emprunts")
    @GetMapping("/top5emprunteur")
    public ResponseEntity<List<Top5Dto>> getTop5Borrowers() {
        List<Top5Dto> top5Borrowers = userService.getTop5Borrowers();
        return ResponseEntity.ok(top5Borrowers);
    }

    @Operation(summary = "Top 10 des emprunteurs", description = "Retourne les 10 utilisateurs ayant effectué le plus d'emprunts")
    @GetMapping("/top10emprunteur")
    public ResponseEntity<List<Top5Dto>> getTop10Borrowers() {
        List<Top5Dto> top5Borrowers = userService.getTop10Borrowers();
        return ResponseEntity.ok(top5Borrowers);
    }







}
