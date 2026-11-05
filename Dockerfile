FROM golang:1.27.3-alpine3.24 AS builder

WORKDIR /app
COPY . /app
RUN CGO_ENABLED=0 GOMAXPROCS=1 go build -p 1 -trimpath -o /app/glance .

FROM alpine:3.24.3

WORKDIR /app
COPY --from=builder /app/glance .
COPY vibenest /app/vibenest
COPY LICENSE /app/LICENSE

EXPOSE 8080/tcp
ENTRYPOINT ["/bin/sh", "/app/vibenest/entrypoint.sh"]
