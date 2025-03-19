package com.sofrecom.backend.services;

import com.sofrecom.backend.entities.Borrow;

import java.util.List;

public interface IBorrowService {
    public List<Borrow> findAll();
    public Borrow borrowBook(Borrow borrow);
    public Borrow  processBorrowRequest(Borrow borrow, boolean isApproved);

    Borrow getBorrowById(Long id);
}
