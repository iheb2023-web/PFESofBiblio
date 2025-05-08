import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from './navbar/navbar.component';
import { SidebarComponent } from './sidebar/sidebar.component';
import { RouterModule } from '@angular/router';
import { NavComponent } from './nav/nav.component';
import { ProfileComponent } from './profile/profile.component';



@NgModule({
  declarations: [
    NavbarComponent,
    SidebarComponent,
    NavComponent,
    ProfileComponent
  ],
  imports: [
    CommonModule,
    RouterModule
    
  ],
  exports: [
    NavbarComponent,
    SidebarComponent,
    NavComponent,
    ProfileComponent
  ]
})
export class SharedModule { }
