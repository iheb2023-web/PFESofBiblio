package com.sofrecom.backend.repositories;

import com.sofrecom.backend.entities.Preference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;


public interface PreferenceRepository extends JpaRepository<Preference,Long> {

    @Query("select p from Preference p where p.user.id = :id")
    Preference findPreferenceByUserId(@Param("id") Long id);
}
