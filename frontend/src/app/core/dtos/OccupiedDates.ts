export class OccupiedDates {
  from: Date;
  to: Date;

  constructor(from: string, to: string) {
    this.from = new Date(from);
    this.to = new Date(to);
  }
}
