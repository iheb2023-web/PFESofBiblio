package com.sofrecom.backend.dtos;

import com.sofrecom.backend.enums.Role;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@Getter
@AllArgsConstructor
public class UserDto {
    private Long id;
    private String firstname;
    private String lastname;
    private String email;
    private String image;
    private String job;
    private Role role;

    // Constructeur explicite
    public UserDto(Long id, String firstname, String lastname, String email, String image, String job) {
        this.id = id;
        this.firstname = firstname;
        this.lastname = lastname;
        this.email = email;
        this.image = image;
        this.job = job;

    }


}
