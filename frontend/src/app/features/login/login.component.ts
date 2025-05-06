import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AuthenticationRequest } from 'src/app/core/dtos/AuthentificationRequest';
import { AuthenticationResponse } from 'src/app/core/dtos/AuthentificationResponse';
import { AuthService } from 'src/app/core/services/auth.service';
import { UsersService } from 'src/app/core/services/users.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {
  errorMessage!: string;
  passwordVisible: boolean = false;

  authRequest: AuthenticationRequest = {};
  authResponse: AuthenticationResponse = {};

  constructor(
    private authService: AuthService,
    private router: Router,
    private userService : UsersService
  ) {}


  

  authenticate() {
    this.authService.login(this.authRequest).subscribe({
      next: (response) => {
        this.authResponse = response;
        
        document.cookie = `token=${response.access_token}; path=/; max-age=${24 * 60 * 60}`;
  
        this.authRequest.email
        this.userService.getUserMinInfo(
          this.authRequest.email
        ).subscribe({
          next: (userMin) => {
            localStorage.setItem('user', JSON.stringify(userMin));
            if(userMin.hasSetPassword==false){
              this.router.navigate(['/newpassword'])
            }else  {
              if(userMin.role==="Administrateur"){
                this.router.navigate(['/home/users']);
              }else
              this.router.navigate(['/home/books']);
            }
            
          },
          error: (error) => {
            console.error('Failed to fetch user info:', error);
          }
        });
      },
      error: (error) => {
        this.errorMessage = 'Authentication failed. Check your credentials.';
        console.error('Authentication failed:', error);
      }
    });
  }
  
}