package com.sofrecom.backend.services;

import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.repositories.BookRepository;
import com.sofrecom.backend.services.IUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Service
public class BookService implements IBookService {

    private final BookRepository bookRepository;
    private final IUserService userService;

    @Override
    public Book addBook(Book book) {
        return this.bookRepository.save(book);
    }

    @Override
    public List<Book> getAll() {
        return this.bookRepository.findAll();
    }

    @Override
    public List<Book> getBooksByUser(Long userId) {
        var userDto = userService.getUserById(userId);
        if (userDto == null) {
            throw new RuntimeException("User not found with id: " + userId);
        }
        return this.bookRepository.findByOwner_Id(userId);
    }
}
