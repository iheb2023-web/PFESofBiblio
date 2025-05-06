import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { ForgetPasswordEmailRequest } from 'src/app/core/dtos/ForgetPasswordEmailRequest';
import { AuthService } from 'src/app/core/services/auth.service';

interface NewPasswordRequest {
  newPassword: string;
  confirmPassword: string;
}

@Component({
  selector: 'app-forget-password',
  templateUrl: './forget-password.component.html',
  styleUrls: ['./forget-password.component.scss']
})
export class ForgetPasswordComponent {
  token!: any
  email: string = '';
  code: boolean = false;
  newPassword: boolean = false;
  errorMessage: string = '';
  verificationCode: string[] = ['', '', '', ''];
  forgetPasswordEmailRequest: ForgetPasswordEmailRequest = { email: '' };
  newPasswordRequest: NewPasswordRequest = { newPassword: '', confirmPassword: '' };

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  resetPassword() {
    this.forgetPasswordEmailRequest.email = this.email;
    this.authService.resetpassword(this.forgetPasswordEmailRequest).subscribe({
      next: (response) => {
        this.code = true;
        this.errorMessage = '';
      },
      error: (err) => {
        this.code = true;
        this.errorMessage = '';
      }
    });
  }

  verifyCode() {
    const code = this.verificationCode.join('');
    console.log(code)
    this.token= code

    this.authService.getTokenByEmail(this.email).subscribe({
      next: (response) => {
        console.log("response")
        console.log(response)
        if (response==code) {
          this.newPassword = true;
          this.code = false;
          this.errorMessage = '';
        }
      },
      error: (err) => {
        this.errorMessage = err.error?.message || 'Invalid verification code.';
      }
    });
  }

  setNewPassword() {
    if (this.newPasswordRequest.newPassword !== this.newPasswordRequest.confirmPassword) {
      this.errorMessage = 'Passwords do not match.';
      return;
    }

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

  resendCode() {
    this.resetPassword();
  }

  onCodeInput(event: any, index: number) {
    const value = event.target.value;
    if (value.length === 1 && index < 3) {
      const nextInput = document.querySelector(`input[autotab-index="${index + 1}"]`) as HTMLInputElement;
      nextInput?.focus();
    }
  }
}