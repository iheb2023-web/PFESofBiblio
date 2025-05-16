package com.sofrecom.backend.repositories;

import com.sofrecom.backend.dtos.OccupiedDates;
import com.sofrecom.backend.entities.Borrow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface BorrowRepository extends JpaRepository<Borrow, Long> {

    @Query("SELECT b FROM Borrow b WHERE b.book.owner.email = :email AND b.BorrowStatus IN ('PENDING', 'IN_PROGRESS', 'APPROVED')")
    List<Borrow> findBorrowDemandsByOwnerEmail(@Param("email") String email);

    @Query("SELECT  b FROM Borrow b WHERE b.borrower.email = :email")
    List<Borrow> getBorrowRequestsByUserEmail(@Param("email") String email);

    @Query("select count(b) from Borrow b   where  b.BorrowStatus = 'REJECTED' AND b.borrower.email = :email")
    int getTotalRejectRequestByEmail(@Param("email") String email);

    @Query("select count(b) from Borrow b   where  b.BorrowStatus = 'APPROVED' AND b.borrower.email = :email")
    int getTotalApprovedRequestByEmail(@Param("email") String email);

    @Query("select count(b) from Borrow b   where  b.BorrowStatus = 'PENDING' AND b.borrower.email = :email")
    int getTotalPendingRequestByEmail(@Param("email") String email);

    @Query("select count(b) from Borrow b   where  b.BorrowStatus = 'IN_PROGRESS' AND b.borrower.email = :email")
    int getTotalProgressRequestByEmail(@Param("email") String email);

    @Query("select count(b) from Borrow b   where  b.BorrowStatus = 'RETURNED' AND b.borrower.email = :email")
    int getTotalReturnedRequestByEmail(@Param("email") String email);

    @Query("SELECT NEW com.sofrecom.backend.dtos.OccupiedDates(b.borrowDate, b.expectedReturnDate) " +
            "FROM Borrow b " +
            "WHERE (b.BorrowStatus = 'IN_PROGRESS' OR b.BorrowStatus = 'APPROVED' OR b.BorrowStatus = 'PENDING') " +
            "AND b.book.id = :bookId " +
            "AND b.borrowDate >= CURRENT_DATE")
    List<OccupiedDates> getBookOccupiedDatesByBookId(@Param("bookId") Long bookId);


    @Query("select b from Borrow b where b.borrowDate = CURRENT_DATE and b.BorrowStatus = 'APPROVED'")
    List<Borrow> findApprovedBorrowsToday();

    @Query("select b from Borrow b where b.expectedReturnDate = CURRENT_DATE and b.BorrowStatus = 'IN_PROGRESS'")
    List<Borrow> findProgressBorrowsEndToday();


    @Query("SELECT NEW com.sofrecom.backend.dtos.OccupiedDates(b.borrowDate, b.expectedReturnDate) " +
            "FROM Borrow b " +
            "WHERE (b.BorrowStatus = 'IN_PROGRESS' OR b.BorrowStatus = 'APPROVED' OR b.BorrowStatus = 'PENDING') " +
            "AND b.book.id = :bookId  AND b.id != :borrowId " +
            "AND b.borrowDate >= CURRENT_DATE")
    List<OccupiedDates> getBookOccupiedDatesByBookIdForUpdatedBorrow(@Param("bookId") Long bookId, @Param("borrowId") Long borrowId);

}
