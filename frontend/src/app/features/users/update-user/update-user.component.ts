import { Component, OnInit } from '@angular/core';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { lastValueFrom } from 'rxjs';
import { CloudinaryService } from 'src/app/core/services/cloudinary.service';
import { UsersService } from 'src/app/core/services/users.service';

@Component({
  selector: 'app-update-user',
  templateUrl: './update-user.component.html',
  styleUrls: ['./update-user.component.scss']
})
export class UpdateUserComponent implements OnInit {
  userForm: FormGroup = this.fb.group({});
  selectedFile: File | null = null;
  imageUrl: string = '';
  imagePreview: string = '';
  userId: string | null = null; // To store the user ID from the route
  localRole: string = "";

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private route: ActivatedRoute,
    private userService: UsersService,
    private cloudinaryService: CloudinaryService
  ) {}

  ngOnInit(): void {
    // Get the user ID from the route
    this.userId = this.route.snapshot.paramMap.get('id');
  
      const userString = localStorage.getItem('user');
      if (userString) {
        try {
          const user = JSON.parse(userString);
          this.localRole = user.role;
          console.log(this.localRole)
        } catch (e) {
          console.error('Invalid user object in localStorage', e);
        }
      }
    

    // Initialize the form
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

    // Fetch user data if an ID is present
    if (this.userId) {
      this.getUserById(this.userId);
    }
  }

  // Fetch user data by ID
  getUserById(userId: string): void {
    this.userService.getUserById(userId).subscribe({
      next: (user) => {
        // Patch the form with the fetched user data
        this.userForm.patchValue(user);
        this.imageUrl = user.image; // Set the image URL
        this.imagePreview = user.image; // Set the image preview
      },
      error: (error) => {
        console.error('Error fetching user:', error);
      }
    });
  }

  // Handle file selection
  onFileSelected(event: Event): void {
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

  // Upload image to Cloudinary
  async uploadImage(): Promise<void> {
    if (!this.selectedFile) {
      alert('Sélectionne une image avant d\'envoyer !');
      return;
    }

    try {
      const response = await lastValueFrom(this.cloudinaryService.uploadImage(this.selectedFile));
      
      if (response) {
        this.imageUrl = response; // URL of the uploaded image
        console.log('Image uploadée avec succès:', this.imageUrl);
        console.log(this.localRole)
      } else {
        this.imageUrl = response;
        console.log(this.imageUrl);
      }
    } catch (error: any) {
      console.error('Erreur lors de l\'upload:', error.message);
      this.imageUrl = error.text;
      console.log(this.imageUrl);
    }
  }

  // Handle form submission
  onSubmit(): void {
    if (this.userForm.valid && this.userId) {
      this.userForm.value.image = this.imageUrl; // Add the image URL to the form data
      console.log('User Updated:', this.userForm.value);

      this.userService.updateUser(this.userId, this.userForm.value).subscribe({
        next: (response) => {
          console.log('User updated successfully:', response);
          if(this.localRole==="Collaborateur")
            this.router.navigate(['/home/books/library/profile']);
          else this.router.navigate(['/home/users']);
        },
        error: (error) => {
          console.error('Error updating user:', error);
        }
      });
    } else {
      console.log('Form is invalid or user ID is missing');
    }
  }
}