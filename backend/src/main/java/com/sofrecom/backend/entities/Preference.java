package com.sofrecom.backend.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

import java.io.Serializable;
import java.util.List;


@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Preference implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String preferredBookLength;

    @ElementCollection
    @CollectionTable(name = "preference_favorite_genres", joinColumns = @JoinColumn(name = "preference_id"))
    @Cascade(CascadeType.ALL)
    private List<String> favoriteGenres;

    @Cascade(CascadeType.ALL)
    @ElementCollection
    @CollectionTable(name = "preference_preferred_languages", joinColumns = @JoinColumn(name = "preference_id"))
    private List<String> preferredLanguages;

    @Cascade(CascadeType.ALL)
    @CollectionTable(name = "preference_favorite_authors", joinColumns = @JoinColumn(name = "preference_id"))
    @ElementCollection
    private List<String> favoriteAuthors;

    private String type;

    @JsonIgnore
    @OneToOne
    @JoinColumn(name = "user_id") // NOSONAR
    private User user;


}
