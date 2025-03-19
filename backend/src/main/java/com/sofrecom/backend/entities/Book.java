package com.sofrecom.backend.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private  Long id;
    private String title;
    private String author;
    private String description;
    private String coverUrl;
    private String publishedDate;
    private String isbn;
    private String category;
    private int pageCount;
    private String language;

    @JsonIgnore
    @ManyToOne
    private User owner;



}
