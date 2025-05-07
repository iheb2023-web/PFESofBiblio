package com.sofrecom.backend.dtos;

import com.sofrecom.backend.enums.Role;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserUpdateDto {
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
    private Boolean hasPreference;
    private Boolean hasSetPassword;

    public UserUpdateDto(Long id, String firstname, String lastname, String email, String image, String job, LocalDate birthday, Long number, Role role) {
        this.id = id;
        this.firstname = firstname;
        this.lastname = lastname;
        this.email = email;
        this.image = image;
        this.job = job;
        this.birthday = birthday;
        this.number = number;
        this.role = role;
    }


}
