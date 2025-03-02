import { Injectable } from "@angular/core";
import { AuthenticationRequest } from "../dtos/AuthentificationRequest";
import { AuthenticationResponse } from "../dtos/AuthentificationResponse";
import { HttpClient } from "@angular/common/http";
import { ForgetPasswordEmailRequest } from "../dtos/ForgetPasswordEmailRequest";

@Injectable({
    providedIn: 'root'
  })
  export class AuthService {
     URL = 'http://localhost:8080/users/login'
     RESET_PASSWORD_EMAIL_SEND = 'http://localhost:8080/password-reset/request'

     constructor(private _http:HttpClient) { }

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