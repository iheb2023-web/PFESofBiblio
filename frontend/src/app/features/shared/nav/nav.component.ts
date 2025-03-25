import { Component, OnInit, Renderer2 } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-nav',
  templateUrl: './nav.component.html',
  styleUrls: ['./nav.component.scss']
})
export class NavComponent  implements OnInit {
  firstname: string = '';
  lastname: string = '';
  email: string = '';
  image : string = '';
  

  ngOnInit(): void {
    this.setTheme(this.getPreferredTheme());
    this.loadUserData();


    
  }
 
  constructor(private router: Router,
    private renderer: Renderer2
  ) {}


  logout() {
    document.cookie = 'token=; path=/; max-age=0;'; 
    localStorage.removeItem('user');
    this.router.navigate(['/login']);
  }
  
  getPreferredTheme(): string {
    const storedTheme = localStorage.getItem('theme');
    if (storedTheme) {
      return storedTheme;
    }
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  setTheme(theme: string): void {
    if (theme === 'auto' && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      this.renderer.setAttribute(document.documentElement, 'data-bs-theme', 'dark');
    } else {
      this.renderer.setAttribute(document.documentElement, 'data-bs-theme', theme);
    }
    localStorage.setItem('theme', theme);
    this.updateActiveTheme(theme);
  }

  updateActiveTheme(theme: string): void {
    document.querySelectorAll('[data-bs-theme-value]').forEach(element => {
      element.classList.remove('active');
    });

    const btnToActivate = document.querySelector(`[data-bs-theme-value="${theme}"]`);
    if (btnToActivate) {
      btnToActivate.classList.add('active');
    }
  }

  changeTheme(theme: string): void {
    this.setTheme(theme);
  }
  
  loadUserData(): void {
    const userData = localStorage.getItem('user');
    if (userData) {
      const user = JSON.parse(userData);
      this.firstname = user.firstname;
      this.lastname = user.lastname;
      this.email = user.email;
      this.image = user.image
    }
  }


}
