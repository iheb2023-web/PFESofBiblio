package com.sofrecom.backend.controllers;

import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.entities.Borrow;
import com.sofrecom.backend.services.IBorrowService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/borrows")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class BorrowController {
    private final IBorrowService borrowService;

    @GetMapping
    public List<Borrow> getAllBorrows() {
        return this.borrowService.findAll();
    }

    @PostMapping()
    public Borrow borrowBook(@RequestBody Borrow borrow)
    {
        return this.borrowService.borrowBook(borrow);
    }

    @GetMapping("/{id}")
    public Borrow getBorrowById(@PathVariable Long id) {
        return this.borrowService.getBorrowById(id);
    }

    @PutMapping("/approved/{isApproved}")
    public Borrow  processBorrowRequest(@RequestBody  Borrow borrow,@PathVariable String isApproved)
    {
        boolean approved = Boolean.parseBoolean(isApproved);
        return this.borrowService.processBorrowRequest(borrow,approved);
    }

}
