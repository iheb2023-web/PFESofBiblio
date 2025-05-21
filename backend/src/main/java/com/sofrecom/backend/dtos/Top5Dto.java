package com.sofrecom.backend.dtos;


import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@AllArgsConstructor
public class Top5Dto {
        private Long id;
        private String firstname;
        private String lastname;
        private String email;
        private Long nbEmprunts;

    }
