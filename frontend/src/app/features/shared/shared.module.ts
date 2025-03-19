import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from './navbar/navbar.component';
import { SidebarComponent } from './sidebar/sidebar.component';
import { RouterModule } from '@angular/router';
import { NavComponent } from './nav/nav.component';



@NgModule({
  declarations: [
    NavbarComponent,
    SidebarComponent,
    NavComponent
  ],
  imports: [
    CommonModule,
    RouterModule
    
  ],
  exports: [
    NavbarComponent,
    SidebarComponent,
    NavComponent
  ]
})
export class SharedModule { }
