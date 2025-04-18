import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";

@Injectable({
  providedIn: 'root'
})
export class ReviewsService {

    private URL = 'http://localhost:8080/reviews';
     constructor(private http: HttpClient) {}

    getReviewsByIdBook(id : any)
    {
        return this.http.get(this.URL+ `/${id}`);
    }

    updateReview(review: any) {
        delete review.userReviewsDto;
        return this.http.put(`${this.URL}/${review.id}`, review);
    }
    
    deleteReview(id: any) {
        return this.http.delete<void>(`${this.URL}/${id}`);
    }

    addReviews(reviews : any)
    {
        return this.http.post(`${this.URL}`,reviews);
    }

    getReviewById(id : any)
    {
        return this.http.get(`${this.URL}/getReviewById/${id}`)
    }

}