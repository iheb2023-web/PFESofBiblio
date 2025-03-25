package com.sofrecom.backend.dtos;

import com.sofrecom.backend.enums.Role;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@AllArgsConstructor
public class UserMinDto {
    private Long id;
    private String email;
    private String firstname;
    private String lastname;
    private String image;
    @Enumerated(EnumType.STRING)
    private Role role;
}
