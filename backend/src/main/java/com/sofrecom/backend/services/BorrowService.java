package com.sofrecom.backend.services;


import com.sofrecom.backend.dtos.BorrowStatusUser;
import com.sofrecom.backend.dtos.OccupiedDates;
import com.sofrecom.backend.entities.Borrow;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.enums.BorrowStatus;
import com.sofrecom.backend.repositories.BorrowRepository;
import com.sofrecom.backend.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@RequiredArgsConstructor
@Service
public class BorrowService implements IBorrowService {
    private final BorrowRepository borrowRepository;
    private final UserRepository userRepository;
    private final SocketIOService socketIOService;

    public List<Borrow> findAll() {
        return borrowRepository.findAll();
    }

    public void borrowBook(Borrow borrow) {
        borrow.setRequestDate(LocalDate.now());
        User user = this.userRepository.findByEmail(borrow.getBorrower().getEmail()).orElse(null);
        User borrower = borrow.getBorrower();
        if (user != null) {
            borrower.setId(user.getId());
        }
        borrow.setBorrower(borrower);

        borrow.setBorrowStatus(BorrowStatus.PENDING);
        Borrow b =borrowRepository.save(borrow);
        socketIOService.sendDemandNotification(b.getId());
    }

    public Borrow  processBorrowRequest(Borrow borrow, boolean isApproved)
    {
        borrow.setResponseDate(LocalDate.now());
        if(isApproved)
        {
            borrow.setBorrowStatus(BorrowStatus.APPROVED);
        }else
        {
            borrow.setBorrowStatus(BorrowStatus.REJECTED);
        }

        socketIOService.sendProcessBorrowRequestNotification(borrow.getId());
        return borrowRepository.save(borrow);
    }

    @Override
    public Borrow getBorrowById(Long id) {
        return this.borrowRepository.findById(id).orElse(null);
    }

    @Override
    public List<Borrow> getBorrowDemandsByUserEmail(String email) {
        return this.borrowRepository.findBorrowDemandsByOwnerEmail(email);
    }

    @Override
    public List<Borrow> getBorrowRequestsByUserEmail(String email) {
        return this.borrowRepository.getBorrowRequestsByUserEmail(email);
    }

    @Override
    public BorrowStatusUser getBorrowStatusUserByEmail(String email) {
        BorrowStatusUser stats =  new BorrowStatusUser();
        stats.setApproved(this.borrowRepository.getTotalApprovedRequestByEmail(email));
        stats.setPending(this.borrowRepository.getTotalPendingRequestByEmail(email));
        stats.setProgress(this.borrowRepository.getTotalProgressRequestByEmail(email));
        stats.setRejected(this.borrowRepository.getTotalRejectRequestByEmail(email));
        stats.setReturned(this.borrowRepository.getTotalReturnedRequestByEmail(email));
        return stats;
    }

    @Override
    public List<OccupiedDates> getBookOccupiedDatesByBookId(Long bookId) {
        return this.borrowRepository.getBookOccupiedDatesByBookId(bookId);
    }

    //@Scheduled(cron = "0 0 0 * * *")
    @Scheduled(fixedRate = 15000) // every 10 seconds
   // @Scheduled(cron = "0 * * * * *") // every minute
    public void updateBorrowStatuses() {
        List<Borrow> borrows = this.borrowRepository.findApprovedBorrowsToday();
        for (Borrow borrow : borrows) {
            borrow.setBorrowStatus(BorrowStatus.IN_PROGRESS);
        }
        borrowRepository.saveAll(borrows);
    }

    //@Scheduled(cron = "0 0 0 * * *")
    //@Scheduled(fixedRate = 15000) // every 10 seconds
    //@Scheduled(cron = "0 * * * * *") // every minute
    public void updateBorrowStatusesToReturned() {
        List<Borrow> borrows = this.borrowRepository.findProgressBorrowsEndToday();
        for (Borrow borrow : borrows) {
            borrow.setBorrowStatus(BorrowStatus.RETURNED);
        }
        borrowRepository.saveAll(borrows);
    }


    @Override
    public void cancelPendingOrApproved(Long idBorrow) {
        this.borrowRepository.deleteById(idBorrow);
    }

    @Override
    public List<OccupiedDates> getBookOccupiedDatesUpdatedBorrow(Long bookId, Long borrowId) {
        return this.borrowRepository.getBookOccupiedDatesByBookIdForUpdatedBorrow(bookId, borrowId);
    }

    @Override
    public Borrow updateBorrowWhilePending(Borrow borrow) {
        borrow.setRequestDate(LocalDate.now());
        User user = this.userRepository.findByEmail(borrow.getBorrower().getEmail()).orElse(null);
        User borrower = borrow.getBorrower();
        if (user != null) {
            borrower.setId(user.getId());
        }
        borrow.setBorrower(borrower);
        borrow.setBorrowStatus(BorrowStatus.PENDING);

        socketIOService.sendDemandNotification(borrow.getId());
        return this.borrowRepository.save(borrow);
    }

    @Override
    public void markAsReturned(Long idBorrow) {
        Borrow borrow= this.borrowRepository.findById(idBorrow).orElse(null);
        assert borrow != null;
        borrow.setBorrowStatus(BorrowStatus.RETURNED);
        this.borrowRepository.save(borrow);

    }


    @Override
    public void cancelWhileInProgress(Long idBorrow) {
        Borrow borrow = this.borrowRepository.findById(idBorrow).orElse(null);
        assert borrow != null;
        borrow.setBorrowStatus(BorrowStatus.RETURNED);
        borrow.setExpectedReturnDate(LocalDate.now());
        this.borrowRepository.save(borrow);

    }
}
