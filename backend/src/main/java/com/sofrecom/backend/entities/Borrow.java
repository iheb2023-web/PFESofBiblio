package com.sofrecom.backend.entities;

import com.sofrecom.backend.enums.BorrowStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDate;

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


    @ManyToOne
    private User borrower;


    @ManyToOne
    @JoinColumn(name = "book_id", nullable = false) // NOSONAR
    private Book book;

}
