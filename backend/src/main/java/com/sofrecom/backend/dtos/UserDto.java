package com.sofrecom.backend.dtos;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class UserDto {
    private Long id;
    private String firstname;
    private String lastname;
    private String email;
    private String image;
    private String job;


}
