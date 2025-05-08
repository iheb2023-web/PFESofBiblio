package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.BorrowStatusUser;
import com.sofrecom.backend.dtos.OccupiedDates;
import com.sofrecom.backend.entities.Borrow;

import java.util.List;

public interface IBorrowService {
    public List<Borrow> findAll();
    public void borrowBook(Borrow borrow);
    public Borrow  processBorrowRequest(Borrow borrow, boolean isApproved);

    Borrow getBorrowById(Long id);

    List<Borrow>  getBorrowDemandsByUserEmail(String email);


    List<Borrow> getBorrowRequestsByUserEmail(String email);

    BorrowStatusUser getBorrowStatusUserByEmail(String email);

    List<OccupiedDates> getBookOccupiedDatesByBookId(Long bookId);

    void cancelWhileInProgress(Long idBorrow);

    void cancelPendingOrApproved(Long idBorrow);

    List<OccupiedDates> getBookOccupiedDatesUpdatedBorrow(Long bookId, Long borrowId);

    Borrow updateBorrowWhilePending(Borrow borrow);

    void markAsReturned(Long idBorrow);
}
