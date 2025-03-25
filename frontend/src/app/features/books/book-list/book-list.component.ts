import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { BookService } from 'src/app/core/services/books.service';

@Component({
  selector: 'app-book-list',
  templateUrl: './book-list.component.html',
  styleUrls: ['./book-list.component.scss']
})
export class BookListComponent implements OnInit{
    books : any[] = []
  
    constructor(private bookService : BookService,
      private router : Router
    ){}
  
    
    ngOnInit(): void {
      this. getBooks()
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
