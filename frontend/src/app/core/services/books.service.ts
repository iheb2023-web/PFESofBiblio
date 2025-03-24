import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { Book } from '../dtos/Book';

@Injectable({
  providedIn: 'root'
})
export class BookService {
  private apiUrl = 'https://www.googleapis.com/books/v1/volumes?q=';
  private URL ='http://localhost:8080/books';
  constructor(private http: HttpClient) {}

  addBook(book : any, email : any){
    return this.http.post(this.URL+ "/add"+ `/${email}`, book)
  }

  getBooks()
  {
    return this.http.get<any>(this.URL);
  }
  
  searchBooks(query: string): Observable<Book[]> {
    return this.http.get<any>(`${this.apiUrl}${query}`).pipe(
      map(response => {
        return response.items.map((item: any) => ({
          title: item.volumeInfo.title || '',
          author: item.volumeInfo.authors?.join(', ') || 'Unknown',
          description: item.volumeInfo.description || 'No description available',
          coverUrl: item.volumeInfo.imageLinks?.thumbnail || '',
          publishedDate: item.volumeInfo.publishedDate || '',
          isbn: item.volumeInfo.industryIdentifiers?.[0]?.identifier || '',
          category: item.volumeInfo.categories?.[0] || 'Uncategorized',
          pageCount: item.volumeInfo.pageCount || 0,
          language: item.volumeInfo.language || ''
        }));
      })
    );
  }
}
