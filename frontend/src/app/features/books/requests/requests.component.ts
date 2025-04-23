import { Component, OnInit } from '@angular/core';
import { BorrowService } from 'src/app/core/services/borrow.service';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-requests',
  templateUrl: './requests.component.html',
  styleUrls: ['./requests.component.scss']
})
export class RequestsComponent implements OnInit {
  demands: any[] = [];
  stats: any;

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

  calculateDuration(demand: any): number {
    if (demand.borrowDate && demand.expectedReturnDate) {
      const borrowDate = new Date(demand.borrowDate);
      const expectedReturnDate = new Date(demand.expectedReturnDate);
      const duration = Math.ceil((expectedReturnDate.getTime() - borrowDate.getTime()) / (1000 * 60 * 60 * 24));
      return duration;
    }
    return 0;
  }

  getRequests(email: string): void {
    this.borrowService.getBorrowRequestsByUserEmail(email).subscribe(
      (response: any) => {
        this.demands = response.reverse();
        console.log(this.demands);
      },
      (error) => {
        console.error('Error fetching demands:', error);
      }
    );
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
        if(actionText === 'cancel')
        {
          this.borrowService.cancelPendingOrApproved(demand.id).subscribe(
            () => {
              Swal.fire(
                'Success!',
                `The demand has been ${actionText}ed.`,
                'success'
              );
              // Refresh the demands list after the action
              const user = JSON.parse(localStorage.getItem('user') || '{}');
              this.getRequests(user?.email);
              this.getBorrowStatusUser(user?.email);
            },
            (error) => {
              Swal.fire(
                'Error!',
                `Failed to ${actionText} the demand.`,
                'error'
              );
              console.error(`Error ${actionText}ing demand:`, error);
            }
          );
        }
        else
        {
          this.borrowService.cancelWhileInProgress(demand.id).subscribe(
            () => {
              Swal.fire(
                'Success!',
                `The demand has been ${actionText}ed.`,
                'success'
              );
              // Refresh the demands list after the action
              const user = JSON.parse(localStorage.getItem('user') || '{}');
              this.getRequests(user?.email);
              this.getBorrowStatusUser(user?.email);
            },
            (error) => {
              Swal.fire(
                'Error!',
                `Failed to ${actionText} the demand.`,
                'error'
              );
              console.error(`Error ${actionText}ing demand:`, error);
            }
          );
        }
      
        
      }
    });
  }
}