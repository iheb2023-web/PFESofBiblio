package com.sofrecom.backend.services;


import com.cloudinary.Cloudinary;
import com.cloudinary.Uploader;
import com.cloudinary.utils.ObjectUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CloudinaryServiceTest {

    @Mock
    private Cloudinary cloudinary;

    @Mock
    private Uploader uploader;

    @InjectMocks
    private CloudinaryService cloudinaryService;

    private MockMultipartFile multipartFile;

    @BeforeEach
    void setUp() {
        // Create a sample multipart file for testing
        multipartFile = new MockMultipartFile(
                "file",
                "test-image.jpg",
                "image/jpeg",
                "test image content".getBytes()
        );
    }

    @Test
    void uploadImage_ValidFile_ShouldReturnUrl() throws IOException {
        Map<String, Object> uploadResult = new HashMap<>();
        uploadResult.put("url", "https://cloudinary.com/test-image.jpg");

        when(cloudinary.uploader()).thenReturn(uploader);
        when(uploader.upload(any(byte[].class), eq(ObjectUtils.emptyMap()))).thenReturn(uploadResult);

        String result = cloudinaryService.uploadImage(multipartFile);

        assertNotNull(result);
        assertEquals("https://cloudinary.com/test-image.jpg", result);
        verify(cloudinary).uploader();
        verify(uploader).upload(multipartFile.getBytes(), ObjectUtils.emptyMap());
    }

    @Test
    void uploadImage_IOException_ShouldThrowException() throws IOException {
        when(cloudinary.uploader()).thenReturn(uploader);
        when(uploader.upload(any(byte[].class), eq(ObjectUtils.emptyMap())))
                .thenThrow(new IOException("Upload failed"));

        IOException exception = assertThrows(IOException.class, () ->
                cloudinaryService.uploadImage(multipartFile));
        assertEquals("Upload failed", exception.getMessage());
        verify(cloudinary).uploader();
        verify(uploader).upload(multipartFile.getBytes(), ObjectUtils.emptyMap());
    }

    @Test
    void uploadImage_EmptyFile_ShouldThrowIOException() throws IOException {
        MockMultipartFile emptyFile = new MockMultipartFile(
                "file",
                "empty.jpg",
                "image/jpeg",
                new byte[0]
        );

        when(cloudinary.uploader()).thenReturn(uploader);
        when(uploader.upload(any(byte[].class), eq(ObjectUtils.emptyMap())))
                .thenThrow(new IOException("Empty file"));

        IOException exception = assertThrows(IOException.class, () ->
                cloudinaryService.uploadImage(emptyFile));
        assertEquals("Empty file", exception.getMessage());
        verify(cloudinary).uploader();
        verify(uploader).upload(emptyFile.getBytes(), ObjectUtils.emptyMap());
    }
}