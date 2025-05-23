package com.sofrecom.backend.services;

import com.sofrecom.backend.dtos.PasswordResetResponse;
import com.sofrecom.backend.entities.PasswordResetToken;
import com.sofrecom.backend.entities.User;
import com.sofrecom.backend.repositories.PasswordResetTokenRepository;
import com.sofrecom.backend.repositories.UserRepository;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.Optional;

@Service
public class PasswordResetService {

    private Environment env;

    public PasswordResetService(Environment env) {
        this.env = env;
    }

    @Autowired
    private PasswordResetTokenRepository tokenRepository;

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Transactional
    public void createPasswordResetTokenForUser(User user, String token) {
        tokenRepository.deleteByUser(user);
        PasswordResetToken passwordResetToken = new PasswordResetToken();
        passwordResetToken.setUser(user);
        passwordResetToken.setToken(token);
        LocalDateTime expirationDateTime = LocalDateTime.now().plusMinutes(5);
        Instant instant = expirationDateTime.atZone(ZoneId.systemDefault()).toInstant();
        Date expirationDate = Date.from(instant);
        passwordResetToken.setExpiryDate(expirationDate);
        tokenRepository.save(passwordResetToken);
    }

    public void sendPasswordResetEmail(String email, String token) throws MessagingException {
        MimeMessage mailMessage = mailSender.createMimeMessage();
        mailMessage.setFrom("noreply.sofbiblio@gmail.com");
        mailMessage.setRecipients(Message.RecipientType.TO, email);
        mailMessage.setSubject("Password Reset");
        String htmlTemplate =
                "<html>" + "\n" +
                        "<body marginheight=\"0\" topmargin=\"0\" marginwidth=\"0\" style=\"margin: 0px; background-color: #f2f3f8;\" leftmargin=\"0\">\n" +
                        "    <!--100% body table-->\n" +
                        "    <table cellspacing=\"0\" border=\"0\" cellpadding=\"0\" width=\"100%\" bgcolor=\"#f2f3f8\"\n" +
                        "        style=\"@import url(https://fonts.googleapis.com/css?family=Rubik:300,400,500,700|Open+Sans:300,400,600,700); font-family: 'Open Sans', sans-serif;\">\n" +
                        "        <tr>\n" +
                        "            <td>\n" +
                        "                <table style=\"background-color: #f2f3f8; max-width:670px;  margin:0 auto;\" width=\"100%\" border=\"0\"\n" +
                        "                    align=\"center\" cellpadding=\"0\" cellspacing=\"0\">\n" +
                        "                    <tr>\n" +
                        "                        <td style=\"height:80px;\">&nbsp;</td>\n" +
                        "                    </tr>\n" +
                        "                    <tr>\n" +
                        "                    </tr>\n" +
                        "                    <tr>\n" +
                        "                        <td style=\"height:20px;\">&nbsp;</td>\n" +
                        "                    </tr>\n" +
                        "                    <tr>\n" +
                        "                        <td>\n" +
                        "                            <table width=\"95%\" border=\"0\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\"\n" +
                        "                                style=\"max-width:670px;background:#fff; border-radius:3px; text-align:center;-webkit-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);-moz-box-shadow:0 6px 18px 0 rgba(0,0,0,.06);box-shadow:0 6px 18px 0 rgba(0,0,0,.06);\">\n" +
                        "                                <tr>\n" +
                        "                                    <td style=\"height:40px;\">&nbsp;</td>\n" +
                        "                                </tr>\n" +
                        "                                <tr>\n" +
                        "                                    <td style=\"padding:0 35px;\">\n" +
                        "                                        <h1 style=\"color:#1e1e2d; font-weight:500; margin:0;font-size:32px;font-family:'Rubik',sans-serif;\">You have\n" +
                        "                                            requested to reset your password</h1>\n" +
                        "                                        <span\n" +
                        "                                            style=\"display:inline-block; vertical-align:middle; margin:29px 0 26px; border-bottom:1px solid #cecece; width:100px;\"></span>\n" +
                        "                                        <p style=\"color:#455056; font-size:15px;line-height:24px; margin:0;\">\n" +
                        " Hello,\n" +
                        "\n" +
                        " \n" +
                        "\n" +
                        "We have sent you this email in response to your request to reset your password on SoftBiblio.\n" +
                        "\n" +
                        " \n" +
                        "\n" +
                        "To reset your password, this is your code:\n" +
                        "                                        </p>\n" +
                        "                                        <a href=\"" + "\"\n" +
                        "                                            style=\"background:#20e277;text-decoration:none !important; font-weight:500; margin-top:35px; color:#fff;text-transform:uppercase; font-size:14px;padding:10px 24px;display:inline-block;border-radius:50px;\">" +
                        token +
                        "</a>\n" +
                        "                                    </td>\n" +
                        "                                </tr>\n" +
                        "                                <tr>\n" +
                        "                                    <td style=\"height:40px;\">&nbsp;</td>\n" +
                        "                                </tr>\n" +
                        "                            </table>\n" +
                        "                        </td>\n" +
                        "                    <tr>\n" +
                        "                        <td style=\"height:20px;\">&nbsp;</td>\n" +
                        "                    </tr>\n" +
                        "                    <tr>\n" +
                        "                        <td style=\"text-align:center;\">\n" +
                        "                            <p style=\"font-size:14px; color:rgba(69, 80, 86, 0.7411764705882353); line-height:18px; margin:0 0 0;\">&copy; <strong>SofBiblio</strong></p>\n" +
                        "                        </td>\n" +
                        "                    </tr>\n" +
                        "                    <tr>\n" +
                        "                        <td style=\"height:80px;\">&nbsp;</td>\n" +
                        "                    </tr>\n" +
                        "                </table>\n" +
                        "            </td>\n" +
                        "        </tr>\n" +
                        "    </table>\n" +
                        "    <!--/100% body table-->\n" +
                        "</body>\n" +
                        "\n" +
                        "</html>";
        mailMessage.setContent(htmlTemplate, "text/html; charset=utf-8");
        mailSender.send(mailMessage);
    }

