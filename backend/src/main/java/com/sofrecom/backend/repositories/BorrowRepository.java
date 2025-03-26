package com.sofrecom.backend.repositories;

import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.entities.Borrow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface BorrowRepository extends JpaRepository<Borrow, Long> {

    @Query("SELECT  b FROM Borrow b WHERE b.book.owner.email = :email AND b.BorrowStatus = 'PENDING'")
    List<Borrow> findBorrowDemandsByOwnerEmail(@Param("email") String email);

    @Query("SELECT  b FROM Borrow b WHERE b.borrower.email = :email")
    List<Borrow> getBorrowRequestsByUserEmail(@Param("email") String email);
}
