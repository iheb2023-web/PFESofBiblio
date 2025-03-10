# Build stage
FROM maven:3.8.7-openjdk-18 AS build
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM amazoncorretto:17

#ARG PROFILE=dev
#ARG APP_VERSION=0.0.1-SNAPSHOT

WORKDIR /app
COPY --from=build /build/target/backend-*.jar /app/

EXPOSE 8081

ENV DB_URL=jdbc:mysql://softbiblio_database:3306/sofbiblio_db

CMD java -jar -Dspring.datasource.url=${DB_URL} backend-0.0.1-SNAPSHOT.jar