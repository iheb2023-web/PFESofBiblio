package com.sofrecom.backend.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfiguration {
    private final JwtAuthenticationFilter jwtAuthFilter;
    private final AuthenticationProvider authenticationProvider;

    @Bean
    @SuppressWarnings("java:S4502") // CSRF disabled safely due to stateless JWT authentication
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception
    {

        http
                .csrf()
                // CSRF protection is disabled because the application uses stateless JWT-based authentication.
                // No server-side sessions or cookies are used, eliminating the risk of CSRF attacks.
                // The JwtAuthenticationFilter validates JWTs in the Authorization header for all protected requests.
                .disable() // NOSONAR
                .cors()
                .and()
                .authorizeHttpRequests()
                .requestMatchers("/users/login","/users/**", "/books/**","/password-reset/**", "/borrows/**","/users", "/reviews/**","/preferences/**","/swagger-ui/**","/swagger-ui.html","/v3/api-docs/**","/v3/api-docs.yaml")
                .permitAll()
                .anyRequest()
                .authenticated()
                .and()
                .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                .and()
                .authenticationProvider(authenticationProvider)
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);




        return http.build();
    }

}
