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
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private UserReviewsDto userReviewsDto;


}
