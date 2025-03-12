package com.sofrecom.backend.dtos;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@AllArgsConstructor
public class UserMinDto {
    private String email;
    private String firstname;
    private String lastname;
    private String image;
}
