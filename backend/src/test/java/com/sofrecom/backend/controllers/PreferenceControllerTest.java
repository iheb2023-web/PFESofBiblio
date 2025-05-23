package com.sofrecom.backend.controllers;


import com.sofrecom.backend.dtos.PreferenceDto;
import com.sofrecom.backend.entities.Preference;
import com.sofrecom.backend.services.IPreferenceService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class PreferenceControllerTest {

    @Mock
    private IPreferenceService preferenceService;

    @InjectMocks
    private PreferenceController preferenceController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void getPreferences_shouldReturnListOfPreferences() {
        Preference pref1 = new Preference();
        Preference pref2 = new Preference();
        List<Preference> preferences = Arrays.asList(pref1, pref2);

        when(preferenceService.getPreferences()).thenReturn(preferences);

        List<Preference> result = preferenceController.getPreferences();

        assertEquals(2, result.size());
        verify(preferenceService).getPreferences();
    }

    @Test
    void addPreference_shouldReturnCreatedPreference() {
        PreferenceDto dto = new PreferenceDto();
        Preference createdPreference = new Preference();

        when(preferenceService.addPreference(dto)).thenReturn(createdPreference);

        Preference result = preferenceController.addPreference(dto);

        assertNotNull(result);
        verify(preferenceService).addPreference(dto);
    }

    @Test
    void getPreferenceByUserId_shouldReturnPreference() {
        Long userId = 1L;
        Preference preference = new Preference();

        when(preferenceService.getPreferenceByUserId(userId)).thenReturn(preference);

        Preference result = preferenceController.getPreferenceByUserId(userId);

        assertNotNull(result);
        verify(preferenceService).getPreferenceByUserId(userId);
    }
}
