FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM golang:alpine AS build

RUN apk add clang lld
COPY --from=xx / /

WORKDIR /build

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
