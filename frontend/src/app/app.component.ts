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
import { Subscription } from 'rxjs';
import { ReviewsService } from './core/services/reviews.service';

declare var bootstrap: any;

interface Toast {
  id: number;
  type: 'ProcessBorrowRequest' | 'ProcessDemand' | 'addReview';
  content: any;
}

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit, OnDestroy, AfterViewInit {
  toasts: Toast[] = [];
  toastIdCounter = 0;
  owner: any = null;
  email: string | null = null;
  localUser: any = null;
  private subscriptions: Subscription[] = []; // Store subscriptions for cleanup

  @ViewChildren('toastRef') toastRefs!: QueryList<any>;

  constructor(
    private socketService: SocketService,
    private borrowService: BorrowService,
    private bookService: BookService,
    private reviewService : ReviewsService
  ) {}

  ngOnInit() {
    this.loadUserData();
    this.listenSendProcessBorrowRequestNotification();
    this.listenProcessDemandNotification();
    this.listenAddReviewNotification();
  }

  ngOnDestroy() {
    // Unsubscribe from all subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.socketService.disconnect();
  }

  ngAfterViewInit() {
    this.toastRefs.changes.subscribe((elements: QueryList<any>) => {
      elements.toArray().forEach((toastElement) => {
        const toast = new bootstrap.Toast(toastElement.nativeElement, { autohide: true, delay: 35000 });
        toast.show();
      });
    });
  }

  listenSendProcessBorrowRequestNotification() {
    const sub = this.socketService.listenSendProcessBorrowRequestNotification().subscribe((data: any) => {
      this.borrowService.getBorrowById(data).subscribe((borrow: any) => {
        this.bookService.getBookOwnerById(borrow.book.id).subscribe((owner: any) => {
          borrow.owner = owner;
          this.addToast(borrow, 'ProcessBorrowRequest');
        });
      });
    });
    this.subscriptions.push(sub);
  }

  listenProcessDemandNotification() {
    const sub = this.socketService.listenProcessDemandNotification().subscribe((data: any) => {
      this.borrowService.getBorrowById(data).subscribe((borrow: any) => {
        this.bookService.getBookOwnerById(borrow.book.id).subscribe((owner: any) => {
          borrow.owner = owner;
          this.addToast(borrow, 'ProcessDemand');
        });
      });
    });
    this.subscriptions.push(sub);
  }

  listenAddReviewNotification()
  {
    const sub = this.socketService.listenAddReviewNotification().subscribe((data: any) => {
      this.reviewService.getReviewById(data).subscribe((reviews : any)=> {
        this.bookService.getBookOwnerById(reviews.book.id).subscribe((owner: any) => {
          reviews.book.owner = owner;
          this.addToast(reviews, 'addReview');
        });
      })
    });
    this.subscriptions.push(sub);
  }

  addToast(content: any, type: 'ProcessBorrowRequest' | 'ProcessDemand' | 'addReview') {
    // Prevent duplicate toasts (e.g., check if a toast with the same borrow ID exists)
    const borrowId = content.id; // Assuming borrow object has an 'id' property
    if (this.toasts.some(toast => toast.content.id === borrowId && toast.type === type)) {
      return; // Skip if a toast for this borrow ID and type already exists
    }

    const id = ++this.toastIdCounter;
    this.toasts.push({ id, content, type });

    // Automatically remove the toast after 5 seconds
    setTimeout(() => {
      this.removeToast(id);
    }, 25000);
  }

  removeToast(id: number) {
    this.toasts = this.toasts.filter(toast => toast.id !== id);
  }

  loadUserData(): void {
    const userData = localStorage.getItem('user');
    if (userData) {
      const user = JSON.parse(userData);
      this.email = user.email;
      this.localUser = user;
    }
  }
}