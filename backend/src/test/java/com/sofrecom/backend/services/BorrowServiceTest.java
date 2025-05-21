package com.sofrecom.backend.services;

import static org.junit.jupiter.api.Assertions.*;
import com.sofrecom.backend.dtos.BorrowStatusUser;
import com.sofrecom.backend.dtos.OccupiedDates;
import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.entities.Borrow;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.enums.BorrowStatus;
import com.sofrecom.backend.repositories.BorrowRepository;
import com.sofrecom.backend.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BorrowServiceTest {

    @Mock
    private BorrowRepository borrowRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SocketIOService socketIOService;

    @InjectMocks
    private BorrowService borrowService;

    private Borrow borrow;
    private User borrower;
    private Book book;

    @BeforeEach
    void setUp() {
        borrower = new User();
        borrower.setId(1L);
        borrower.setEmail("borrower@example.com");

        book = new Book();
        book.setId(1L);

        borrow = new Borrow();
        borrow.setId(1L);
        borrow.setBorrower(borrower);
        borrow.setBook(book);
        borrow.setBorrowStatus(BorrowStatus.PENDING);
    }

    @Test
    void findAll_ShouldReturnAllBorrows() {
        List<Borrow> borrows = Arrays.asList(borrow);
        when(borrowRepository.findAll()).thenReturn(borrows);

        List<Borrow> result = borrowService.findAll();

        assertEquals(1, result.size());
        verify(borrowRepository).findAll();
    }

    @Test
    void borrowBook_ShouldSetRequestDateAndSave() {
        when(userRepository.findByEmail("borrower@example.com")).thenReturn(Optional.of(borrower));
        when(borrowRepository.save(any(Borrow.class))).thenReturn(borrow);

        borrowService.borrowBook(borrow);

        assertEquals(LocalDate.now(), borrow.getRequestDate());
        assertEquals(BorrowStatus.PENDING, borrow.getBorrowStatus());
        verify(borrowRepository).save(borrow);
        verify(socketIOService).sendDemandNotification(borrow.getId());
    }

    @Test
    void processBorrowRequest_Approved_ShouldUpdateStatus() {
        when(borrowRepository.save(any(Borrow.class))).thenReturn(borrow);

        Borrow result = borrowService.processBorrowRequest(borrow, true);

        assertEquals(LocalDate.now(), result.getResponseDate());
        assertEquals(BorrowStatus.APPROVED, result.getBorrowStatus());
        verify(borrowRepository).save(borrow);
        verify(socketIOService).sendProcessBorrowRequestNotification(borrow.getId());
    }

    @Test
    void processBorrowRequest_Rejected_ShouldUpdateStatus() {
        when(borrowRepository.save(any(Borrow.class))).thenReturn(borrow);

        Borrow result = borrowService.processBorrowRequest(borrow, false);

        assertEquals(LocalDate.now(), result.getResponseDate());
        assertEquals(BorrowStatus.REJECTED, result.getBorrowStatus());
        verify(borrowRepository).save(borrow);
        verify(socketIOService).sendProcessBorrowRequestNotification(borrow.getId());
    }

    @Test
    void getBorrowById_ExistingId_ShouldReturnBorrow() {
        when(borrowRepository.findById(1L)).thenReturn(Optional.of(borrow));

        Borrow result = borrowService.getBorrowById(1L);

        assertNotNull(result);
        assertEquals(borrow.getId(), result.getId());
        verify(borrowRepository).findById(1L);
    }

    @Test
    void getBorrowById_NonExistingId_ShouldReturnNull() {
        when(borrowRepository.findById(1L)).thenReturn(Optional.empty());

        Borrow result = borrowService.getBorrowById(1L);

        assertNull(result);
        verify(borrowRepository).findById(1L);
    }

    @Test
    void getBorrowDemandsByUserEmail_ShouldReturnBorrows() {
        List<Borrow> borrows = Arrays.asList(borrow);
        when(borrowRepository.findBorrowDemandsByOwnerEmail("borrower@example.com")).thenReturn(borrows);

        List<Borrow> result = borrowService.getBorrowDemandsByUserEmail("borrower@example.com");

        assertEquals(1, result.size());
        verify(borrowRepository).findBorrowDemandsByOwnerEmail("borrower@example.com");
    }

    @Test
    void getBorrowRequestsByUserEmail_ShouldReturnBorrows() {
        List<Borrow> borrows = Arrays.asList(borrow);
        when(borrowRepository.getBorrowRequestsByUserEmail("borrower@example.com")).thenReturn(borrows);

        List<Borrow> result = borrowService.getBorrowRequestsByUserEmail("borrower@example.com");

        assertEquals(1, result.size());
        verify(borrowRepository).getBorrowRequestsByUserEmail("borrower@example.com");
    }

    @Test
    void getBorrowStatusUserByEmail_ShouldReturnStats() {
        when(borrowRepository.getTotalApprovedRequestByEmail("borrower@example.com")).thenReturn(1);
        when(borrowRepository.getTotalPendingRequestByEmail("borrower@example.com")).thenReturn(2);
        when(borrowRepository.getTotalProgressRequestByEmail("borrower@example.com")).thenReturn(3);
        when(borrowRepository.getTotalRejectRequestByEmail("borrower@example.com")).thenReturn(4);
        when(borrowRepository.getTotalReturnedRequestByEmail("borrower@example.com")).thenReturn(5);

        BorrowStatusUser result = borrowService.getBorrowStatusUserByEmail("borrower@example.com");

        assertEquals(1, result.getApproved());
        assertEquals(2, result.getPending());
        assertEquals(3, result.getProgress());
        assertEquals(4, result.getRejected());
        assertEquals(5, result.getReturned());
    }

    @Test
    void getBookOccupiedDatesByBookId_ShouldReturnDates() {
        List<OccupiedDates> dates = Arrays.asList(new OccupiedDates());
        when(borrowRepository.getBookOccupiedDatesByBookId(1L)).thenReturn(dates);

        List<OccupiedDates> result = borrowService.getBookOccupiedDatesByBookId(1L);

        assertEquals(1, result.size());
        verify(borrowRepository).getBookOccupiedDatesByBookId(1L);
    }

    @Test
    void updateBorrowStatuses_ShouldUpdateApprovedToInProgress() {
        borrow.setBorrowStatus(BorrowStatus.APPROVED);
        List<Borrow> borrows = Arrays.asList(borrow);
        when(borrowRepository.findApprovedBorrowsToday()).thenReturn(borrows);
        when(borrowRepository.saveAll(borrows)).thenReturn(borrows);

        borrowService.updateBorrowStatuses();

        assertEquals(BorrowStatus.IN_PROGRESS, borrow.getBorrowStatus());
        verify(borrowRepository).findApprovedBorrowsToday();
        verify(borrowRepository).saveAll(borrows);
    }

    @Test
    void updateBorrowStatusesToReturned_ShouldUpdateProgressToReturned() {
        borrow.setBorrowStatus(BorrowStatus.IN_PROGRESS);
        List<Borrow> borrows = Arrays.asList(borrow);
        when(borrowRepository.findProgressBorrowsEndToday()).thenReturn(borrows);
        when(borrowRepository.saveAll(borrows)).thenReturn(borrows);

        borrowService.updateBorrowStatusesToReturned();

        assertEquals(BorrowStatus.RETURNED, borrow.getBorrowStatus());
        verify(borrowRepository).findProgressBorrowsEndToday();
        verify(borrowRepository).saveAll(borrows);
    }

    @Test
    void cancelPendingOrApproved_ShouldDeleteBorrow() {
        borrowService.cancelPendingOrApproved(1L);

        verify(borrowRepository).deleteById(1L);
    }

    @Test
    void getBookOccupiedDatesUpdatedBorrow_ShouldReturnDates() {
        List<OccupiedDates> dates = Arrays.asList(new OccupiedDates());
        when(borrowRepository.getBookOccupiedDatesByBookIdForUpdatedBorrow(1L, 1L)).thenReturn(dates);

        List<OccupiedDates> result = borrowService.getBookOccupiedDatesUpdatedBorrow(1L, 1L);

        assertEquals(1, result.size());
        verify(borrowRepository).getBookOccupiedDatesByBookIdForUpdatedBorrow(1L, 1L);
    }

    @Test
    void updateBorrowWhilePending_ShouldUpdateAndSave() {
        when(userRepository.findByEmail("borrower@example.com")).thenReturn(Optional.of(borrower));
        when(borrowRepository.save(any(Borrow.class))).thenReturn(borrow);

        Borrow result = borrowService.updateBorrowWhilePending(borrow);

        assertEquals(LocalDate.now(), result.getRequestDate());
        assertEquals(BorrowStatus.PENDING, result.getBorrowStatus());
        assertEquals(borrower.getId(), result.getBorrower().getId());
        verify(borrowRepository).save(borrow);
        verify(socketIOService).sendDemandNotification(borrow.getId());
    }

    @Test
    void markAsReturned_ShouldUpdateStatusToReturned() {
        when(borrowRepository.findById(1L)).thenReturn(Optional.of(borrow));
        when(borrowRepository.save(any(Borrow.class))).thenReturn(borrow);

        borrowService.markAsReturned(1L);

        assertEquals(BorrowStatus.RETURNED, borrow.getBorrowStatus());
        verify(borrowRepository).findById(1L);
        verify(borrowRepository).save(borrow);
    }

    @Test
    void cancelWhileInProgress_ShouldUpdateStatusAndDate() {
        when(borrowRepository.findById(1L)).thenReturn(Optional.of(borrow));
        when(borrowRepository.save(any(Borrow.class))).thenReturn(borrow);

        borrowService.cancelWhileInProgress(1L);

        assertEquals(BorrowStatus.RETURNED, borrow.getBorrowStatus());
        assertEquals(LocalDate.now(), borrow.getExpectedReturnDate());
        verify(borrowRepository).findById(1L);
        verify(borrowRepository).save(borrow);
    }
}