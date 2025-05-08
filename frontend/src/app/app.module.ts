import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { LoginComponent } from './features/login/login.component';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { ForgetPasswordComponent } from './features/forget-password/forget-password.component';
import { TokenInterceptor } from './core/interceptor/token-inter.interceptor';
import { NotfoundComponent } from './features/notfound/notfound.component';
import { UsersModule } from './features/users/users.module';
import { NewPasswordComponent } from './features/new-password/new-password.component';
import { SharedModule } from './features/shared/shared.module';
import { HomeComponent } from './features/home/home.component';
import { BooksModule } from './features/books/books.module';
import { PreferenceStepsComponent } from './features/preference-steps/preference-steps.component';


@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    ForgetPasswordComponent,
    NotfoundComponent,
    NewPasswordComponent,
    HomeComponent,
    PreferenceStepsComponent
    
    
    
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    ReactiveFormsModule,
    FormsModule,
    UsersModule,
    BooksModule,
    SharedModule,
    
   
  ],
  providers: [
    {
    provide: HTTP_INTERCEPTORS,
    useClass: TokenInterceptor,
    multi: true,
    }
],
  bootstrap: [AppComponent]
})
export class AppModule { }
