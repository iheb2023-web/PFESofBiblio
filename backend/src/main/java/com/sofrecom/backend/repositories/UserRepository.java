package com.sofrecom.backend.repositories;

import com.sofrecom.backend.dtos.UserDto;
import com.sofrecom.backend.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    @Query("SELECT  new com.sofrecom.backend.dtos.UserDto(u.id,u.firstname,u.lastname,u.email,u.image,u.job) from User u")
    Page<UserDto> findAllUsers(Pageable pageable);

    boolean existsByEmail(String email);
}
