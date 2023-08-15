FROM golang:1.21.0 AS build

ENV GOPATH=/
WORKDIR /app
COPY ./go.mod ./go.sum /app/
RUN go mod download
COPY ./ /app/
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o /cmd/main ./cmd/main.go


FROM ubuntu:23.10

WORKDIR /
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ Europe/Moscow

RUN apt-get update && \
    apt-get install -y curl libaio1 postgresql-client tzdata iputils-ping && \
    apt-get purge --autoremove -y && \
    rm -rf /var/lib/apt/lists/*
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

COPY --from=build /cmd/main /main

ENTRYPOINT ["./main"]
