package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.ReviewsDto;
import com.sofrecom.backend.entities.Reviews;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.repositories.ReviewsRepository;
import com.sofrecom.backend.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@RequiredArgsConstructor
@Service
public class ReviewsService implements IReviewsService {
    private final ReviewsRepository reviewsRepository;
    private final UserRepository userRepository;

    @Override
    public Reviews addReviews(Reviews reviews) {
        User user = userRepository.findByEmail(reviews.getUser().getEmail()).orElse(null);
        reviews.setUser(user);
        reviews.setCreatedAt(LocalDateTime.now());
        return reviewsRepository.save(reviews);

    }

    @Override
    public List<Reviews> getAllReviews() {
        return this.reviewsRepository.findAll();
    }

    @Override
    public List<ReviewsDto> getReviewsByIdBook(Long id) {
        return this.reviewsRepository.getReviewsByIdBook(id);
    }

}
