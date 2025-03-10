import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";

@Injectable({
    providedIn: 'root'
  })
  export class UsersService {
    
    constructor(private _http: HttpClient) {}
    URL = 'http://localhost:8080/users';
    getUser() {
        return this._http.get<any>(this.URL);
      }

      getUsersWithPagination(page: number, pageSize: number){
        const params = {
          page: page.toString(),
          size: pageSize.toString()
        };
        return this._http.get<any>(this.URL, { params });
      }

    

  }
  