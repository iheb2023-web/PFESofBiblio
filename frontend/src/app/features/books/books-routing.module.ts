import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { BookListComponent } from './book-list/book-list.component';
import { BookGridComponent } from './book-grid/book-grid.component';
import { AddBookComponent } from './add-book/add-book.component';
import { BookDetailsComponent } from './book-details/book-details.component';
import { MyBooksComponent } from './my-books/my-books.component';
import { DemandesComponent } from './demandes/demandes.component';
import { LibraryComponent } from './library/library.component';
import { RequestsComponent } from './requests/requests.component';

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
    path: "details/:id", component: BookDetailsComponent
  },
  {
    path: "library",
    component: LibraryComponent,
    children: [
      { path: "mybooks", component: MyBooksComponent },
      { path: "demands", component: DemandesComponent },
      { path: "requests", component: RequestsComponent },
    ],
  }

];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class BooksRoutingModule { }
