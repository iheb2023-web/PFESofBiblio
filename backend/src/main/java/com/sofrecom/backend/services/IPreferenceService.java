package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.PreferenceDto;
import com.sofrecom.backend.entities.Preference;

import java.util.List;

public interface IPreferenceService {
    List<Preference> getPreferences();

    Preference addPreference(PreferenceDto preference);

    Preference getPreferenceByUserId(Long id);
}
