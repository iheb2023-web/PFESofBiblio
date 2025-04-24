import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, FormArray, FormControl } from '@angular/forms';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-preference-steps',
  templateUrl: './preference-steps.component.html',
  styleUrls: ['./preference-steps.component.scss']
})
export class PreferenceStepsComponent implements OnInit {
  preferenceForm: FormGroup;
  currentStep = 1;
  totalSteps = 3;

  // Options for the form
  bookLengths = ['Under 200 pages', '200-400 pages', '400-600 pages', '600+ pages'];
  genres = ['Fiction', 'History', 'Science', 'Romance', 'Biography'];

  constructor(private fb: FormBuilder, private http: HttpClient) {
    this.preferenceForm = this.fb.group({
      preferredBookLength: [''],
      favoriteGenres: this.fb.array([])
    });
  }

  ngOnInit(): void {}

  // Handle genres checkbox
  onGenreChange(event: any) {
    const genresArray = this.preferenceForm.get('favoriteGenres') as FormArray;
    if (event.target.checked) {
      genresArray.push(new FormControl(event.target.value));
    } else {
      const index = genresArray.controls.findIndex(x => x.value === event.target.value);
      genresArray.removeAt(index);
    }
  }

  // Move to the next step
  nextStep() {
    if (this.currentStep < this.totalSteps) {
      this.currentStep++;
    }
  }

  // Move to the previous step
  prevStep() {
    if (this.currentStep > 1) {
      this.currentStep--;
    }
  }

  // Submit the form to the backend
  onSubmit() {
    const preferenceData = this.preferenceForm.value;
    console.log('Preference Data:', preferenceData);

    // Send data to backend (replace with your API endpoint)
    this.http.post('http://localhost:8080/api/preferences', preferenceData).subscribe(
      response => {
        console.log('Preferences saved successfully:', response);
      },
      error => {
        console.error('Error saving preferences:', error);
      }
    );
  }
}