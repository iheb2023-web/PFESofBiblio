import { Component, OnInit } from '@angular/core';
import { BookService } from 'src/app/core/services/books.service';
import { UsersService } from 'src/app/core/services/users.service';

@Component({
  selector: 'app-my-books',
  templateUrl: './my-books.component.html',
  styleUrls: ['./my-books.component.scss']
})
export class MyBooksComponent implements OnInit{
  books: any[] = [];
  
  constructor(private bookService : BookService , 
    private userService : UsersService
   ) {}

  ngOnInit(): void {
    const user = JSON.parse(localStorage.getItem('user') || '{}'); 
    const email = user?.email; 
    if (email) {
      this.userService.getIdFromEmail(email).subscribe(
        response => {
         
          
          this.bookService.getBooksByOwnerId(response).subscribe(
            (books: any) => {

              this.books = books;
              console.log(books)
            },
            error => {
              console.error('Error fetching books:', error);
            }
          );
          
          
        },
        error => {
          
          console.error('Error fetching user ID:', error);
        }
      )
     
    }
  }
}
