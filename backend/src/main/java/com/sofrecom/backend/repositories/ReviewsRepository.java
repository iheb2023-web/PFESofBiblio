package com.sofrecom.backend.repositories;

import com.sofrecom.backend.dtos.ReviewsDto;
import com.sofrecom.backend.entities.Reviews;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReviewsRepository extends JpaRepository<Reviews, Long> {

    @Query("select new com.sofrecom.backend.dtos.ReviewsDto(" +
            "r.id,r.book.id, r.content, r.rating, r.createdAt, r.updatedAt, " +
            "new com.sofrecom.backend.dtos.UserReviewsDto(u.id, u.email, u.firstname, u.lastname, u.image)) " +
            "from Reviews r join r.user u " +
            "where r.book.id = :id " +
            "order by COALESCE(r.updatedAt, r.createdAt) desc")
    List<ReviewsDto> getReviewsByIdBook(@Param("id") Long id);


}
