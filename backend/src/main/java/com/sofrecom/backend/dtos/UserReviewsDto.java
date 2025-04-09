package com.sofrecom.backend.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserReviewsDto {
    private Long id;
    private String email;
    private String firstname;
    private String lastname;
    private String image;
}
