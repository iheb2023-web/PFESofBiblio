import { HttpClient, HttpParams } from "@angular/common/http";
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

          getUsersWithPagination(page: number, pageSize: number, search: string = '') {
            let params = new HttpParams()
              .set('page', page.toString())
              .set('size', pageSize.toString());
          
            if (search && search.trim() !== '') {
              params = params.set('search', search.trim());
            }
          
            return this._http.get<any>(this.URL, { params });
          }
          

      getIdFromEmail(email :any )
      {
        return this._http.get(this.URL+ `/getIdFromEmail/${email}`)
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


      hasSetPassword(email : any)
      {
        return this._http.post(this.URL +`/hasSetPassword/${email}`, {})
      }

      top5emprunteurs(){
        return this._http.get(this.URL+ `/top5emprunteur`)
      }
    

  }
  