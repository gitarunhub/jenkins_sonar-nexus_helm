FROM openjdk:11.0
WORKDIR /app
COPY ./target/devops-integration.jar /app/
EXPOSE 8080
CMD ["java","-jar","devops-integration.jar"]

