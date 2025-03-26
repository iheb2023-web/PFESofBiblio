import { Component } from '@angular/core';
import { catchError, debounceTime, map, switchMap } from 'rxjs/operators';
import { Observable, of, Subject } from 'rxjs';
import { BookService } from 'src/app/core/services/books.service';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
  selector: 'app-add-book',
  templateUrl: './add-book.component.html',
  styleUrls: ['./add-book.component.scss']
})
export class AddBookComponent {
  // Search query
  searchQuery: string = '';
  books: any[] = [];
  selectedBook: any = null;

  // Book details fields
  bookTitle: string = '';
  bookAuthor: string = '';
  bookDescription: string = '';
  publishedDate: string = '';
  isbn: string = '';
  category: string = '';
  pageCount: number = 0;
  language: string = '';
  bookCover: string | null = null;

  private searchSubject = new Subject<void>();

  constructor(
    private bookService: BookService,
    private http: HttpClient,
    private router : Router
  ) {
    // Setting up the searchSubject with debounceTime and switchMap
    this.searchSubject.pipe(
      debounceTime(500),
      switchMap(() => this.fetchBookData())
    ).subscribe();
  }

  // Function to handle search
  searchBooks() {
    if (this.searchQuery.trim()) {
      this.bookService.searchBooks(this.searchQuery).subscribe(books => {
        this.books = books;
      });
    }
  }

  // Handle when a book is selected
  selectBook(book: any) {
    this.selectedBook = book;
    this.populateBookDetails(book);
  }

  // Populate book details when a book is selected
  populateBookDetails(book: any) {
    this.bookTitle = book.title || '';
    this.bookAuthor = book.author || '';
    this.bookDescription = book.description || '';
    this.publishedDate = book.publishedDate || '';
    this.isbn = book.isbn || '';
    this.category = book.category || '';
    this.pageCount = book.pageCount || 0;
    this.language = book.language || '';
    this.bookCover = book.bookCover || '';
  }

  // Function to fetch book data from Google Books API based on title and author
  fetchBookData(): Observable<any> {
    if (this.bookTitle.trim().length > 3 || this.bookAuthor.trim().length > 3) {
      const query = encodeURIComponent(`intitle:${this.bookTitle}+inauthor:${this.bookAuthor}`);
      // Remove the callback=handleResponse parameter and fetch regular JSON response
      return this.http.get(`https://www.googleapis.com/books/v1/volumes?q=${query}`)
        .pipe(
          map((data: any) => {
            if (data.items && data.items.length > 0) {
              const book = data.items[0].volumeInfo;
              this.bookDescription = book.description || '';
              this.publishedDate = book.publishedDate || '';
  
              // Get ISBN - prefer ISBN_13 if available
              if (book.industryIdentifiers && book.industryIdentifiers.length > 0) {
                const isbn13 = book.industryIdentifiers.find((id: any) => id.type === 'ISBN_13');
                this.isbn = isbn13 ? isbn13.identifier : book.industryIdentifiers[0].identifier;
              } else {
                this.isbn = '';
              }
  
              this.category = book.categories?.[0] || '';
              this.pageCount = book.pageCount || 0;
              this.language = book.language || '';
  
              const cover = book.imageLinks?.thumbnail || '';
              this.bookCover = cover ? cover.replace('http:', 'https:') : null;
            }
            return data;
          }),
          catchError(error => {
            console.error('Error fetching book data:', error);
            return of(null); // Return null if there's an error
          })
        );
    } else {
      return of(null); // Return null if title or author is too short
    }
  }
  
  // Trigger the search when title or author changes
  onTitleOrAuthorChange(): void {
    this.searchSubject.next();
  }

  // Function to handle form submission
  onSubmit(): void {
    const newBook = {
      title: this.bookTitle,
      author: this.bookAuthor,
      description: this.bookDescription,
      publishedDate: this.publishedDate,
      isbn: this.isbn,
      category: this.category,
      pageCount: this.pageCount,
      language: this.language,
      coverUrl: this.bookCover
    };

    const userData = localStorage.getItem('user'); 
    if (userData) {
    const user = JSON.parse(userData);
    this.bookService.addBook(newBook,user.email).subscribe(
      response => {
        this.router.navigate(['/home/books/library/mybooks']);
      },
      error => {
        console.error('Error adding book:', error);
      }
    );
 
  }
    }
}