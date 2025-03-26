import { Component, ElementRef, Input, OnInit, ViewChild } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import flatpickr from 'flatpickr';
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
  email : any;


  constructor(private fb: FormBuilder,
    private borrowService : BorrowService,
    private userService : UsersService
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
  }
  ngAfterViewInit() {
    flatpickr(this.dateInput.nativeElement, {
      mode: 'range',
      dateFormat: 'd M',
      defaultDate: ['2023-09-19', '2023-09-28'],
      static: true,
      allowInput: false,
      onChange: (selectedDates) => {
        if (selectedDates.length === 2) {
          this.reservationForm.patchValue({
            checkInOut: selectedDates
          });
          console.log(this.reservationForm.value)
        }
      }
    });
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
      borrowDate: requestDate.toISOString().split('T')[0], // Format as YYYY-MM-DD
      expectedReturnDate: expectedReturnDate.toISOString().split('T')[0]
    };

    this.borrowService.borrowBook(borrowRequest).subscribe({
      next: (response) => {
        alert('Borrow request submitted successfully!');
        
        // Handle success (e.g., navigation or UI update)
      },
      error: (err) => {
        console.error('Error submitting request:', err);
        
      }
    });
  }
}