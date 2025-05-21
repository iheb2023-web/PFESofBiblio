package com.sofrecom.backend.dtos;

import com.sofrecom.backend.enums.Role;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class UserMinDto {
    private Long id;
    private String email;
    private String firstname;
    private String lastname;
    private String image;
    @Enumerated(EnumType.STRING)
    private Role role;
    private boolean hasPreference;
    private boolean hasSetPassword;

    public UserMinDto(Long id, String email, String firstname, String lastname, String image, Role role) {
        this.id = id;
        this.email = email;
        this.firstname = firstname;
        this.lastname = lastname;
        this.image = image;
        this.role = role;

    }
}
