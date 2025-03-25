import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { UsersService } from 'src/app/core/services/users.service';

@Component({
  selector: 'app-list-user',
  templateUrl: './list-user.component.html',
  styleUrls: ['./list-user.component.scss']
})
export class ListUserComponent implements OnInit {
  users: any[] =[]
  currentPage: number = 1;
  pageSize: number = 8;
  totalEntries: number = 0;

  constructor(private usersService: UsersService,
    private router : Router,
    
  ) {}

  ngOnInit(): void {
    this.getUsers(this.currentPage, this.pageSize);
  }

  navToUpdate(userId: number): void {
    this.router.navigate(['/home/users/update', userId]);
  }

  getUsers(page: number, pageSize: number): void {
    this.usersService.getUsersWithPagination(page, pageSize).subscribe({
      next: (res: any) => {
        console.log(res.content)
     
        this.users = res.content
        this.totalEntries = res.totalElements
      },
      error: (err: any) => {
        console.error('Error fetching users:', err);
      }
    });
  }



  onPageChange(page: number): void {
    this.currentPage = page;
    this.getUsers(this.currentPage, this.pageSize);
  }

  get totalPages(): number {
    return Math.ceil(this.totalEntries / this.pageSize);
  }

  get isNextDisabled(): boolean {
    return this.currentPage === this.totalPages;
  }

  get isPrevDisabled(): boolean {
    return this.currentPage === 1;
  }
}