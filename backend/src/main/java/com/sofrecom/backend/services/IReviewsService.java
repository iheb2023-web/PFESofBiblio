package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.ReviewsDto;
import com.sofrecom.backend.entities.Reviews;

import java.util.List;

public interface IReviewsService {
    Reviews addReviews(Reviews reviews);

    List<Reviews> getAllReviews();

    List<ReviewsDto> getReviewsByIdBook(Long id);
}
