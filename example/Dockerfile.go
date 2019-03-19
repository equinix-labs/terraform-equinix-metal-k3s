FROM golang:latest
RUN mkdir /app
ADD app.go /app/
WORKDIR /app
RUN go build -o main .
CMD ["/app/main"]
