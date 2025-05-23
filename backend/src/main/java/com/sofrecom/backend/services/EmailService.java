package com.sofrecom.backend.services;

import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {
    private final JavaMailSender mailSender;
    @Value("${spring.mail.username}")
    private String fromEmailId;

    public void sendEmail(String toEmail, String subject, String text) throws MessagingException {
        MimeMessage mailMessage = mailSender.createMimeMessage();
        mailMessage.setFrom("noreply.sofbiblio@gmail.com");
        mailMessage.setRecipients(Message.RecipientType.TO, toEmail);
        mailMessage.setSubject("Password");
        String htmlTemplate ="<h1>Password</h1>"+text+"</br>";
        mailMessage.setContent(htmlTemplate, "text/html; charset=utf-8");
        mailSender.send(mailMessage);

    }

}
