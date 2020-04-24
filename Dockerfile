# Build the manager binary
FROM golang:1-alpine as builder

## GOLANG env
ARG GOPROXY="https://proxy.golang.org,direct"
ARG GO111MODULE="on"
ARG CGO_ENABLED=0
ARG GOOS=linux 
ARG GOARCH=amd64 

# Copy go.mod and download dependencies
WORKDIR /ec2-metadata-test-proxy

# Build
COPY . . 
RUN go build -a -o ec2-metadata-test-proxy cmd/ec2-metadata-test-proxy.go
# In case the target is build for testing:
# $ docker build  --target=builder -t test .
ENTRYPOINT ["ec2-metadata-test-proxy"]

# Copy the ec2-metadata-test-proxy binary into a thin image
FROM amazonlinux:2 as amazonlinux
FROM scratch
WORKDIR /
COPY --from=builder /ec2-metadata-test-proxy .
COPY --from=amazonlinux /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/
COPY THIRD_PARTY_LICENSES .
ENTRYPOINT ["/ec2-metadata-test-proxy"]
