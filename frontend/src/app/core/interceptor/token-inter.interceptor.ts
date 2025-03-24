import { isPlatformBrowser } from '@angular/common';
import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent } from '@angular/common/http';
import { Injectable, PLATFORM_ID, Inject } from '@angular/core';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';

@Injectable()
export class TokenInterceptor implements HttpInterceptor {
  constructor(@Inject(PLATFORM_ID) private platformId: Object) {}

  private getCookie(name: string): string | null {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop()?.split(';').shift() || null;
    return null;
  }

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    if (isPlatformBrowser(this.platformId)) {
      const myToken = this.getCookie('token');  

      // Check if the URL is for a Google API request
      if (req.url.includes('googleapis.com')) {
        // If it's a Google API request, remove the Authorization header
        const cloneRequest = req.clone({
          headers: req.headers.delete('Authorization') // Remove Authorization header
        });
        return next.handle(cloneRequest);
      }

      // If the request is not to Google APIs, add the Authorization header
      if (myToken) {
        const cloneRequest = req.clone({
          setHeaders: {
            Authorization: `Bearer ${myToken}`
          }
        });

        return next.handle(cloneRequest).pipe(
          catchError((error) => {
            return throwError(error);
          })
        );
      }
    }

    return next.handle(req);
  }
}
