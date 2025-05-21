package com.sofrecom.backend.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.List;

@SuppressWarnings("java:S7027")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity // NOSONAR
public class Book implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String author;
    @Column(length = 3000)
    private String description;
    private String coverUrl;
    private String publishedDate;
    private String isbn;
    private String category;
    private int pageCount;
    private String language;
    private LocalDate AddedDate;

    @Transient
    private Long ownerId;

    @SuppressWarnings("java:S7027")
    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "owner_id") // NOSONAR
    private User owner;

    @SuppressWarnings("java:S7027")
    @JsonIgnore
    @OneToMany(mappedBy = "book") // NOSONAR
    private List<Borrow> borrows;


}
