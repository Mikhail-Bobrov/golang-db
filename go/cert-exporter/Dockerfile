FROM golang:1.21 AS builder

WORKDIR /app

COPY . .

RUN go mod download

RUN go build -o cert_exporter .

FROM debian:stable-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY config.yaml /etc/cert_exporter/config.yaml
COPY --from=builder /app/cert_exporter /usr/local/bin/cert_exporter

EXPOSE 9116

CMD ["cert_exporter", "--config.file=/etc/cert_exporter/config.yaml"]
