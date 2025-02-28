package com.sofrecom.backend.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
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

}
