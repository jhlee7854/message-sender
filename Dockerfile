FROM --platform=$BUILDPLATFORM golang:alpine AS build
ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-progress --no-cache gcc musl-dev
# RUN apk add --upgrade --no-cache ca-certificates && update-ca-certificates

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./

RUN if [[ "${TARGETARCH}" -eq "amd64" ]]; then CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags '-s -w' -o /build/message-sender; else CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${TARGETARCH} CC=aarch64-alpine-linux-musl-gcc go build -ldflags '-s -w' -o /build/message-sender; fi
# RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -tags musl -ldflags '-extldflags "-static"' -o /build/message-sender

FROM alpine

WORKDIR /app

# COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /build/message-sender .

EXPOSE 8080

ENTRYPOINT ["/app/message-sender"]
