package com.sofrecom.backend.repositories;

import com.sofrecom.backend.dtos.Top5Dto;
import com.sofrecom.backend.dtos.UserDto;
import com.sofrecom.backend.dtos.UserMinDto;
import com.sofrecom.backend.dtos.UserUpdateDto;
import com.sofrecom.backend.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    @Query("SELECT  new com.sofrecom.backend.dtos.UserDto(u.id,u.firstname,u.lastname,u.email,u.image,u.job,u.role) from User u")
    Page<UserDto> findAllUsers(Pageable pageable);

    @Query("SELECT  new com.sofrecom.backend.dtos.UserDto(u.id,u.firstname,u.lastname,u.email,u.image,u.job)  from User u WHERE " +
            "LOWER(u.firstname) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(u.lastname) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(u.email) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(u.job) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<UserDto> findBySearchTerm(@Param("searchTerm") String searchTerm, Pageable pageable);

    boolean existsByEmail(String email);
    @Query("SELECT new com.sofrecom.backend.dtos.UserMinDto(u.id,u.email, u.firstname, u.lastname,u.image, u.role ,u.hasPreference,u.hasSetPassword) FROM User u WHERE u.email = :email")
    UserMinDto findUserMinInfo(@Param("email") String email);

    @Query("SELECT new com.sofrecom.backend.dtos.UserUpdateDto(u.id, u.firstname, u.lastname, u.email, u.image, u.job, u.birthday, u.number, u.role) FROM User u WHERE u.id = :id")
    Optional<UserUpdateDto> findUserUpdateDtoById(@Param("id") Long id);

    @Query("SELECT u FROM User u WHERE " +
            "LOWER(u.email) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(u.job) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(u.firstname) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
            "LOWER(u.lastname) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    List<UserDto> searchUsers(@Param("searchTerm") String searchTerm);

    @Query("SELECT  u.id FROM  User u where u.email = :email")
    Long findIdByEmail(@Param("email") String email);

    @Query("SELECT count(*) FROM Borrow b WHERE b.borrower.email = :email")
    Long numbreOfBorrowsByUser(@Param("email") String email);

    @Query("SELECT count(*) FROM Book b WHERE b.owner.email = :email")
    Long numbreOfBooksByUser(@Param("email") String email);


    @Query("SELECT new com.sofrecom.backend.dtos.Top5Dto(u.id, u.firstname, u.lastname, u.email, COUNT(b)) " +
            "FROM Borrow b JOIN b.borrower u " +
            "GROUP BY u.id, u.firstname, u.lastname, u.email " +
            "ORDER BY COUNT(b) DESC")
    List<Top5Dto> findTop5Borrowers(Pageable pageable);



}
