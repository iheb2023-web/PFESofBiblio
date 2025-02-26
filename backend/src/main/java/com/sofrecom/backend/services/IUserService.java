package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.AuthenticationResponse;
import com.sofrecom.backend.dtos.RegisterRequest;
import com.sofrecom.backend.entities.User;

import java.util.List;

public interface IUserService {
    public List<User> getAllUsers();
    public AuthenticationResponse addUser(RegisterRequest registerRequest);
}
