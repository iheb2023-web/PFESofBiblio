package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.ReviewsDto;
import com.sofrecom.backend.entities.Reviews;
import com.sofrecom.backend.services.IReviewsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/reviews")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class ReviewsController {
    private final IReviewsService reviewsService;


    @PostMapping("")
    public Reviews addReviews(@RequestBody Reviews reviews) {
        return this.reviewsService.addReviews(reviews);
    }

    @GetMapping
    public List<Reviews> getAllReviews() {
        return this.reviewsService.getAllReviews();
    }

    @GetMapping("/{id}")
    public List<ReviewsDto> getReviewsByIdBook(@PathVariable Long id) {
        return this.reviewsService.getReviewsByIdBook(id);
    }
    @PutMapping("/{idReview}")
    public Reviews updateReviews(@PathVariable Long idReview, @RequestBody Reviews reviews) {
        return this.reviewsService.updateReviews(idReview,reviews);
    }

    @DeleteMapping("/{id}")
    public void deleteReviews(@PathVariable Long id) {
        this.reviewsService.deleteReviews(id);
    }

    @GetMapping("/getReviewById/{id}")
    public Reviews getReviewById(@PathVariable Long id) {
        return this.reviewsService.getReviewById(id);
    }
}
