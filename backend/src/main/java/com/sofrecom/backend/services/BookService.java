package com.sofrecom.backend.services;

import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.repositories.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Service
public class BookService implements IBookService {

    private final BookRepository bookRepository;
    @Override
    public Book addBook(Book book) {
        return this.bookRepository.save(book);
    }

    @Override
    public List<Book> getAll() {
        return this.bookRepository.findAll();
    }
}
