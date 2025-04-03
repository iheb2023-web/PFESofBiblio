package com.sofrecom.backend.repositories;

import com.sofrecom.backend.dtos.BookOwerDto;
import com.sofrecom.backend.entities.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface BookRepository extends JpaRepository<Book, Long> {
    java.util.List<Book> findByOwner_Id(Long ownerId);

    @Query("SELECT COUNT(b) > 0 FROM Book b WHERE b.owner.email = :email AND b.id = :id")
    boolean checkOwnerBookByEmail(@Param("email") String email, @Param("id") Long id);

    @Query("select b from Book b where b.owner.email != :email")
    List<Book> getAllBooksWithinEmailOwner(@Param("email") String email);

    @Query("select new com.sofrecom.backend.dtos.BookOwerDto(b.owner.email, b.owner.firstname, b.owner.lastname, b.owner.image) from Book b where b.id = :id")
    BookOwerDto findBookOwerByIdBook(@Param("id") Long id);

}
