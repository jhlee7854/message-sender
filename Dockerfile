FROM --platform=$BUILDPLATFORM golang:alpine AS build

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./

ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=1
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN apk add --no-progress --no-cache gcc musl-dev
RUN ls -al /usr/bin

RUN if [ "${GOARCH}" = "amd64" ]; then CC=gcc go build -tags musl -ldflags '-s -w' -o /build/message-sender; else CC=aarch64-alpine-linux-musl-gcc go build -tags musl -ldflags '-s -w' -o /build/message-sender; fi

FROM alpine

WORKDIR /app

COPY --from=build /build/message-sender .

EXPOSE 8080

ENTRYPOINT ["/app/message-sender"]
