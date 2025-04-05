package com.sofrecom.backend.services;


import com.sofrecom.backend.dtos.BorrowStatusUser;
import com.sofrecom.backend.dtos.OccupiedDates;
import com.sofrecom.backend.dtos.UserDto;
import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.entities.Borrow;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.enums.BorrowStatus;
import com.sofrecom.backend.repositories.BorrowRepository;
import com.sofrecom.backend.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@RequiredArgsConstructor
@Service
public class BorrowService implements IBorrowService {
    private final BorrowRepository borrowRepository;
    private final UserRepository userRepository;

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

        //tester disponiblity of book in that period
        //this.borrowRepository.findBorrowByD


        borrow.setBorrowStatus(BorrowStatus.PENDING);
        borrowRepository.save(borrow);
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
        return stats;
    }

    @Override
    public List<OccupiedDates> getBookOccupiedDatesByBookId(Long bookId) {
        return this.borrowRepository.getBookOccupiedDatesByBookId(bookId);
    }
}
