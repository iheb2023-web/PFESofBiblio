import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";
import { OccupiedDates } from "../dtos/OccupiedDates";

@Injectable({
  providedIn: 'root'
})
export class BorrowService {
 

 
    private URL ='http://localhost:8080/borrows';

     constructor(private http: HttpClient) {}
     
     borrowBook(borrow : any)
     {
        
        return this.http.post(this.URL, borrow);
     }

     updateBorrowWhilePending(borrow : any) {
      return this.http.put(this.URL+"/updateBorrowWhilePending", borrow);
      }

     getBookOccupiedDatesByBookId(bookId: number): Observable<OccupiedDates[]> {
      return this.http.get<OccupiedDates[]>(this.URL + `/BookOccupiedDates/${bookId}`)
    }

     getBorrowRequestsByUserEmail(email: string) {
        return this.http.get(this.URL+`/requests/${email}`) 
    }
    
    getBorrowStatusUser(email : any)
    {
        return this.http.get(this.URL + `/BorrowStatusUser/${email}`)
    }

     getBorrowDemandsByUserEmail(email : any)
     {
        return this.http.get(this.URL+`/demands/${email}`)
     }

     processBorrowRequest(approved : any, borrow : any)
     {
        return this.http.put(this.URL+`/approved/${approved}`, borrow)
     }

     getBorrowById(id : any)
     {
      return this.http.get(this.URL + `/${id}`)
     }

     cancelPendingOrApproved(id : any)
     {
      return this.http.delete(this.URL+`/cancelPendingOrApproved/${id}`)
     }

     cancelWhileInProgress(id : any)
     {
      return this.http.put(this.URL+`/cancelWhileInProgress/${id}`,{})
     }

     getBookOccupiedDatesByBookIdForUpdatedBorrow(bookId: any ,borrowId : any)
     : Observable<OccupiedDates[]> {
      return this.http.get<OccupiedDates[]>(this.URL + `/getBookOccupiedDatesUpdatedBorrow/${bookId}/${borrowId}`)
    }

    markAsReturned(idBorrow : any)
    {
      return this.http.put(this.URL+`/markAsReturned/${idBorrow}`,{})
    }
}