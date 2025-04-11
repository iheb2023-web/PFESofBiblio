package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.BookOwerDto;
import com.sofrecom.backend.dtos.BookUpdateDto;
import com.sofrecom.backend.entities.Book;

import java.util.List;

public interface IBookService {

    Book addBook(Book addBookDto);

    List<Book> getAll();
    
    List<Book> getBooksByUser(Long userId);

    Book addNewBook(Book book, String email);

    Book getBookById(Long id);

    boolean checkOwnerBookByEmail(String email, Long id);

    List<Book> getAllBooksWithinEmailOwner(String email);

    BookOwerDto getBookOwnerById(Long idbook);

    void deleteBook(Long id);

    Book updateBook(Long id, BookUpdateDto BookDto);

    public Book AddBookSocket(Book book,String email);
}
