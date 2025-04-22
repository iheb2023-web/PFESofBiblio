package com.sofrecom.backend.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;


@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Preference {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String preferredBookLength;
    @ElementCollection
    private List<String> favoriteGenres;
    @ElementCollection
    private List<String> preferredLanguages;
    @ElementCollection
    private List<String> favoriteAuthors;
    private String type;

    @JsonIgnore
    @OneToOne
    @JoinColumn(name = "user_id")
    private User user;


}
