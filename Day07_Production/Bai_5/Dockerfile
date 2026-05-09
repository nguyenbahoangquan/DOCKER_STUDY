# Day 6
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Day 7 - Security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /app/target/*.jar app.jar
RUN chown -R appuser:appgroup /app
# chay voi user binh thuong, khong phai root
USER appuser
# Day 3:: 
EXPOSE 8080
ENTRYPOINT ["java"]
CMD ["-jar", "app.jar"]
