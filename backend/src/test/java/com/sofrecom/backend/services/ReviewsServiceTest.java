package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.ReviewsDto;
import com.sofrecom.backend.entities.Reviews;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.repositories.ReviewsRepository;
import com.sofrecom.backend.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;


@ExtendWith(MockitoExtension.class)
class ReviewsServiceTest {

    @Mock
    private ReviewsRepository reviewsRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SocketIOService socketIOService;

    @InjectMocks
    private ReviewsService reviewsService;

    private User user;
    private Reviews review;
    private ReviewsDto reviewsDto;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");

        review = new Reviews();
        review.setId(1L);
        review.setUser(user);
        review.setContent("Great book!");
        review.setRating(5);
        review.setCreatedAt(LocalDateTime.now());

        reviewsDto = new ReviewsDto();
        reviewsDto.setContent("Great book!");
        reviewsDto.setRating(5);
    }

    @Test
    void addReviews_ValidUser_ShouldSaveReviewAndSendNotification() {
        // Arrange
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));
        when(reviewsRepository.save(any(Reviews.class))).thenReturn(review);
        doNothing().when(socketIOService).sendAddReviewNotification(anyLong());

        // Act
        Reviews result = reviewsService.addReviews(review);

        // Assert
        assertNotNull(result);
        assertEquals(user, result.getUser());
        assertEquals("Great book!", result.getContent());
        assertNotNull(result.getCreatedAt());
        verify(userRepository).findByEmail("test@example.com");
        verify(reviewsRepository).save(any(Reviews.class));
        verify(socketIOService).sendAddReviewNotification(review.getId());
    }

    @Test
    void addReviews_NonExistingUser_ShouldSaveReviewWithNullUser() {
        // Arrange
        Reviews reviewWithNullUser = new Reviews();
        reviewWithNullUser.setId(1L);
        reviewWithNullUser.setUser(null);
        reviewWithNullUser.setContent("Great book!");
        reviewWithNullUser.setRating(5);
        reviewWithNullUser.setCreatedAt(LocalDateTime.now());

        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.empty());
        when(reviewsRepository.save(any(Reviews.class))).thenReturn(reviewWithNullUser);
        doNothing().when(socketIOService).sendAddReviewNotification(anyLong());

        // Act
        Reviews result = reviewsService.addReviews(review);

        // Assert
        assertNotNull(result);
        assertNull(result.getUser());
        assertEquals("Great book!", result.getContent());
        assertNotNull(result.getCreatedAt());
        verify(userRepository).findByEmail("test@example.com");
        verify(reviewsRepository).save(any(Reviews.class));
        verify(socketIOService).sendAddReviewNotification(reviewWithNullUser.getId());
    }

    @Test
    void getAllReviews_ShouldReturnAllReviews() {
        // Arrange
        List<Reviews> reviews = Arrays.asList(review);
        when(reviewsRepository.findAll()).thenReturn(reviews);

        // Act
        List<Reviews> result = reviewsService.getAllReviews();

        // Assert
        assertEquals(1, result.size());
        assertEquals(review, result.get(0));
        verify(reviewsRepository).findAll();
    }

    @Test
    void getReviewsByIdBook_ShouldReturnReviews() {
        // Arrange
        List<ReviewsDto> reviewsDtos = Arrays.asList(reviewsDto);
        when(reviewsRepository.getReviewsByIdBook(1L)).thenReturn(reviewsDtos);

        // Act
        List<ReviewsDto> result = reviewsService.getReviewsByIdBook(1L);

        // Assert
        assertEquals(1, result.size());
        assertEquals(reviewsDto, result.get(0));
        verify(reviewsRepository).getReviewsByIdBook(1L);
    }

    @Test
    void updateReviews_ExistingReview_ShouldUpdateAndSave() {
        // Arrange
        Reviews updatedReview = new Reviews();
        updatedReview.setContent("Updated content");
        updatedReview.setRating(4);

        when(reviewsRepository.findById(1L)).thenReturn(Optional.of(review));
        when(reviewsRepository.save(any(Reviews.class))).thenReturn(review);

        // Act
        Reviews result = reviewsService.updateReviews(1L, updatedReview);

        // Assert
        assertNotNull(result);
        assertEquals("Updated content", result.getContent());
        assertEquals(4, result.getRating());
        assertNotNull(result.getUpdatedAt());
        verify(reviewsRepository).findById(1L);
        verify(reviewsRepository).save(any(Reviews.class));
    }

    @Test
    void updateReviews_NonExistingReview_ShouldThrowAssertionError() {
        // Arrange
        Reviews updatedReview = new Reviews();
        when(reviewsRepository.findById(1L)).thenReturn(Optional.empty());

        // Act & Assert
        AssertionError exception = assertThrows(AssertionError.class, () ->
                reviewsService.updateReviews(1L, updatedReview));
        verify(reviewsRepository).findById(1L);
        verify(reviewsRepository, never()).save(any());
    }

    @Test
    void deleteReviews_ShouldDeleteById() {
        // Arrange
        doNothing().when(reviewsRepository).deleteById(1L);

        // Act
        reviewsService.deleteReviews(1L);

        // Assert
        verify(reviewsRepository).deleteById(1L);
    }

    @Test
    void getReviewById_ExistingReview_ShouldReturnReview() {
        // Arrange
        when(reviewsRepository.findById(1L)).thenReturn(Optional.of(review));

        // Act
        Reviews result = reviewsService.getReviewById(1L);

        // Assert
        assertNotNull(result);
        assertEquals(review, result);
        verify(reviewsRepository).findById(1L);
    }

    @Test
    void getReviewById_NonExistingReview_ShouldReturnNull() {
        // Arrange
        when(reviewsRepository.findById(1L)).thenReturn(Optional.empty());

        // Act
        Reviews result = reviewsService.getReviewById(1L);

        // Assert
        assertNull(result);
        verify(reviewsRepository).findById(1L);
    }
}