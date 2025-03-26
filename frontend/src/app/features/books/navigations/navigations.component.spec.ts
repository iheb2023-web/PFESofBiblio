import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NavigationsComponent } from './navigations.component';

describe('NavigationsComponent', () => {
  let component: NavigationsComponent;
  let fixture: ComponentFixture<NavigationsComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [NavigationsComponent]
    });
    fixture = TestBed.createComponent(NavigationsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
