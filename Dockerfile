FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM golang:alpine AS build

RUN apk add clang lld

COPY --from=xx / /

ARG TARGETPLATFORM

RUN xx-info env

RUN xx-apk add musl-dev gcc
ENV CGO_ENABLED=1
RUN xx-go build -tags musl -ldflags '-s -w' -o /build/message-sender
