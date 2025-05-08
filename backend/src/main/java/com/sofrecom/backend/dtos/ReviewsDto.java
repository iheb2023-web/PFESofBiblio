package com.sofrecom.backend.dtos;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ReviewsDto {
    private Long id;
    private String content;
    private int rating;
    private Long bookId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private UserReviewsDto userReviewsDto;

    public ReviewsDto(Long id, Long bookId, String content, int rating,
                      LocalDateTime createdAt, LocalDateTime updatedAt,
                      UserReviewsDto userReviewsDto) {
        this.id = id;
        this.bookId = bookId;
        this.content = content;
        this.rating = rating;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.userReviewsDto = userReviewsDto;
    }


}
