import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { UsersRoutingModule } from './users-routing.module';
import { ListUserComponent } from './list-user/list-user.component';
import { SharedModule } from '../shared/shared.module';
import { ProfileComponent } from './profile/profile.component';
import { ProfileSidebarComponent } from './profile-sidebar/profile-sidebar.component';
import { AddUserComponent } from './add-user/add-user.component';


@NgModule({
  declarations: [
    ListUserComponent,
    ProfileComponent,
    ProfileSidebarComponent,
    AddUserComponent
  ],
  imports: [
    CommonModule,
    UsersRoutingModule,
    SharedModule 
  ]
})
export class UsersModule { }
