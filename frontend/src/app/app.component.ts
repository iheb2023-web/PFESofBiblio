import {
  Component,
  OnDestroy,
  OnInit,
  QueryList,
  ViewChildren,
  AfterViewInit
} from '@angular/core';
import { SocketService } from './core/services/socket.service';
import { BorrowService } from './core/services/borrow.service';
import { BookService } from './core/services/books.service';
import { forkJoin } from 'rxjs';

declare var bootstrap: any;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit, OnDestroy, AfterViewInit {
  notification: any | null = null;
  toasts: { id: number; message: any }[] = [];  // Array to store multiple toasts
  toastIdCounter = 0;  // Counter to give each toast a unique ID
  owner : any = null
  email : any = null

  @ViewChildren('toastRef') toastRefs!: QueryList<any>; // To handle all toast references

  constructor(
    private socketService: SocketService,
    private borrowService: BorrowService,
    
    
  ) {}

  ngOnInit() {
    this.listenSendProcessBorrowRequestNotification();
  }

  ngOnDestroy() {
    this.socketService.disconnect();
  }

  ngAfterViewInit() {
    this.toastRefs.changes.subscribe((elements: QueryList<any>) => {
      // When toast references change (new toast added), show them
      elements.toArray().forEach((toastElement) => {
        const toast = new bootstrap.Toast(toastElement.nativeElement,  { autohide: false });
        toast.show();
      });
    });
  }

  listenSendProcessBorrowRequestNotification() {
    this.loadUserData()
    this.socketService.listenSendProcessBorrowRequestNotification().subscribe((data) => {
      this.borrowService.getBorrowById(data).subscribe((borrow: any) => {
        console.log('Socket process', borrow);
        borrow.owner = this.owner
        this.addToast(borrow);
      });
    });
  }

  addToast(message: any) {
    const id = ++this.toastIdCounter;
    this.toasts.push({ id, message });

    // Remove the toast after delay (5 seconds)
   /* setTimeout(() => {
      this.toasts = this.toasts.filter((toast) => toast.id !== id);
    }, 500000000);*/
  }


  loadUserData(): void {
    const userData = localStorage.getItem('user');
    if (userData) {
      const user = JSON.parse(userData);
      this.email = user.email;
    }
  }
}
