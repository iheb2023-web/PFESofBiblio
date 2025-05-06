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

    setNewPassword(token: string, newPassword: string) {
        return this._http.put('http://localhost:8080/password-reset/reset'+`?token=${token}&password=${newPassword}`, "")
           
      }
      changePassword(email: string,newPassword: string)
      {
        return this._http.put('http://localhost:8080/password-reset/changePassword'+`?email=${email}&password=${newPassword}`, "")
      }
    
      getTokenByEmail(email : any)
      {
        return this._http.get('http://localhost:8080/password-reset/getTokenByEmail/'+email)
      }
  }

