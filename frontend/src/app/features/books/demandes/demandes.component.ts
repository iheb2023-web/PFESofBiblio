import { Component, OnInit } from '@angular/core';
import { BorrowService } from 'src/app/core/services/borrow.service';

@Component({
  selector: 'app-demandes',
  templateUrl: './demandes.component.html',
  styleUrls: ['./demandes.component.scss']
})
export class DemandesComponent implements OnInit {
  demands: any[] = [];
  email! : any

  constructor(private borrowService: BorrowService) {}

  ngOnInit(): void {
    const user = JSON.parse(localStorage.getItem('user') || '{}'); 
    const email = user?.email; 
    if (email) {
      this.email =email
      this.getDemands(email); 
    }
  }

  getDemands(email: string): void {
    this.borrowService.getBorrowDemandsByUserEmail(email).subscribe(
      (response : any) => {
        this.demands = response; 
        console.log(this.demands)
      },
      (error) => {
        console.error('Error fetching demands:', error);
      }
    );
  }

  processDemand(approved : any, borrow : any)
  {
    const borrower = {
      id: borrow.borrower.id,
    };

    const updatedBorrow = {
      ...borrow, 
      borrower: borrower 
    };
    console.log(updatedBorrow)
    this.borrowService.processBorrowRequest(approved,updatedBorrow).subscribe(
      (response : any) => {
        console.log(response)
        this.demands = this.demands.filter(demand => demand.id !== borrow.id);
      },
      (error : any) => {
        console.error('Error fetching demands:', error);
      }
    )
  }

  markAsReturned(borrowId : any)
  {
    this.borrowService.markAsReturned(borrowId).subscribe({
      next: (response: any) => {
        this.getDemands(this.email); 
      },
      error: (error: any) => {
        console.error('Failed to mark as returned:', error);
        // Optionally show error to the user
      }
    });
  }

}
