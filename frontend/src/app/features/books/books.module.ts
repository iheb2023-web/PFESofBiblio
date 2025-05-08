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
import { BookReservationComponent } from './book-reservation/book-reservation.component';
import { NavigationsComponent } from './navigations/navigations.component';
import { DemandesComponent } from './demandes/demandes.component';
import { LibraryComponent } from './library/library.component';
import { RequestsComponent } from './requests/requests.component';
import { UpdateReservationComponent } from './update-reservation/update-reservation.component';


@NgModule({
  declarations: [
    BookListComponent,
    BookGridComponent,
    AddBookComponent,
    BookDetailsComponent,
    MyBooksComponent,
    BookReservationComponent,
    NavigationsComponent,
    DemandesComponent,
    LibraryComponent,
    RequestsComponent,
    UpdateReservationComponent
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
