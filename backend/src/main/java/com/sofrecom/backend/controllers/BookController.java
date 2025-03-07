package com.sofrecom.backend.controllers;

import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.services.IBookService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/books")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class BookController {
    private final IBookService bookService;


    @Operation(summary = "Add book", description = "Add new book")
    @PostMapping("")
    public ResponseEntity<Book> registerUser(@RequestBody Book request) {
        Book response = bookService.addBook(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("")
    public List<Book> getAllBooks() {
        return this.bookService.getAll();
    }


}
