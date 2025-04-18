import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { io, Socket } from 'socket.io-client';

@Injectable({
  providedIn: 'root' // Ensures singleton instance
})
export class SocketService {
 
  private socket: Socket;

  constructor() {
    this.socket = io('http://localhost:9092', {
      reconnection: true, // Enable reconnection
      reconnectionAttempts: 5, // Limit reconnection attempts
      reconnectionDelay: 1000
    });

    // Log connection for debugging
    this.socket.on('connect', () => {
      console.log('Connected to Socket.IO server:', this.socket.id);
    });
  }

  listenForBookUpdates(): Observable<string> {
    return new Observable<string>((observer) => {
      this.socket.on('bookUpdated', (data: string) => {
        observer.next(data);
      });
    });
  }

  listenSendProcessBorrowRequestNotification(): Observable<any> {
    return new Observable<any>((observer) => {
      this.socket.on('processBorrowRequest', (data: any) => {
        observer.next(data);
      });
    });
  }

  listenProcessDemandNotification(): Observable<any> {
    return new Observable<any>((observer) => {
      this.socket.on('processDemand', (data: any) => {
        observer.next(data);
      });
    });
  }

  listenAddReviewNotification(): Observable<any> {
    return new Observable<any>((observer) => {
        this.socket.on('addReview', (data: any) => {
          observer.next(data);
        });
      });
  }

  disconnect() {
    this.socket.disconnect();
  }
}