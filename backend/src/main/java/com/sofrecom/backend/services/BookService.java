package com.sofrecom.backend.services;

import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.repositories.BookRepository;
import com.sofrecom.backend.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@RequiredArgsConstructor
@Service
public class BookService implements IBookService {

    private final BookRepository bookRepository;
    private final IUserService userService;
    private final UserRepository userRepository;

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

    @Override
    public Book addNewBook(Book book, String email) {
        book.setAddedDate(LocalDate.now());
        User user = this.userRepository.findByEmail(email).orElse(null);
        book.setOwner(user);
        return this.bookRepository.save(book);
    }

    @Override
    public Book getBookById(Long id) {
        return this.bookRepository.findById(id).orElse(null);
    }

    @Override
    public boolean checkOwnerBookByEmail(String email, Long id) {
        return this.bookRepository.checkOwnerBookByEmail(email,id);
    }
}
