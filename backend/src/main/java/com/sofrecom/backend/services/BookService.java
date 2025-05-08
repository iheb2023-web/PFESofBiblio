package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.BookOwerDto;
import com.sofrecom.backend.dtos.BookUpdateDto;
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
    private final SocketIOService socketIOService;

    @Override
    public Book addBook(Book book) {
        book.setAddedDate(LocalDate.now());
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

    @Override
    public List<Book> getAllBooksWithinEmailOwner(String email) {
        return this.bookRepository.getAllBooksWithinEmailOwner(email);
    }

    @Override
    public BookOwerDto getBookOwnerById(Long idbook) {
        return this.bookRepository.findBookOwerByIdBook(idbook);
    }

    @Override
    public void deleteBook(Long id) {

        this.bookRepository.deleteById(id);
    }
    @Override
    public Book updateBook(Long id, BookUpdateDto BookDto) {
        Book existingBook = bookRepository.findById(id).orElseThrow(() -> new RuntimeException("Book not found"));

        if (BookDto.getTitle() != null) {
            existingBook.setTitle(BookDto.getTitle());
        }
        if (BookDto.getAuthor() != null) {
            existingBook.setAuthor(BookDto.getAuthor());
        }
        if (BookDto.getDescription() != null) {
            existingBook.setDescription(BookDto.getDescription());
        }
        if (BookDto.getCoverUrl() != null) {
            existingBook.setCoverUrl(BookDto.getCoverUrl());
        }
        if (BookDto.getPublishedDate() != null) {
            existingBook.setPublishedDate(BookDto.getPublishedDate());
        }
        if (BookDto.getIsbn() != null) {
            existingBook.setIsbn(BookDto.getIsbn());
        }
        if (BookDto.getCategory() != null) {
            existingBook.setCategory(BookDto.getCategory());
        }
        if (BookDto.getPageCount() != 0) {
            existingBook.setPageCount(BookDto.getPageCount());
        }
        if (BookDto.getLanguage() != null) {
            existingBook.setLanguage(BookDto.getLanguage());
        }
        return bookRepository.save(existingBook);
    }

    public Book AddBookSocket(Book book,String email) {
        book.setAddedDate(LocalDate.now());
        User user = this.userRepository.findByEmail(email).orElse(null);
        book.setOwner(user);

        return this.bookRepository.save(book);
    }


}
