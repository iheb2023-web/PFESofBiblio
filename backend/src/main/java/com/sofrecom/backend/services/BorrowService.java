package com.sofrecom.backend.services;


import com.sofrecom.backend.entities.Borrow;
import com.sofrecom.backend.enums.BorrowStatus;
import com.sofrecom.backend.repositories.BorrowRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@RequiredArgsConstructor
@Service
public class BorrowService implements IBorrowService {
    private final BorrowRepository borrowRepository;

    public List<Borrow> findAll() {
        return borrowRepository.findAll();
    }

    public Borrow borrowBook(Borrow borrow) {
        borrow.setRequestDate(LocalDate.now());

        borrow.setBorrowStatus(BorrowStatus.PENDING);
        return borrowRepository.save(borrow);
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
}
