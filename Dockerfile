FROM --platform=$BUILDPLATFORM golang:alpine AS build

WORKDIR /build

RUN apk add clang lld

COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./

ARG TARGETPLATFORM
RUN xx-apk add musl-dev gcc
ENV CGO_ENABLED=1

RUN xx-go build -o /build/message-sender && \
    xx-verify /build/message-sender

FROM alpine

WORKDIR /app

COPY --from=build /build/message-sender .

EXPOSE 8080

ENTRYPOINT ["/app/message-sender"]
