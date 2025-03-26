import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";

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

     getBorrowRequestsByUserEmail(email: string) {
        return this.http.get(this.URL+`/requests/${email}`) 
    }

     getBorrowDemandsByUserEmail(email : any)
     {
        return this.http.get(this.URL+`/demands/${email}`)
     }

     processBorrowRequest(approved : any, borrow : any)
     {
        return this.http.put(this.URL+`/approved/${approved}`, borrow)
     }
}