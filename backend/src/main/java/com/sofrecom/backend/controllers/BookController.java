package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.BookOwerDto;
import com.sofrecom.backend.dtos.BookUpdateDto;
import com.sofrecom.backend.dtos.UserUpdateDto;
import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.services.IBookService;
import com.sofrecom.backend.services.IUserService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
@RestController
@RequestMapping("/books")
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
    public ResponseEntity<Book> addBook(@RequestBody Book book) {
        if (book.getOwnerId() == null) {
            throw new IllegalArgumentException("L'ownerId est obligatoire !");
        }

        User owner = userService.findById(book.getOwnerId());
        if (owner == null) {
            throw new EntityNotFoundException("Utilisateur non trouvé avec l'ID : " + book.getOwnerId());
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
    public ResponseEntity<List<Book>> getBooksByUser(@PathVariable Long userId) {
        var userDto = userService.getUserById(userId);
        if (userDto == null) {
            throw new EntityNotFoundException("User not found with id: " + userId);
        }

        List<Book> books = bookService.getBooksByUser(userId);
        return ResponseEntity.ok(books);
    }


    @GetMapping("/checkOwnerBookByEmail/{email}/{id}")
    public boolean checkOwnerBookByEmail(@PathVariable String email, @PathVariable Long id) {
        return this.bookService.checkOwnerBookByEmail(email,id);
    }

    @GetMapping("/allBookWithinEmailOwner/{email}")
    public List<Book> getAllBooksWithinEmailOwner(@PathVariable String email) {
        return this.bookService.getAllBooksWithinEmailOwner(email);
    }

    @GetMapping("/getBookOwner/{idbook}")
    public BookOwerDto getBookOwner(@PathVariable Long idbook) {

        return this.bookService.getBookOwnerById(idbook);
    }

    @DeleteMapping("/{id}")
    public void deleteBook(@PathVariable Long id) {
        bookService.deleteBook(id);
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Book> updateBook(@PathVariable Long id, @RequestBody BookUpdateDto book) {
        Book updatedBook = bookService.updateBook(id, book);
        return ResponseEntity.ok(updatedBook);
    }


    @PostMapping("/add/socket/{email}")
    public Book updateBook(@RequestBody Book book, @PathVariable String email) {
        return bookService.AddBookSocket(book,email);
    }


}
