package com.sofrecom.backend.services;

import com.sofrecom.backend.entities.Preference;
import com.sofrecom.backend.repositories.PreferenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
@RequiredArgsConstructor
public class PreferenceService implements IPreferenceService {

    private final PreferenceRepository preferenceRepository;

    @Override
    public List<Preference> getPreferences() {
        return this.preferenceRepository.findAll();
    }

    @Override
    public Preference addPreference(Preference preference) {
        return this.preferenceRepository.save(preference);

    }
}
