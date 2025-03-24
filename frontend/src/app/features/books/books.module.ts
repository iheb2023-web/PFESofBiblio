import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { BooksRoutingModule } from './books-routing.module';
import { BookListComponent } from './book-list/book-list.component';
import { SharedModule } from '../shared/shared.module';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { BookGridComponent } from './book-grid/book-grid.component';
import { AddBookComponent } from './add-book/add-book.component';
import {  HttpClientModule } from '@angular/common/http';
import { BookDetailsComponent } from './book-details/book-details.component';
import { MyBooksComponent } from './my-books/my-books.component';


@NgModule({
  declarations: [
    BookListComponent,
    BookGridComponent,
    AddBookComponent,
    BookDetailsComponent,
    MyBooksComponent
  ],
  imports: [
    CommonModule,
    BooksRoutingModule,
    SharedModule,
    FormsModule,
    ReactiveFormsModule,
    HttpClientModule
  ]
})
export class BooksModule { }
