package com.sofrecom.backend.dtos;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PreferenceDto {
    private String preferredBookLength;
    private List<String> favoriteGenres;
    private List<String> preferredLanguages;
    private List<String> favoriteAuthors;
    private String type;
    private Long userId;






}
