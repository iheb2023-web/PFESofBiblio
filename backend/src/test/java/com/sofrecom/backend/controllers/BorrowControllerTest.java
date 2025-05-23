package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.BorrowStatusUser;
import com.sofrecom.backend.dtos.OccupiedDates;
import com.sofrecom.backend.entities.Borrow;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.enums.BorrowStatus;
import com.sofrecom.backend.services.IBorrowService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BorrowControllerTest {

    @Mock
    private IBorrowService borrowService;

    @InjectMocks
    private BorrowController borrowController;

    private Borrow borrow;
    private BorrowStatusUser borrowStatusUser;
    private OccupiedDates occupiedDates;

    @BeforeEach
    void setUp() {
        borrow = new Borrow();
        borrow.setId(1L);
        User borrower = new User();
        borrower.setEmail("test@example.com");
        borrow.setBorrower(borrower);
        borrow.setBorrowStatus(BorrowStatus.RETURNED);
        borrow.setRequestDate(LocalDate.of(2025, 6, 1));
        borrow.setExpectedReturnDate(LocalDate.of(2025, 6, 15));

        borrowStatusUser = new BorrowStatusUser();


        occupiedDates = new OccupiedDates();
        occupiedDates.setFrom(LocalDate.of(2025, 6, 1));
        occupiedDates.setTo(LocalDate.of(2025, 6, 15));
    }

    @Test
    void getAllBorrows_Success() {
        when(borrowService.findAll()).thenReturn(Collections.singletonList(borrow));

        List<Borrow> result = borrowController.getAllBorrows();

        assertEquals(1, result.size());
        assertEquals(1L, result.get(0).getId());
        assertEquals("test@example.com", result.get(0).getBorrower().getEmail());
        verify(borrowService).findAll();
    }

    @Test
    void getAllBorrows_EmptyList_Success() {
        when(borrowService.findAll()).thenReturn(Collections.emptyList());

        List<Borrow> result = borrowController.getAllBorrows();

        assertTrue(result.isEmpty());
        verify(borrowService).findAll();
    }

    @Test
    void borrowBook_Success() {
        doNothing().when(borrowService).borrowBook(any(Borrow.class));

        borrowController.borrowBook(borrow);

        verify(borrowService).borrowBook(any(Borrow.class));
    }

    @Test
    void getBorrowById_Success() {
        when(borrowService.getBorrowById(eq(1L))).thenReturn(borrow);

        Borrow result = borrowController.getBorrowById(1L);

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("test@example.com", result.getBorrower().getEmail());
        verify(borrowService).getBorrowById(eq(1L));
    }

    @Test
    void processBorrowRequest_Success() {
        when(borrowService.processBorrowRequest(any(Borrow.class), eq(true))).thenReturn(borrow);

        Borrow result = borrowController.processBorrowRequest(borrow, "true");

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("test@example.com", result.getBorrower().getEmail());
        verify(borrowService).processBorrowRequest(any(Borrow.class), eq(true));
    }

    @Test
    void getBorrowDemandsByUserEmail_Success() {
        when(borrowService.getBorrowDemandsByUserEmail(eq("test@example.com"))).thenReturn(Collections.singletonList(borrow));

        List<Borrow> result = borrowController.getBorrowDemandsByUserEmail("test@example.com");

        assertEquals(1, result.size());
        assertEquals(1L, result.get(0).getId());
        assertEquals("test@example.com", result.get(0).getBorrower().getEmail());
        verify(borrowService).getBorrowDemandsByUserEmail(eq("test@example.com"));
    }

    @Test
    void getBorrowDemandsByUserEmail_EmptyList_Success() {
        when(borrowService.getBorrowDemandsByUserEmail(eq("test@example.com"))).thenReturn(Collections.emptyList());

        List<Borrow> result = borrowController.getBorrowDemandsByUserEmail("test@example.com");

        assertTrue(result.isEmpty());
        verify(borrowService).getBorrowDemandsByUserEmail(eq("test@example.com"));
    }

    @Test
    void getBorrowRequestsByUserEmail_Success() {
        when(borrowService.getBorrowRequestsByUserEmail(eq("test@example.com"))).thenReturn(Collections.singletonList(borrow));

        List<Borrow> result = borrowController.getBorrowRequestsByUserEmail("test@example.com");

        assertEquals(1, result.size());
        assertEquals(1L, result.get(0).getId());
        assertEquals("test@example.com", result.get(0).getBorrower().getEmail());
        verify(borrowService).getBorrowRequestsByUserEmail(eq("test@example.com"));
    }

    @Test
    void getBorrowRequestsByUserEmail_EmptyList_Success() {
        when(borrowService.getBorrowRequestsByUserEmail(eq("test@example.com"))).thenReturn(Collections.emptyList());

        List<Borrow> result = borrowController.getBorrowRequestsByUserEmail("test@example.com");

        assertTrue(result.isEmpty());
        verify(borrowService).getBorrowRequestsByUserEmail(eq("test@example.com"));
    }

    @Test
    void getBorrowStatusUserByEmail_Success() {
        when(borrowService.getBorrowStatusUserByEmail(eq("test@example.com"))).thenReturn(borrowStatusUser);

        BorrowStatusUser result = borrowController.getBorrowStatusUserByEmail("test@example.com");

        assertNotNull(result);
        verify(borrowService).getBorrowStatusUserByEmail(eq("test@example.com"));
    }

    @Test
    void getBookOccupiedDatesByBookId_Success() {
        when(borrowService.getBookOccupiedDatesByBookId(eq(1L))).thenReturn(Collections.singletonList(occupiedDates));

        List<OccupiedDates> result = borrowController.getBookOccupiedDatesByBookId(1L);

        assertEquals(1, result.size());
        assertEquals(LocalDate.of(2025, 6, 1), result.get(0).getFrom());
        assertEquals(LocalDate.of(2025, 6, 15), result.get(0).getTo());
        verify(borrowService).getBookOccupiedDatesByBookId(eq(1L));
    }

    @Test
    void getBookOccupiedDatesByBookId_EmptyList_Success() {
        when(borrowService.getBookOccupiedDatesByBookId(eq(1L))).thenReturn(Collections.emptyList());

        List<OccupiedDates> result = borrowController.getBookOccupiedDatesByBookId(1L);

        assertTrue(result.isEmpty());
        verify(borrowService).getBookOccupiedDatesByBookId(eq(1L));
    }

    @Test
    void cancelWhileInProgress_Success() {
        doNothing().when(borrowService).cancelWhileInProgress(eq(1L));

        borrowController.cancelWhileInProgress(1L);

        verify(borrowService).cancelWhileInProgress(eq(1L));
    }

    @Test
    void cancelPendingOrApproved_Success() {
        doNothing().when(borrowService).cancelPendingOrApproved(eq(1L));

        borrowController.cancelPendingOrApproved(1L);

        verify(borrowService).cancelPendingOrApproved(eq(1L));
    }

    @Test
    void getBookOccupiedDatesUpdatedBorrow_Success() {
        when(borrowService.getBookOccupiedDatesUpdatedBorrow(eq(1L), eq(1L))).thenReturn(Collections.singletonList(occupiedDates));

        List<OccupiedDates> result = borrowController.getBookOccupiedDatesUpdatedBorrow(1L, 1L);

        assertEquals(1, result.size());
        assertEquals(LocalDate.of(2025, 6, 1), result.get(0).getFrom());
        assertEquals(LocalDate.of(2025, 6, 15), result.get(0).getTo());
        verify(borrowService).getBookOccupiedDatesUpdatedBorrow(eq(1L), eq(1L));
    }

    @Test
    void getBookOccupiedDatesUpdatedBorrow_EmptyList_Success() {
        when(borrowService.getBookOccupiedDatesUpdatedBorrow(eq(1L), eq(1L))).thenReturn(Collections.emptyList());

        List<OccupiedDates> result = borrowController.getBookOccupiedDatesUpdatedBorrow(1L, 1L);

        assertTrue(result.isEmpty());
        verify(borrowService).getBookOccupiedDatesUpdatedBorrow(eq(1L), eq(1L));
    }

    @Test
    void updateBorrowWhilePending_Success() {
        when(borrowService.updateBorrowWhilePending(any(Borrow.class))).thenReturn(borrow);

        Borrow result = borrowController.updateBorrowWhilePending(borrow);

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("test@example.com", result.getBorrower().getEmail());
        verify(borrowService).updateBorrowWhilePending(any(Borrow.class));
    }

    @Test
    void markAsReturned_Success() {
        doNothing().when(borrowService).markAsReturned(eq(1L));

        borrowController.markAsReturned(1L);

        verify(borrowService).markAsReturned(eq(1L));
    }
}