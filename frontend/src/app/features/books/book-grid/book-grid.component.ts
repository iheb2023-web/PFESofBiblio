import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { BookService } from 'src/app/core/services/books.service';

@Component({
  selector: 'app-book-grid',
  templateUrl: './book-grid.component.html',
  styleUrls: ['./book-grid.component.scss']
})
export class BookGridComponent  implements OnInit{
  books : any[] = []

  constructor(private bookService : BookService,
    private router : Router
  ){}

  
  ngOnInit(): void {
    //this. getBooks()
    const user = JSON.parse(localStorage.getItem('user') || '{}'); 
    const email = user?.email; 
    if(email)
    {
      this.allBookWithinEmailOwner(email);
    }


  }
  allBookWithinEmailOwner(email : any)
  {
    this.bookService.allBookWithinEmailOwner(email).subscribe(
      (books : any) =>
      {
        this.books = books
      },
      (error) => {
        console.error('Error fetching books:', error);
      }

    );
  }

  getBooks(): void {
    this.bookService.getBooks().subscribe(
      (books) => {
        this.books = books;
      },
      (error) => {
        console.error('Error fetching books:', error);
      }
    );
  }

}
