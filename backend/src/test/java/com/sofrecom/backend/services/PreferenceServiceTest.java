package com.sofrecom.backend.services;


import com.sofrecom.backend.dtos.PreferenceDto;
import com.sofrecom.backend.entities.Preference;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.repositories.PreferenceRepository;
import com.sofrecom.backend.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;


@ExtendWith(MockitoExtension.class)
class PreferenceServiceTest {

    @Mock
    private PreferenceRepository preferenceRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private PreferenceService preferenceService;

    private User user;
    private Preference preference;
    private PreferenceDto preferenceDto;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");

        preference = Preference.builder()
                .id(1L)
                .preferredBookLength("Short")
                .favoriteGenres(Arrays.asList("Fiction", "Mystery"))
                .preferredLanguages(Arrays.asList("English"))
                .favoriteAuthors(Arrays.asList("Author A"))
                .type("Book")
                .user(user)
                .build();

        preferenceDto = new PreferenceDto();
        preferenceDto.setUserId(1L);
        preferenceDto.setPreferredBookLength("Short");
        preferenceDto.setFavoriteGenres(Arrays.asList("Fiction", "Mystery"));
        preferenceDto.setPreferredLanguages(Arrays.asList("English"));
        preferenceDto.setFavoriteAuthors(Arrays.asList("Author A"));
        preferenceDto.setType("Book");
    }

    @Test
    void getPreferences_ShouldReturnAllPreferences() {
        // Arrange
        List<Preference> preferences = Arrays.asList(preference);
        when(preferenceRepository.findAll()).thenReturn(preferences);

        // Act
        List<Preference> result = preferenceService.getPreferences();

        // Assert
        assertEquals(1, result.size());
        assertEquals(preference, result.get(0));
        verify(preferenceRepository).findAll();
    }

    @Test
    void addPreference_ValidUser_ShouldSavePreference() {
        // Arrange
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(preferenceRepository.save(any(Preference.class))).thenReturn(preference);

        // Act
        Preference result = preferenceService.addPreference(preferenceDto);

        // Assert
        assertNotNull(result);
        assertEquals("Short", result.getPreferredBookLength());
        assertEquals(Arrays.asList("Fiction", "Mystery"), result.getFavoriteGenres());
        assertEquals(user, result.getUser());
        verify(userRepository).findById(1L);
        verify(preferenceRepository).save(any(Preference.class));
    }

    @Test
    void addPreference_NonExistingUser_ShouldSavePreferenceWithNullUser() {
        // Arrange
        Preference preferenceWithNullUser = Preference.builder()
                .id(1L)
                .preferredBookLength("Short")
                .favoriteGenres(Arrays.asList("Fiction", "Mystery"))
                .preferredLanguages(Arrays.asList("English"))
                .favoriteAuthors(Arrays.asList("Author A"))
                .type("Book")
                .user(null)
                .build();
        when(userRepository.findById(1L)).thenReturn(Optional.empty());
        when(preferenceRepository.save(any(Preference.class))).thenReturn(preferenceWithNullUser);


        Preference result = preferenceService.addPreference(preferenceDto);

        assertNotNull(result);
        verify(userRepository).findById(1L);
        verify(preferenceRepository).save(any(Preference.class));
    }

    @Test
    void getPreferenceByUserId_ExistingPreference_ShouldReturnPreference() {
        // Arrange
        when(preferenceRepository.findPreferenceByUserId(1L)).thenReturn(preference);

        // Act
        Preference result = preferenceService.getPreferenceByUserId(1L);

        // Assert
        assertNotNull(result);
        assertEquals(preference, result);
        verify(preferenceRepository).findPreferenceByUserId(1L);
    }

    @Test
    void getPreferenceByUserId_NonExistingPreference_ShouldReturnNull() {
        // Arrange
        when(preferenceRepository.findPreferenceByUserId(1L)).thenReturn(null);

        // Act
        Preference result = preferenceService.getPreferenceByUserId(1L);

        // Assert
        assertNull(result);
        verify(preferenceRepository).findPreferenceByUserId(1L);
    }
}