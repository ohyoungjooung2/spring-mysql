FROM openjdk:8u111-jdk-alpine
VOLUME /tmp
ADD /target/gs-mysql-data-0.1.0.jar app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
