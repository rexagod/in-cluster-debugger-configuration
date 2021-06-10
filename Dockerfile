FROM golang AS builder
ENV CGO_ENABLED=0 GOPATH=/go GO111MODULE=on
COPY . /go/src/controller
WORKDIR /go/src/controller
RUN go mod tidy
RUN go get github.com/go-delve/delve/cmd/dlv
RUN go build -gcflags="-N -l" -o /controller

FROM alpine AS runner
COPY --from=builder /controller /
COPY --from=builder /go/bin/dlv /
ENTRYPOINT ["/dlv", \
            "--listen=:40000", \
            "--headless=true", \
            "--api-version=2", \
            "--accept-multiclient", \
            "exec", "/controller"]
EXPOSE 40000
