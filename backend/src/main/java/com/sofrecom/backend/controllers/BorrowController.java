package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.BorrowStatusUser;
import com.sofrecom.backend.dtos.OccupiedDates;
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
    public void borrowBook(@RequestBody Borrow borrow)
    {
        this.borrowService.borrowBook(borrow);
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

    @GetMapping("/demands/{email}")
    public List<Borrow>  getBorrowDemandsByUserEmail(@PathVariable String email) {
        return this.borrowService.getBorrowDemandsByUserEmail(email);
    }



    @GetMapping("/requests/{email}")
    public List<Borrow>  getBorrowRequestsByUserEmail(@PathVariable String email) {
        return this.borrowService.getBorrowRequestsByUserEmail(email);
    }

    @GetMapping("/BorrowStatusUser/{email}")
    public BorrowStatusUser getBorrowStatusUserByEmail(@PathVariable String email) {
        return this.borrowService.getBorrowStatusUserByEmail(email);
    }

    @GetMapping("/BookOccupiedDates/{bookId}")
    public List<OccupiedDates> getBookOccupiedDatesByBookId(@PathVariable Long bookId) {
        return this.borrowService.getBookOccupiedDatesByBookId(bookId);
    }

    @PutMapping("/cancelWhileInProgress/{idBorrow}")
    public void cancelWhileInProgress(@PathVariable Long idBorrow) {
        this.borrowService.cancelWhileInProgress(idBorrow);
    }

    @DeleteMapping("/cancelPendingOrApproved/{idBorrow}")
    public void cancelPendingOrApproved(@PathVariable Long idBorrow) {
        this.borrowService.cancelPendingOrApproved(idBorrow);
    }

    @GetMapping("/getBookOccupiedDatesUpdatedBorrow/{bookId}/{borrowId}")
    public List<OccupiedDates> getBookOccupiedDatesUpdatedBorrow(@PathVariable Long bookId , @PathVariable Long borrowId) {
        return this.borrowService.getBookOccupiedDatesUpdatedBorrow(bookId, borrowId);
    }

    @PutMapping("/updateBorrowWhilePending")
    public Borrow updateBorrowWhilePending(@RequestBody Borrow borrow) {
         return this.borrowService.updateBorrowWhilePending(borrow);
    }


    @PutMapping("/markAsReturned/{idBorrow}")
    public void markAsReturned(@PathVariable Long idBorrow)
    {
        this.borrowService.markAsReturned(idBorrow);
    }




}
