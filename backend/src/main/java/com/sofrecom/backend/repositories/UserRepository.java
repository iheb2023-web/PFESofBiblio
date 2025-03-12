package com.sofrecom.backend.repositories;

import com.sofrecom.backend.dtos.UserDto;
import com.sofrecom.backend.dtos.UserMinDto;
import com.sofrecom.backend.dtos.UserUpdateDto;
import com.sofrecom.backend.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    @Query("SELECT  new com.sofrecom.backend.dtos.UserDto(u.id,u.firstname,u.lastname,u.email,u.image,u.job) from User u")
    Page<UserDto> findAllUsers(Pageable pageable);

    boolean existsByEmail(String email);
    @Query("SELECT new com.sofrecom.backend.dtos.UserMinDto(u.email, u.firstname, u.lastname,u.image) FROM User u WHERE u.email = :email")
    UserMinDto findUserMinInfo(@Param("email") String email);

    @Query("SELECT new com.sofrecom.backend.dtos.UserUpdateDto(u.id, u.firstname, u.lastname, u.email, u.image, u.job, u.birthday, u.number, u.role) FROM User u WHERE u.id = :id")
    Optional<UserUpdateDto> findUserUpdateDtoById(@Param("id") Long id);
}
