import { Injectable } from "@angular/core";
import { AuthenticationRequest } from "../dtos/AuthentificationRequest";
import { AuthenticationResponse } from "../dtos/AuthentificationResponse";
import { HttpClient } from "@angular/common/http";
import { ForgetPasswordEmailRequest } from "../dtos/ForgetPasswordEmailRequest";
import { CookieService } from "ngx-cookie-service";

@Injectable({
    providedIn: 'root'
  })
  export class AuthService {
     URL = 'http://localhost:8080/users/login'
     RESET_PASSWORD_EMAIL_SEND = 'http://localhost:8080/password-reset/request'

     constructor(private _http:HttpClient,
        private cookieService: CookieService
     ) { }

     getToken(): string | null {
        return this.cookieService.get('token'); 
      }
    
     
      getUserFromToken(): any {
        const token = this.getToken();
        if (token) {
          try {
            const decodedToken = jwt_decode(token);
            console.log("decoded token")
            return decodedToken; 
          } catch (error) {
            console.error('Error decoding JWT:', error);
            return null;
          }
        }
        return null;
      }
    
      
      isLoggedIn(): boolean {
        return !!this.getToken();
      }

    login(
        authRequest: AuthenticationRequest
      ) {
        return this._http.post<AuthenticationResponse>
        (this.URL, authRequest);
      }

    resetpassword(email:ForgetPasswordEmailRequest){
        return this._http.post(this.RESET_PASSWORD_EMAIL_SEND+`?email=${email.email}`, "")
    }
  }

function jwt_decode(token: string) {
    throw new Error("Function not implemented.");
}
