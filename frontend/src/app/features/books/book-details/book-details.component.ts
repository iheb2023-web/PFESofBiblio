import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { BookService } from 'src/app/core/services/books.service';

@Component({
  selector: 'app-book-details',
  templateUrl: './book-details.component.html',
  styleUrls: ['./book-details.component.scss']
})
export class BookDetailsComponent implements OnInit {
  owner! : any
  bookId!: string;
  book!: any;
  isOwner !: boolean
  constructor(private route : ActivatedRoute,
    private bookService : BookService
  )
  {}

  ngOnInit(): void {
    this.bookId = this.route.snapshot.paramMap.get('id')!;
    const user = JSON.parse(localStorage.getItem('user') || '{}'); 
    this.bookService.getBookOwnerById(this.bookId).subscribe(
      (owner : any) =>{
        this.owner = owner
      }
    )
    this.getBookById(this.bookId);
    const email = user?.email; 
    if(email)
    {
      this.bookService.checkOwnerBookByEmail(email, this.bookId).subscribe(
        (isOwner : any) => {
         this.isOwner = isOwner
        },
        (error) => {
        }
      ); 
    }
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
