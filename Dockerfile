# syntax=docker/dockerfile:experimental
# Build container
FROM --platform=$TARGETPLATFORM golang AS build
ARG DIBS_TARGET
ARG TARGETPLATFORM

WORKDIR /app

RUN apt update
RUN apt install -y protobuf-compiler gcc make git file

RUN curl -Lo /tmp/dibs https://github.com/pojntfx/dibs/releases/latest/download/dibs-linux-amd64
RUN install /tmp/dibs /usr/local/bin

ENV GO111MODULE=on

RUN go get github.com/golang/protobuf/protoc-gen-go
RUN go get github.com/rakyll/statik

ADD . .

RUN dibs -generateSources
RUN dibs -build

# Run container
FROM --platform=$TARGETPLATFORM debian
ARG DIBS_TARGET
ARG TARGETPLATFORM

COPY --from=build /app/.bin/binaries/ipxebuilderd* /usr/local/bin/ipxebuilderd

CMD /usr/local/bin/ipxebuilderd