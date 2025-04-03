import { Component, ElementRef, Input, OnInit, ViewChild } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { Router } from '@angular/router';
import flatpickr from 'flatpickr';
import { Instance } from 'flatpickr/dist/types/instance';
import { OccupiedDates } from 'src/app/core/dtos/OccupiedDates';
import { BorrowService } from 'src/app/core/services/borrow.service';
import { UsersService } from 'src/app/core/services/users.service';

@Component({
  selector: 'app-book-reservation',
  templateUrl: './book-reservation.component.html',
  styleUrls: ['./book-reservation.component.scss']
})
export class BookReservationComponent implements OnInit {
  @Input() bookId!: number;
  @ViewChild('dateInput') dateInput!: ElementRef;
  reservationForm: FormGroup;
  email: string | undefined;
  occupiedDatesList: { from: string; to: string }[] = [];
  flatpickrInstance!: Instance;

  constructor(
    private fb: FormBuilder,
    private borrowService: BorrowService,
    private userService: UsersService,
    private router: Router
  ) {
    this.reservationForm = this.fb.group({
      checkInOut: ['']
    });
  }

  ngOnInit(): void {
    const userData = localStorage.getItem('user');
    if (userData) {
      const parsedUserData = JSON.parse(userData);
      this.email = parsedUserData.email;
    }

    this.borrowService.getBookOccupiedDatesByBookId(this.bookId).subscribe({
      next: (occupiedDates: OccupiedDates[]) => {
        this.occupiedDatesList = occupiedDates.map(dateRange => ({
          from: this.formatDate(dateRange.from),
          to: this.formatDate(dateRange.to)
        }));

        if (this.flatpickrInstance) {
          this.flatpickrInstance.set('disable', this.occupiedDatesList);
        }
      },
      error: (err) => {
        console.error('Error fetching occupied dates:', err);
      }
    });
  }

  ngAfterViewInit() {
    this.flatpickrInstance = flatpickr(this.dateInput.nativeElement, {
      mode: 'range',
      dateFormat: 'Y-m-d',
      defaultDate: ['2025-01-01'],
      minDate: 'today',
      disable: this.occupiedDatesList,
      static: false,
      allowInput: false,
      onChange: (selectedDates) => {
        if (selectedDates.length === 2) {
          this.reservationForm.patchValue({
            checkInOut: selectedDates.map(date => this.formatDate(date)) // Store as strings
          });
        }
      }
    }) as Instance;
  }

  private formatDate(date: Date | string): string {
    const d = new Date(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0'); // Months are 0-based
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  createBorrowRequest() {
    if (!this.reservationForm.valid || !this.reservationForm.value.checkInOut[1]) {
      alert('Please select valid dates');
      return;
    }

    const [requestDate, expectedReturnDate] = this.reservationForm.value.checkInOut;
    

    const borrowRequest = {
      borrower: { email: this.email },
      book: { id: this.bookId },
      borrowDate: requestDate,
      expectedReturnDate: expectedReturnDate
    };

    this.borrowService.borrowBook(borrowRequest).subscribe({
      next: (response) => {
        this.router.navigate(['/home/books/library/requests']);
      },
      error: (err) => {
        console.error('Error submitting request:', err);
      }
    });
  }
}