package com.sofrecom.backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import io.github.cdimascio.dotenv.Dotenv;
import org.junit.jupiter.api.BeforeAll;

@SpringBootTest(classes = BackendApplication.class)
class BackendApplicationTests {

	@BeforeAll
	static void loadEnv() {
		Dotenv dotenv = Dotenv.load();
		dotenv.entries().forEach(entry -> System.setProperty(entry.getKey(), entry.getValue()));
	}
	@Test
	void contextLoads() {
		// This method is intentionally empty as it serves as a basic test to verify
		// that the Spring application context loads successfully without any configuration errors.
		// If the context fails to load, the test will fail, indicating issues with the application setup.
	}
}

