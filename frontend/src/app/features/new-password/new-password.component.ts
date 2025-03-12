import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from 'src/app/core/services/auth.service';
import { UsersService } from 'src/app/core/services/users.service';

@Component({
  selector: 'app-new-password',
  templateUrl: './new-password.component.html',
  styleUrls: ['./new-password.component.scss']
})
export class NewPasswordComponent implements OnInit {
  token: string | null = null; // Token from the URL
  newPasswordRequest = {
    newPassword: '',
    confirmPassword: ''
  };
  errorMessage: string | null = null;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private authService : AuthService
  ) {}

  ngOnInit(): void {
    // Extract the token from the query parameters
    this.route.queryParamMap.subscribe((params) => {
      this.token = params.get('token');
      if (!this.token) {
        this.errorMessage = 'Invalid or missing token.';
      }
    });
  }

  setNewPassword(): void {
    if (this.newPasswordRequest.newPassword !== this.newPasswordRequest.confirmPassword) {
      this.errorMessage = 'Passwords do not match.';
      return;
    }

    if (!this.token) {
      this.errorMessage = 'Invalid or missing token.';
      return;
    }

    // Call the API to set the new password
    this.authService.setNewPassword(this.token, this.newPasswordRequest.newPassword).subscribe({
      next: (response) => {
        console.log('Password reset successfully:', response);
        this.router.navigate(['/login']); 
        
      },
      error: (error) => {
        console.error('Error resetting password:', error);
        this.errorMessage = 'Failed to reset password. Please try again.';
      }
    });
  }
}