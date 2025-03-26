import { Component, OnInit } from '@angular/core';
import { BorrowService } from 'src/app/core/services/borrow.service';

@Component({
  selector: 'app-requests',
  templateUrl: './requests.component.html',
  styleUrls: ['./requests.component.scss']
})
export class RequestsComponent implements OnInit{
  demands: any[] = [];  
  
  
    constructor(private borrowService: BorrowService) {}
  
    ngOnInit(): void {
      const user = JSON.parse(localStorage.getItem('user') || '{}'); 
      const email = user?.email; 
      if (email) {
        this.getRequests(email); 
      }
      
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
        (response : any) => {
          this.demands = response; 
          console.log(this.demands)
        },
        (error) => {
          console.error('Error fetching demands:', error);
        }
      );
    }

}
