package com.sofrecom.backend.services;

import com.sofrecom.backend.entities.Book;

import java.util.List;

public interface IBookService {

    Book addBook(Book addBookDto);

    List<Book> getAll();
}
