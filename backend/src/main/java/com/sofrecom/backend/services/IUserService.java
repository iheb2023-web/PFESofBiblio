package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.AuthenticationResponse;
import com.sofrecom.backend.dtos.RegisterRequest;
import com.sofrecom.backend.dtos.UserDto;
import com.sofrecom.backend.entities.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface IUserService {
    public List<User> getAllUsers();
    public AuthenticationResponse addUser(RegisterRequest registerRequest);
    public Page<UserDto> getUsers(Pageable pageable);
}
