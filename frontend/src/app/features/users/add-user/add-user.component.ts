// add-user.component.ts
import { Component, OnInit } from '@angular/core';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { lastValueFrom } from 'rxjs';
import { CloudinaryService } from 'src/app/core/services/cloudinary.service';
import { UsersService } from 'src/app/core/services/users.service';

@Component({
  selector: 'app-add-user',
  templateUrl: './add-user.component.html',
  styleUrls: ['./add-user.component.scss']
})
export class AddUserComponent implements OnInit {
  userForm: FormGroup = this.fb.group({}); 
  selectedFile: File | null = null;
  registrationForm: FormGroup | undefined;
  imageUrl: any = '';
  imagePreview: any = '';
  

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private userService : UsersService,
    private cloudinaryService: CloudinaryService

  ) { }




async uploadImage() {
  if (!this.selectedFile) {
    alert('Sélectionne une image avant d\'envoyer !');
    return;
  }

  try {
    // Convert the observable to a promise and wait for it to resolve
    const response = await lastValueFrom(this.cloudinaryService.uploadImage(this.selectedFile));
    
    // Ensure the response contains the image URL
    if (response ) {
      this.imageUrl = response; // URL of the uploaded image
      console.log('Image uploadée avec succès:', this.imageUrl);
    } else {
      this.imageUrl = response;
      console.log(this.imageUrl)
    }
  } catch (error : any
  ) {
    console.error('Erreur lors de l\'upload:', error.message)
    this.imageUrl = error.text
    console.log(this.imageUrl)
  }
}


  onFileSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    
    if (input.files && input.files[0]) {
      const file = input.files[0];
      this.selectedFile = file;
  
      const reader = new FileReader();
      reader.onload = () => {
        this.imagePreview = reader.result as string; 
      };
      reader.readAsDataURL(file);
      this.uploadImage();

    }
  }
  
  ngOnInit(): void {
    this.userForm = this.fb.group({
      firstname: [
        '', 
        [
          Validators.required, 
          Validators.pattern('^[A-Za-z\s]+$') // Only letters and spaces
        ]
      ],
      lastname: [
        '', 
        [
          Validators.required, 
          Validators.pattern('^[A-Za-z\s]+$') // Only letters and spaces
        ]
      ],
      email: [
        '', 
        [
          Validators.required, 
          Validators.email
        ]
      ],
      number: [
        '', 
        [
          Validators.required, 
          Validators.pattern('^[0-9]+$') // Only numbers
        ]
      ],
      job: [
        '', 
        Validators.required
      ],
      role: [
        '', 
        Validators.required
      ],
      birthday: [
        '', 
        Validators.required
      ],
    

    });
  }

  onSubmit(): void {
    if (this.userForm.valid) {
      this.userForm.value.image= this.imageUrl
      console.log('User Added:', this.userForm.value);
      this.userService.addUser(this.userForm.value).subscribe({
        next: (response) => {
        console.log('User added successfully:', response);
        this.router.navigate(['/home/users']);
        },
        error: (error) => {
         console.error('Error adding user:', error);
         }
         });
    } else {
      console.log('Form is invalid');
    }
  }
}
