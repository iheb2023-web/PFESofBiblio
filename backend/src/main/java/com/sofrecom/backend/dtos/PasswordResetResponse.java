package com.sofrecom.backend.dtos;

import lombok.*;

@Data
@Getter
@Setter
@AllArgsConstructor
@Builder
public class PasswordResetResponse {
    private String status;
}