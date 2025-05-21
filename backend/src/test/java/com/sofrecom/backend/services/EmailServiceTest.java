package com.sofrecom.backend.services;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mail.javamail.JavaMailSender;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class EmailServiceTest {

    private JavaMailSender mailSender;
    private EmailService emailService;

    @BeforeEach
    public void setUp() {
        mailSender = mock(JavaMailSender.class);
        emailService = new EmailService(mailSender);
    }

    @Test
    void testSendEmail() throws MessagingException, IOException {
        String toEmail = "recipient@example.com";
        String subject = "Password";
        String text = "Your temporary password is: 123456";

        MimeMessage mimeMessage = new MimeMessage((jakarta.mail.Session) null);
        when(mailSender.createMimeMessage()).thenReturn(mimeMessage);


        emailService.sendEmail(toEmail, subject, text);

        verify(mailSender, times(1)).send(mimeMessage);
        assertEquals("Password", mimeMessage.getSubject());
        assertTrue(mimeMessage.getContent().toString().contains("Your temporary password is: 123456"));
    }
}
