import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { UsersService } from 'src/app/core/services/users.service';



interface User {
  id: string;
  firstname: string;
  lastname: string;
  email: string;
  number: any;
  birthday: any;
  role: string;
  image: string;
  job: string;
}

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.scss']
})
export class ProfileComponent implements OnInit {
  userId: string | null = null;
  user: User | null = null;
  localId : string | null = null;
  localRole: string| null = null;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private userService: UsersService
  ) {}

  ngOnInit(): void {
    this.userId = this.route.snapshot.paramMap.get('id');
    if (this.userId === null) {
      const userString = localStorage.getItem('user');
      if (userString) {
        try {
          const user = JSON.parse(userString);
          this.userId = user.id; 
          this.localId = user.id;
          this.localRole = user.role;
        } catch (e) {
          console.error('Invalid user object in localStorage', e);
        }
      }
    }
    
    if (this.userId) {
      this.getUserById(this.userId);
    }
  }

  getUserById(userId: string): void {
    this.userService.getUserById(userId).subscribe({
      next: (user: User) => {
        this.user = user;
      },
      error: (error) => {
        console.error('Error fetching user:', error);
      }
    });
  }

  editProfile(): void {
    if (this.userId) {
      this.router.navigate(['/home/books/library/update/', this.userId]);
    }
  }
}