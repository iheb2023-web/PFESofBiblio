import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { ForgetPasswordEmailRequest } from 'src/app/core/dtos/ForgetPasswordEmailRequest';
import { AuthService } from 'src/app/core/services/auth.service';

@Component({
  selector: 'app-forget-password',
  templateUrl: './forget-password.component.html',
  styleUrls: ['./forget-password.component.scss']
})
export class ForgetPasswordComponent {
  errorMessage!: string;
  forgetPasswordEmailRequest : ForgetPasswordEmailRequest ={};
  constructor(
      private authService: AuthService,
      private router: Router,
    ) {}

    resetpassword(){
      this.authService.resetpassword(this.forgetPasswordEmailRequest).subscribe({
        next: (response) => {
          
          if (response==="Password reset email sent successfully") {
            this.router.navigate(['/reset']); 
          }
        },
        error: (err) => {
          if (err.status === 500) {
         //lert('Please verify your email address and try again.');
          } else {
            this.errorMessage = err.error?.message ;  //'Please verify your email address and try again.'
          }
        }
      });
    }

}
