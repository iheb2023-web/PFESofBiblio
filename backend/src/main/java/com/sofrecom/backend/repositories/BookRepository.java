package com.sofrecom.backend.repositories;

import com.sofrecom.backend.entities.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BookRepository extends JpaRepository<Book, Long> {
    java.util.List<Book> findByOwner_Id(Long ownerId);

    @Query("SELECT COUNT(b) > 0 FROM Book b WHERE b.owner.email = :email AND b.id = :id")
    boolean checkOwnerBookByEmail(@Param("email") String email, @Param("id") Long id);

}
