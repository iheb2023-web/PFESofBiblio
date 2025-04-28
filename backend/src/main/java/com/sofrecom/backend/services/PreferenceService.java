package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.PreferenceDto;
import com.sofrecom.backend.entities.Preference;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.exceptions.ResourceNotFoundException;
import com.sofrecom.backend.repositories.PreferenceRepository;
import com.sofrecom.backend.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
@RequiredArgsConstructor
public class PreferenceService implements IPreferenceService {

    private final PreferenceRepository preferenceRepository;
    private final UserRepository userRepository;

    @Override
    public List<Preference> getPreferences() {
        return this.preferenceRepository.findAll();
    }

    @Override
    public Preference addPreference(PreferenceDto preference) {
        User user =  this.userRepository.findById(preference.getUserId()).orElse(null);
        
        Preference newPreference =Preference.builder()
                .preferredBookLength(preference.getPreferredBookLength())
                .favoriteGenres(preference.getFavoriteGenres())
                .preferredLanguages(preference.getPreferredLanguages())
                .favoriteAuthors(preference.getFavoriteAuthors())
                .type(preference.getType())
                .user(user)
                .build();
        return this.preferenceRepository.save(newPreference);
    }

    @Override
    public Preference getPreferenceByUserId(Long id) {
        return preferenceRepository.findPreferenceByUserId(id);
    }


}
