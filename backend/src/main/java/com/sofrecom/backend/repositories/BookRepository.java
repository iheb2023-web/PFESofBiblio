package com.sofrecom.backend.repositories;

import com.sofrecom.backend.entities.Book;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookRepository extends JpaRepository<Book, Long> {
    java.util.List<Book> findByOwner_Id(Long ownerId);
}