    public PasswordResetResponse resetPassword(String token, String newPassword) {
        try {
            PasswordResetToken passwordResetToken = tokenRepository.findByToken(token);
            if (passwordResetToken != null) {
                if (passwordResetToken.getExpiryDate()
                        .after(Date.from(LocalDateTime.now()
                                .atZone(ZoneId.systemDefault()).toInstant()))) {
                    Optional<User> userOptional = userRepository.findById((long) Math.toIntExact(Long.valueOf(passwordResetToken.getUser().getId())));
                    if (userOptional.isPresent()) {
                        User user = userOptional.get();
                        user.setPassword(passwordEncoder.encode(newPassword));
                        userRepository.save(user);
                        tokenRepository.delete(passwordResetToken);
                        return new PasswordResetResponse("Password reset successfully!");
                    } else {
                        return new PasswordResetResponse("User not found!");
                    }

                } else {
                    return new PasswordResetResponse("Token expired!");
                }

            } else {
                return new PasswordResetResponse("Token not found!");
            }


        } catch (Exception e) {
            System.out.println(e);
            return null;
        }
    }


    public String getTokenByEmail(String email) {
      User user =  this.userRepository.findByEmail(email).orElse(null);
      if(user != null) {
         PasswordResetToken token =this.tokenRepository.findByUser(user);
         if(token != null) {
             return token.getToken();
         }else return null;
      }
      return null;

    }

    public PasswordResetResponse changePassword(String email, String newPassword) {
       User user = this.userRepository.findByEmail(email).orElse(null);
       if(user != null) {
           user.setPassword(passwordEncoder.encode(newPassword));
           userRepository.save(user);
           return new PasswordResetResponse("Password changed successfully!");
       }
       return new PasswordResetResponse("Error");
    }
}