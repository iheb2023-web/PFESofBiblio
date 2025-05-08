import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from 'src/app/core/services/auth.service';
import {UsersService} from 'src/app/core/services/users.service';

@Component({
  selector: 'app-new-password',
  templateUrl: './new-password.component.html',
  styleUrls: ['./new-password.component.scss']
})
export class NewPasswordComponent implements OnInit {
  role! : string
  email! : string
  newPasswordRequest = {
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  };
  errorMessage: string | null = null;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private authService: AuthService,
    private userService : UsersService
  ) {}

  ngOnInit(): void {
    const userData = localStorage.getItem('user');
    if (userData) {
      const user = JSON.parse(userData);
      this.email = user.email;
      this.role = user.role

    }
  }

  setNewPassword(): void {
    // Clear previous error messages
    this.errorMessage = null;

    // Check if passwords match
    if (this.newPasswordRequest.newPassword !== this.newPasswordRequest.confirmPassword) {
      this.errorMessage = 'Passwords do not match.';
      return;
    }

 

    // Call the API to set the new password
    this.authService.changePassword(this.email, this.newPasswordRequest.newPassword).subscribe({
      next: (response) => {
        console.log('Password reset successfully:', response);
        this.userService.hasSetPassword(this.email).subscribe({
          next : (response) => {
            if(this.role==="Administrateur"){
              this.router.navigate(['/home/users']);
            }else
            this.router.navigate(['/home/books']);

          }
          
        })
       
      },
      error: (error) => {
        console.error('Error resetting password:', error);
        this.errorMessage = error.error?.message || 'Failed to reset password. Please try again.';
      }
    });
  }
}