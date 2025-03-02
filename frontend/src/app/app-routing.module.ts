import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './features/login/login.component';
import { ForgetPasswordComponent } from './features/forget-password/forget-password.component';

const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
   path: 'forgetpassword', component : ForgetPasswordComponent
  }
  
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
