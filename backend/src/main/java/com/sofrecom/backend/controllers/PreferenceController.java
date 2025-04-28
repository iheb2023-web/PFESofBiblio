package com.sofrecom.backend.controllers;

import com.sofrecom.backend.dtos.PreferenceDto;
import com.sofrecom.backend.entities.Preference;
import com.sofrecom.backend.services.IPreferenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/preferences")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class PreferenceController {
    private final IPreferenceService preferenceService;


    @GetMapping()
    public List<Preference> getPreferences() {
        return this.preferenceService.getPreferences();
    }

    @PostMapping()
    public Preference addPreference(@RequestBody PreferenceDto preference) {
        return this.preferenceService.addPreference(preference);
    }

    @GetMapping("/{id}")
    public Preference getPreferenceByUserId(@PathVariable Long id){
        return  this.preferenceService.getPreferenceByUserId(id);
    }


}
