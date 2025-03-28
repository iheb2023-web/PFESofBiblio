package com.sofrecom.backend.controllers;

import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.services.IBookService;
import com.sofrecom.backend.services.IUserService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
@RestController
@RequestMapping("/books")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class BookController {
    private final IBookService bookService;
    private final IUserService userService;

    @GetMapping("/{id}")
    public Book getBookById(@PathVariable Long id) {
        return this.bookService.getBookById(id);
    }

    @PostMapping("/add/{email}")
    public Book addNewBook(@RequestBody Book book, @PathVariable String email) {
        return bookService.addNewBook(book,email);
    }
    
    @Operation(summary = "Add book", description = "Add new book")
    @PostMapping("")
    public ResponseEntity<?> addBook(@RequestBody Book book) {
        if (book.getOwnerId() == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("L'ownerId est obligatoire !");
        }

        User owner = userService.findById(book.getOwnerId());
        if (owner == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Utilisateur non trouvé avec l'ID : " + book.getOwnerId());
        }

        book.setOwner(owner);
        Book response = bookService.addBook(book);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);

    }

    @GetMapping("")
    public List<Book> getAllBooks() {
        return this.bookService.getAll();
    }

    @Operation(summary = "Get user books", description = "Get all books owned by a specific user")
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getBooksByUser(@PathVariable Long userId) {
        try {
            var userDto = userService.getUserById(userId);
            if (userDto == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("User not found with id: " + userId);
            }
            return ResponseEntity.ok(this.bookService.getBooksByUser(userId));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Error retrieving books: " + e.getMessage());
        }
    }

    @GetMapping("/checkOwnerBookByEmail/{email}/{id}")
    public boolean checkOwnerBookByEmail(@PathVariable String email, @PathVariable Long id) {
        return this.bookService.checkOwnerBookByEmail(email,id);
    }

    @GetMapping("/allBookWithinEmailOwner/{email}")
    public List<Book> getAllBooksWithinEmailOwner(@PathVariable String email) {
        return this.bookService.getAllBooksWithinEmailOwner(email);

    }




}
