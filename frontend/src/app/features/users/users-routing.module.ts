import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { ListUserComponent } from './list-user/list-user.component';
import { AddUserComponent } from './add-user/add-user.component';
import { UpdateUserComponent } from './update-user/update-user.component';
import { AuthGuard } from 'src/app/core/guards/auth-guard.guard';
import { AdminGuard } from 'src/app/core/guards/admin-guard.guard';
import { ProfileComponent } from '../shared/profile/profile.component';
import { StatComponent } from './stat/stat.component';

const routes: Routes = [
  { path: '', component: ListUserComponent,  canActivate: [AuthGuard,AdminGuard]}, 
  {path: 'add', component : AddUserComponent,  canActivate: [AuthGuard,AdminGuard]},
  {
    path: "stat", component: StatComponent, canActivate: [AuthGuard,AdminGuard]
  },
  {
    path: 'update/:id',
    component: UpdateUserComponent,
    canActivate: [AuthGuard,AdminGuard]
  },
  {
    path: 'profile',
    component : ProfileComponent
  },
  {
    path: 'profile/:id',
    component : ProfileComponent
  }


];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class UsersRoutingModule { }
