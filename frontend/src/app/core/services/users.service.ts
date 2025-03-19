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
        getUserById(userId: any

        ) {
            return this._http.get<any>(`${this.URL}/${userId}`);
          }

      getUsersWithPagination(page: number, pageSize: number){
        const params = {
          page: page.toString(),
          size: pageSize.toString()
        };
        return this._http.get<any>(this.URL, { params });
      }

      
      getUserMinInfo(email: any){
        return this._http.get<any>(`${this.URL}/usermininfo/${email}`);
      }

      addUser( user
        : any) {
        return this._http.post(this.URL, user);
      }

      updateUser(id: any
        , user: any) {
        return this._http.patch(this.URL + `/${id}`, user);
      }
    

  }
  