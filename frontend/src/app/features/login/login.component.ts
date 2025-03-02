import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AuthenticationRequest } from 'src/app/core/dtos/AuthentificationRequest';
import { AuthenticationResponse } from 'src/app/core/dtos/AuthentificationResponse';
import { AuthService } from 'src/app/core/services/auth.service';

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
  ) {}


  

  authenticate() {
    this.authService.login(this.authRequest).subscribe({
      next: (response) => {
        this.authResponse = response;
        
        document.cookie = `token=${response.access_token}; path=/; max-age=${24 * 60 * 60}`;

        
        //this.router.navigate(['/home']);
      },
      error: (error) => {
        this.errorMessage = 'Authentication failed. Check your credentials.';
        console.error('Authentication failed:', error);
      }
    });
  }
}
