package com.sofrecom.backend.dtos;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class BookUpdateDto {
    private Long id;
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
