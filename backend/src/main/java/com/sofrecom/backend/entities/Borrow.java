package com.sofrecom.backend.entities;

import com.sofrecom.backend.enums.BorrowStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDate;

@SuppressWarnings("java:S7027")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity // NOSONAR
public class Borrow implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private LocalDate requestDate;
    private LocalDate responseDate;
    private LocalDate borrowDate;
    private LocalDate expectedReturnDate;
    private int numberOfRenewals ;
    @Enumerated(EnumType.STRING)
    private BorrowStatus BorrowStatus; // NOSONAR


    @SuppressWarnings("java:S7027")
    @ManyToOne // NOSONAR
    private User borrower;

    @SuppressWarnings("java:S7027")
    @ManyToOne
    @JoinColumn(name = "book_id", nullable = false) // NOSONAR
    private Book book;

}
