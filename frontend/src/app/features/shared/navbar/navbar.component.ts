import { Component, OnInit } from '@angular/core';
import { CookieService } from 'ngx-cookie-service';

@Component({
  selector: 'app-navbar',
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.scss']
})
export class NavbarComponent implements OnInit{
  ngOnInit(): void {
    
  }
  constructor(private cookieService: CookieService) {}

  getToken(): string | null {
    return this.cookieService.get('token'); 
  }
  

}
