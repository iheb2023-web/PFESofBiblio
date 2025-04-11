import { Component, ElementRef, OnInit, ViewChild, AfterViewInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { BookService } from 'src/app/core/services/books.service';
import { ReviewsService } from 'src/app/core/services/reviews.service';

declare var bootstrap: any;

@Component({
  selector: 'app-book-details',
  templateUrl: './book-details.component.html',
  styleUrls: ['./book-details.component.scss']
})
export class BookDetailsComponent implements OnInit, AfterViewInit {
  owner!: any;
  bookId!: string;
  book!: any;
  isOwner!: boolean;
  reviews: any[] = [];
  selectedReview: any | null = null;
  newReview: any = { rating: 0, content: '' };
  currentUserEmail: string | null = null; // Store logged-in user's email
  hasUserReviewed: boolean = false; // Track if user has reviewed

  @ViewChild('editModal') editModalRef!: ElementRef;
  @ViewChild('deleteModal') deleteModalRef!: ElementRef;
  @ViewChild('addReviewModal') addReviewModalRef!: ElementRef;

  private editModalInstance: any;
  private deleteModalInstance: any;
  private addReviewModalInstance: any;

  constructor(
    private route: ActivatedRoute,
    private bookService: BookService,
    private reviewsService: ReviewsService
  ) {}

  ngOnInit(): void {
    this.bookId = this.route.snapshot.paramMap.get('id')!;
    const user = JSON.parse(localStorage.getItem('user') || '{}');

    // Store current user's email
    this.currentUserEmail = user?.email || null;

    this.bookService.getBookOwnerById(this.bookId).subscribe((owner: any) => {
      this.owner = owner;
    });

    this.getBookById(this.bookId);

    if (this.currentUserEmail) {
      this.bookService.checkOwnerBookByEmail(this.currentUserEmail, this.bookId).subscribe({
        next: (isOwner: any) => {
          this.isOwner = isOwner;
        },
        error: () => {}
      });
    }

    this.getReviewsByIdBook(this.bookId);
  }

  ngAfterViewInit(): void {
    this.editModalInstance = new bootstrap.Modal(this.editModalRef.nativeElement);
    this.deleteModalInstance = new bootstrap.Modal(this.deleteModalRef.nativeElement);
    this.addReviewModalInstance = new bootstrap.Modal(this.addReviewModalRef.nativeElement);
  }

  getBookById(bookId: any) {
    this.bookService.getBookById(bookId).subscribe({
      next: (book: any) => {
        this.book = book;
      },
      error: (error) => {
        console.error('Error fetching book details:', error);
      }
    });
  }

  getReviewsByIdBook(id: any) {
    this.reviewsService.getReviewsByIdBook(id).subscribe({
      next: (reviews: any) => {
        this.reviews = reviews;
        // Check if current user has reviewed
        this.hasUserReviewed = this.currentUserEmail
          ? reviews.some((review: any) => review.userReviewsDto.email === this.currentUserEmail)
          : false;
      }
    });
  }

  // Check if the review belongs to the current user
  isCurrentUserReview(review: any): boolean {
    return this.currentUserEmail ? review.userReviewsDto.email === this.currentUserEmail : false;
  }

  selectReview(review: any): void {
    this.selectedReview = { ...review };
  }

  setRating(rating: number): void {
    if (this.selectedReview) {
      this.selectedReview.rating = rating;
    }
  }

  setNewReviewRating(rating: number): void {
    this.newReview.rating = rating;
  }

  saveReview(): void {
    if (this.selectedReview) {
      this.reviewsService.updateReview(this.selectedReview).subscribe({
        next: () => {
          const index = this.reviews.findIndex(r => r.id === this.selectedReview!.id);
          if (index !== -1) {
            this.reviews[index] = { ...this.selectedReview };
          }
          this.selectedReview = null;
          this.getReviewsByIdBook(this.bookId);
          this.editModalInstance.hide();
        },
        error: (err) => {
          console.error('Failed to update review:', err);
        }
      });
    }
  }

  deleteReview(): void {
    if (this.selectedReview) {
      this.reviewsService.deleteReview(this.selectedReview.id).subscribe({
        next: () => {
          this.reviews = this.reviews.filter(r => r.id !== this.selectedReview!.id);
          this.selectedReview = null;
          this.hasUserReviewed = false; // Allow adding a new review after deletion
          this.deleteModalInstance.hide();
        },
        error: (err) => {
          console.error('Failed to delete review:', err);
        }
      });
    }
  }

  addReview(): void {
    if (this.newReview.rating && this.newReview.content) {
      const user = JSON.parse(localStorage.getItem('user') || '{}');
      if (!user?.id) {
        alert('You must be logged in to add a review.');
        return;
      }

      const reviewData = {
        book: {
          id : this.bookId
        },
        user: {
          email : this.currentUserEmail
        },
        rating: this.newReview.rating,
        content: this.newReview.content
      };

      this.reviewsService.addReviews(reviewData).subscribe({
        next: (data: any) => {
          this.getReviewsByIdBook(this.bookId); // Refresh reviews list, updates hasUserReviewed
          this.newReview = { rating: 0, content: '' }; // Reset form
          this.addReviewModalInstance.hide(); // Close modal
        },
        error: (err) => {
          console.error('Failed to add review:', err);
        }
      });
    } else {
      alert('Please provide both a rating and content.');
    }
  }

  trackByReviewId(index: number, review: any): number {
    return review.id;
  }
}