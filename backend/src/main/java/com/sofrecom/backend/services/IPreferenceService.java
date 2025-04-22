package com.sofrecom.backend.services;

import com.sofrecom.backend.entities.Preference;

import java.util.List;

public interface IPreferenceService {
    List<Preference> getPreferences();

    Preference addPreference(Preference preference);
}
