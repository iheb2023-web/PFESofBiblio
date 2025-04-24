import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PreferenceStepsComponent } from './preference-steps.component';

describe('PreferenceStepsComponent', () => {
  let component: PreferenceStepsComponent;
  let fixture: ComponentFixture<PreferenceStepsComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [PreferenceStepsComponent]
    });
    fixture = TestBed.createComponent(PreferenceStepsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
