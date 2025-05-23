package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.ReviewsDto;
import com.sofrecom.backend.entities.Reviews;
import com.sofrecom.backend.services.IReviewsService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ReviewsControllerTest {

    @Mock
    private IReviewsService reviewsService;

    @InjectMocks
    private ReviewsController reviewsController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void addReviews_shouldReturnSavedReview() {
        Reviews review = new Reviews();
        when(reviewsService.addReviews(review)).thenReturn(review);

        Reviews result = reviewsController.addReviews(review);

        assertNotNull(result);
        verify(reviewsService).addReviews(review);
    }

    @Test
    void getAllReviews_shouldReturnListOfReviews() {
        Reviews r1 = new Reviews();
        Reviews r2 = new Reviews();
        when(reviewsService.getAllReviews()).thenReturn(Arrays.asList(r1, r2));

        List<Reviews> result = reviewsController.getAllReviews();

        assertEquals(2, result.size());
        verify(reviewsService).getAllReviews();
    }

    @Test
    void getReviewsByIdBook_shouldReturnListOfReviewsDto() {
        Long bookId = 1L;
        ReviewsDto dto1 = new ReviewsDto();
        ReviewsDto dto2 = new ReviewsDto();
        when(reviewsService.getReviewsByIdBook(bookId)).thenReturn(Arrays.asList(dto1, dto2));

        List<ReviewsDto> result = reviewsController.getReviewsByIdBook(bookId);

        assertEquals(2, result.size());
        verify(reviewsService).getReviewsByIdBook(bookId);
    }

    @Test
    void updateReviews_shouldReturnUpdatedReview() {
        Long idReview = 1L;
        Reviews review = new Reviews();
        when(reviewsService.updateReviews(idReview, review)).thenReturn(review);

        Reviews result = reviewsController.updateReviews(idReview, review);

        assertNotNull(result);
        verify(reviewsService).updateReviews(idReview, review);
    }

    @Test
    void deleteReviews_shouldInvokeServiceDelete() {
        Long id = 1L;
        doNothing().when(reviewsService).deleteReviews(id);

        reviewsController.deleteReviews(id);

        verify(reviewsService).deleteReviews(id);
    }

    @Test
    void getReviewById_shouldReturnReview() {
        Long id = 1L;
        Reviews review = new Reviews();
        when(reviewsService.getReviewById(id)).thenReturn(review);

        Reviews result = reviewsController.getReviewById(id);

        assertNotNull(result);
        verify(reviewsService).getReviewById(id);
    }
}
