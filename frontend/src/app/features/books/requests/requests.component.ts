import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { BorrowService } from 'src/app/core/services/borrow.service';
import Swal from 'sweetalert2';
declare var bootstrap: any;

@Component({
  selector: 'app-requests',
  templateUrl: './requests.component.html',
  styleUrls: ['./requests.component.scss']
})
export class RequestsComponent implements OnInit {
  @ViewChild('updateReservationModal', { static: false }) modalElement!: ElementRef;

  demands: any[] = [];
  filteredDemands: any[] = [];
  stats: any;
  selectedBookId: any | null = null;
  selectedBorrowId: any | null = null;

  constructor(private borrowService: BorrowService) {}

  ngOnInit(): void {
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    const email = user?.email;
    if (email) {
      this.getRequests(email);
      this.getBorrowStatusUser(email);
    }
  }

  getBorrowStatusUser(email: string) {
    this.borrowService.getBorrowStatusUser(email).subscribe(
      (stats: any) => {
        this.stats = stats;
      },
      (error) => {
        console.error('Error fetching stats:', error);
      }
    );
  }

  getRequests(email: string): void {
    this.borrowService.getBorrowRequestsByUserEmail(email).subscribe(
      (response: any) => {
        this.demands = response.reverse();
        this.filteredDemands = [...this.demands];
      },
      (error) => {
        console.error('Error fetching demands:', error);
      }
    );
  }

  filterDemands(status: string): void {
    this.filteredDemands = status ? this.demands.filter(d => d.borrowStatus === status) : [...this.demands];
  }

  calculateDuration(demand: any): number {
    if (demand.borrowDate && demand.expectedReturnDate) {
      const borrowDate = new Date(demand.borrowDate);
      const expectedReturnDate = new Date(demand.expectedReturnDate);
      return Math.ceil((expectedReturnDate.getTime() - borrowDate.getTime()) / (1000 * 60 * 60 * 24));
    }
    return 0;
  }

  confirmAction(demand: any) {
    const actionText = demand.borrowStatus === 'IN_PROGRESS' ? 'return' : 'cancel';
    Swal.fire({
      title: 'Are you sure?',
      text: `Do you want to ${actionText} this demand?`,
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#3085d6',
      cancelButtonColor: '#d33',
      confirmButtonText: `Yes, ${actionText} it!`
    }).then((result) => {
      if (result.isConfirmed) {
        const serviceCall = actionText === 'cancel'
          ? this.borrowService.cancelPendingOrApproved(demand.id)
          : this.borrowService.cancelWhileInProgress(demand.id);

        serviceCall.subscribe(
          () => {
            Swal.fire('Success!', `The demand has been ${actionText}ed.`, 'success');
            const user = JSON.parse(localStorage.getItem('user') || '{}');
            this.getRequests(user?.email);
            this.getBorrowStatusUser(user?.email);
          },
          (error) => {
            Swal.fire('Error!', `Failed to ${actionText} the demand.`, 'error');
            console.error(`Error ${actionText}ing demand:`, error);
          }
        );
      }
    });
  }

  openUpdateModal(bookId: string, borrowId: string): void {
    this.selectedBookId = bookId;
    this.selectedBorrowId = borrowId;
  }

  handleUpdateFinished() {
    if (this.modalElement && this.modalElement.nativeElement) {
      const modalInstance = bootstrap.Modal.getInstance(this.modalElement.nativeElement) || new bootstrap.Modal(this.modalElement.nativeElement);
      modalInstance.hide();
      // Refresh data after modal closes
      const user = JSON.parse(localStorage.getItem('user') || '{}');
      this.getRequests(user?.email);
      this.getBorrowStatusUser(user?.email);
    } else {
      console.error('Modal element not found');
    }
  }
}