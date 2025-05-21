package com.sofrecom.backend.services;

import static org.junit.jupiter.api.Assertions.*;


import com.sofrecom.backend.dtos.BookOwerDto;
import com.sofrecom.backend.dtos.BookUpdateDto;
import com.sofrecom.backend.entities.Book;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.repositories.BookRepository;
import com.sofrecom.backend.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BookServiceTest {

    @Mock
    private BookRepository bookRepository;

    @Mock
    private IUserService userService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SocketIOService socketIOService;

    @InjectMocks
    private BookService bookService;

    private Book book;
    private User user;
    private BookUpdateDto bookUpdateDto;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");

        book = new Book();
        book.setId(1L);
        book.setTitle("Test Book");
        book.setOwner(user);

        bookUpdateDto = new BookUpdateDto();
        bookUpdateDto.setTitle("Updated Title");
        bookUpdateDto.setAuthor("Updated Author");
    }

    @Test
    void addBook_ShouldSetAddedDateAndSave() {
        when(bookRepository.save(any(Book.class))).thenReturn(book);

        Book result = bookService.addBook(book);

        assertNotNull(result);
        assertEquals(LocalDate.now(), result.getAddedDate());
        verify(bookRepository).save(book);
    }

    @Test
    void getAll_ShouldReturnAllBooks() {
        List<Book> books = Arrays.asList(book);
        when(bookRepository.findAll()).thenReturn(books);

        List<Book> result = bookService.getAll();

        assertEquals(1, result.size());
        verify(bookRepository).findAll();
    }


    @Test
    void getBooksByUser_InvalidUserId_ShouldThrowException() {
        when(userService.getUserById(1L)).thenReturn(null);

        RuntimeException exception = assertThrows(RuntimeException.class, () ->
                bookService.getBooksByUser(1L));

        assertEquals("User not found with id: 1", exception.getMessage());
    }

    @Test
    void addNewBook_ShouldSetOwnerAndSave() {
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));
        when(bookRepository.save(any(Book.class))).thenReturn(book);

        Book result = bookService.addNewBook(book, "test@example.com");

        assertNotNull(result);
        assertEquals(user, result.getOwner());
        assertEquals(LocalDate.now(), result.getAddedDate());
        verify(bookRepository).save(book);
    }

    @Test
    void getBookById_ExistingId_ShouldReturnBook() {
        when(bookRepository.findById(1L)).thenReturn(Optional.of(book));

        Book result = bookService.getBookById(1L);

        assertNotNull(result);
        assertEquals(book.getId(), result.getId());
        verify(bookRepository).findById(1L);
    }

    @Test
    void getBookById_NonExistingId_ShouldReturnNull() {
        when(bookRepository.findById(1L)).thenReturn(Optional.empty());

        Book result = bookService.getBookById(1L);

        assertNull(result);
        verify(bookRepository).findById(1L);
    }

    @Test
    void checkOwnerBookByEmail_ShouldCallRepository() {
        when(bookRepository.checkOwnerBookByEmail("test@example.com", 1L)).thenReturn(true);

        boolean result = bookService.checkOwnerBookByEmail("test@example.com", 1L);

        assertTrue(result);
        verify(bookRepository).checkOwnerBookByEmail("test@example.com", 1L);
    }

    @Test
    void getAllBooksWithinEmailOwner_ShouldReturnBooks() {
        when(bookRepository.getAllBooksWithinEmailOwner("test@example.com")).thenReturn(Arrays.asList(book));

        List<Book> result = bookService.getAllBooksWithinEmailOwner("test@example.com");

        assertEquals(1, result.size());
        verify(bookRepository).getAllBooksWithinEmailOwner("test@example.com");
    }

    @Test
    void getBookOwnerById_ShouldReturnOwnerDto() {
        BookOwerDto ownerDto = new BookOwerDto();
        when(bookRepository.findBookOwerByIdBook(1L)).thenReturn(ownerDto);

        BookOwerDto result = bookService.getBookOwnerById(1L);

        assertNotNull(result);
        verify(bookRepository).findBookOwerByIdBook(1L);
    }

    @Test
    void deleteBook_ShouldCallDeleteById() {
        bookService.deleteBook(1L);

        verify(bookRepository).deleteById(1L);
    }

    @Test
    void updateBook_ExistingBook_ShouldUpdateFields() {
        when(bookRepository.findById(1L)).thenReturn(Optional.of(book));
        when(bookRepository.save(any(Book.class))).thenReturn(book);

        Book result = bookService.updateBook(1L, bookUpdateDto);

        assertNotNull(result);
        assertEquals("Updated Title", result.getTitle());
        assertEquals("Updated Author", result.getAuthor());
        verify(bookRepository).save(book);
    }

    @Test
    void updateBook_NonExistingBook_ShouldThrowException() {
        when(bookRepository.findById(1L)).thenReturn(Optional.empty());

        RuntimeException exception = assertThrows(RuntimeException.class, () ->
                bookService.updateBook(1L, bookUpdateDto));

        assertEquals("Book not found", exception.getMessage());
    }

    @Test
    void addBookSocket_ShouldSetOwnerAndSave() {
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));
        when(bookRepository.save(any(Book.class))).thenReturn(book);

        Book result = bookService.AddBookSocket(book, "test@example.com");

        assertNotNull(result);
        assertEquals(user, result.getOwner());
        assertEquals(LocalDate.now(), result.getAddedDate());
        verify(bookRepository).save(book);
    }
}