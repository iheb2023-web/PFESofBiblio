import { Component, OnInit, ViewChild } from '@angular/core';
import { Chart, registerables } from 'chart.js';
import { UsersService } from 'src/app/core/services/users.service';

@Component({
  selector: 'app-stat',
  templateUrl: './stat.component.html',
  styleUrls: ['./stat.component.scss']
})
export class StatComponent implements OnInit {
  @ViewChild('rolesChart', { static: true }) rolesChartRef: any;
  @ViewChild('topBorrowersChart', { static: true }) topBorrowersChartRef: any;

  recentUsers: any[] = [];
  topBorrowers: any[] = [];
  rolesCount = { Admin: 0, Collaborateur: 0 }; 
  currentPage = 0;
  totalPages = 1;
  totalUsers = 0; 

  constructor(private usersService: UsersService) {}

  ngOnInit() {
    Chart.register(...registerables);
    this.getAllUsers(); 
    this.loadTop5Borrowers();
  }

  loadTop5Borrowers() {
    this.usersService.top5emprunteurs().subscribe({
      next: (res: any) => { // Ici on définit que la réponse est un tableau de type any[]
        this.topBorrowers = res;
        this.createTopBorrowersChart();
      },
      error: (err) => {
        console.error('Erreur lors du chargement des top 5 emprunteurs', err);
      }
    });
  }
  
  
  getAllUsers(): void {
    this.recentUsers = []; 
    const fetchPage = (page: number) => {
      this.usersService.getUsersWithPagination(page, 5).subscribe({
        next: (res: any) => {
          this.recentUsers = [...this.recentUsers, ...res.content];
          this.totalUsers = res.totalElements; 
          if (page < res.totalPages) {
            fetchPage(page + 1); 
          } else {
            this.countRoles();
            this.createCharts();
          }
        },
        error: (err: any) => {
          console.error('Error fetching users:', err);
        }
      });
    };
    fetchPage(this.currentPage);
  }

  createTopBorrowersChart() {
    const labels = this.topBorrowers.map(b => `${b.firstname} ${b.lastname}`);
    const data = this.topBorrowers.map(b => b.nbEmprunts);
  
    new Chart(this.topBorrowersChartRef.nativeElement, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Nombre d\'emprunts',
          data: data,
          backgroundColor: '#4BC0C0'
        }]
      },
      options: {
        scales: {
          y: { beginAtZero: true }
        }
      }
    });
  }

  countRoles() {
    this.rolesCount.Admin = this.recentUsers.filter(user => user.role === 'Administrateur').length;
    this.rolesCount.Collaborateur = this.recentUsers.filter(user => user.role === 'Collaborateur').length;
  }

  createCharts() {
    new Chart(this.rolesChartRef.nativeElement, {
      type: 'pie',
      data: {
        labels: ['Admins', 'Collaborateurs'],
        datasets: [{
          data: [this.rolesCount.Admin, this.rolesCount.Collaborateur], 
          backgroundColor: ['#FF6384', '#36A2EB']
        }]
      }
    });
  }
}
