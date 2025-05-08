import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { UsersService } from 'src/app/core/services/users.service';
import { Subject } from 'rxjs';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
 
@Component({
  selector: 'app-list-user',
  templateUrl: './list-user.component.html',
  styleUrls: ['./list-user.component.scss']
})
export class ListUserComponent implements OnInit {
  users: any[] = [];
  currentPage: number = 1;
  pageSize: number = 8;
  totalEntries: number = 0;
  viewMode: string = 'table'; // 'table' or 'card'
  searchTerm: string = '';
  searchSubject = new Subject<string>();
 
  constructor(
    private usersService: UsersService,
    private router: Router,
  ) {
    // Setup search with debounce to avoid too many API calls
    this.searchSubject.pipe(
      debounceTime(500), // Wait for 500ms pause in events
      distinctUntilChanged() // Only emit if value is different from previous
    ).subscribe(term => {
      this.searchTerm = term;
      this.currentPage = 1; // Reset to first page when searching
      this.getUsers(this.currentPage, this.pageSize, this.searchTerm);
    });
  }
 
  ngOnInit(): void {
    this.getUsers(this.currentPage, this.pageSize);
  }
 
  navToUpdate(userId: number): void {
    this.router.navigate(['/home/users/update', userId]);
  }

  navToDisplay(userId: number): void {
    this.router.navigate(['/home/users/profile', userId]);
  }
 
  getUsers(page: number, pageSize: number, searchTerm: string = ''): void {
    this.usersService.getUsersWithPagination(page, pageSize, searchTerm).subscribe({
      next: (res: any) => {
        this.users = res.content;
        this.totalEntries = res.totalElements;
      },
      error: (err: any) => {
        console.error('Error fetching users:', err);
      }
    });
  }
 
  toggleView(mode: string): void {
    this.viewMode = mode;
  }
 
  onPageChange(page: number): void {
    this.currentPage = page;
    this.getUsers(this.currentPage, this.pageSize, this.searchTerm);
  }
 
  onSearch(event: any): void {
    const term = event.target.value;
    this.searchSubject.next(term);
  }
 
  clearSearch(): void {
    this.searchTerm = '';
    this.searchSubject.next('');
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