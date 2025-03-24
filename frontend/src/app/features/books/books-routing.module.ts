import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { BookListComponent } from './book-list/book-list.component';
import { BookGridComponent } from './book-grid/book-grid.component';
import { AddBookComponent } from './add-book/add-book.component';
import { BookDetailsComponent } from './book-details/book-details.component';
import { MyBooksComponent } from './my-books/my-books.component';

const routes: Routes = [
  {path:"", component : BookListComponent},
  {path:"grid", component : BookGridComponent},
  {
    path:"add", component: AddBookComponent
  },
  {
    path:"mybooks", component: MyBooksComponent
  },
  {
    path: "details", component: BookDetailsComponent
  }

];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class BooksRoutingModule { }
