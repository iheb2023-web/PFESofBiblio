package com.sofrecom.backend.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.sofrecom.backend.enums.Role;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.Collection;
import java.util.List;

@SuppressWarnings("java:S7027")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity // NOSONAR
public class User implements UserDetails, Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String firstname;
    private String lastname;
    private String email;
    private String image;
    private String job;
    private LocalDate birthday;
    private Long number;
    @Enumerated(EnumType.STRING)
    private Role role;
    private String password;

    @OneToMany(mappedBy = "owner") // NOSONAR
    private List<Book> books;

    @JsonIgnore
    @OneToMany(mappedBy = "borrower") // NOSONAR
    private List<Borrow>  borrows;

    @SuppressWarnings("java:S7027")
    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL) // NOSONAR
    private Preference preference;

    private Boolean hasPreference;

    private Boolean hasSetPassword;


    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return role.getAuthorities();
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
