import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { BookService } from 'src/app/core/services/books.service';

@Component({
  selector: 'app-book-details',
  templateUrl: './book-details.component.html',
  styleUrls: ['./book-details.component.scss']
})
export class BookDetailsComponent implements OnInit {
  bookId!: string;
  book!: any;
  
  constructor(private route : ActivatedRoute,
    private bookService : BookService
  )
  {}

  ngOnInit(): void {
    this.bookId = this.route.snapshot.paramMap.get('id')!;
    this.getBookById(this.bookId);
  }

  getBookById(bookId : any)
  {
    this.bookService.getBookById(bookId).subscribe({
      next: (book: any) => {
        console.log(book)
        this.book = book;
      },
      error: (error) => {
        console.error('Error fetching book details:', error);
      }
    });

  }
}
