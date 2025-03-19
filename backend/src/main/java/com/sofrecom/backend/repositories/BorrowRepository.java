package com.sofrecom.backend.repositories;

import com.sofrecom.backend.entities.Borrow;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BorrowRepository extends JpaRepository<Borrow, Long> {
}
