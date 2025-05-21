import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './features/login/login.component';
import { ForgetPasswordComponent } from './features/forget-password/forget-password.component';
import { NotfoundComponent } from './features/notfound/notfound.component';
import { NewPasswordComponent } from './features/new-password/new-password.component';
import { HomeComponent } from './features/home/home.component';
import { PreferenceStepsComponent } from './features/preference-steps/preference-steps.component';

const routes: Routes = [
  {path : 'pref' ,component: PreferenceStepsComponent},
   { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  {
   path: 'forgetpassword', component : ForgetPasswordComponent
  },
  { path: 'newpassword', component: NewPasswordComponent },
  {path : 'home',
    component: HomeComponent,
    children : [
      { path: 'users', loadChildren: () => import('./features/users/users.module').then(m => m.UsersModule) },
      { path: 'books', loadChildren: () => import('./features/books/books.module').then(m => m.BooksModule) },
      {path: 'stat', loadChildren:() => import('./features/users/users.module').then(m=>m.UsersModule)}
    ]
  },
  { path: '**', component: NotfoundComponent },
  
  
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
