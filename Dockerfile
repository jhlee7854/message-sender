FROM --platform=$BUILDPLATFORM golang:alpine AS build
ARG TARGETOS
ARG TARGETARCH

# RUN apk add --no-progress --no-cache gcc musl-dev
# RUN apk add --upgrade --no-cache ca-certificates && update-ca-certificates

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./

RUN CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags '-s -w' -o /build/message-sender
# RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -tags musl -ldflags '-extldflags "-static"' -o /build/message-sender

FROM alpine

WORKDIR /app

# COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /build/message-sender .

EXPOSE 8080

ENTRYPOINT ["/app/message-sender"]
