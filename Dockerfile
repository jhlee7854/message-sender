FROM --platform=$BUILDPLATFORM golang:alpine AS build

RUN apk add clang

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./

ARG TARGETOS
ARG TARGETARCH

RUN CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${TARGETARCH} CC=clang go build -ldflags '-s -w' -o /build/message-sender

FROM alpine

WORKDIR /app

COPY --from=build /build/message-sender .

EXPOSE 8080

ENTRYPOINT ["/app/message-sender"]
