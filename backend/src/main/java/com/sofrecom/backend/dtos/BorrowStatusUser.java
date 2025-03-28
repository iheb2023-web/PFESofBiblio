package com.sofrecom.backend.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class BorrowStatusUser {
    private int approved;
    private int pending;
    private int rejected;
    private int progress;

}
