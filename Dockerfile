FROM eclipse-temurin:17-jre
WORKDIR /app

# 通过构建参数指定环境，默认 prod
ARG ENV=prod
ENV SPRING_PROFILES_ACTIVE=${ENV}

COPY target/demo-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080 9090
ENTRYPOINT ["java", "-jar", "app.jar"]
