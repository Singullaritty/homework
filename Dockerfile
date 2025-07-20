FROM golang:1.24-bullseye AS build
WORKDIR /opt
COPY web-app/ ./
RUN go build -o .

FROM busybox:1.37
COPY --from=build /opt/web-app /homework/web-app
WORKDIR /homework
RUN adduser -D -u 1009 gopher
USER 1009
ENTRYPOINT ["/homework/web-app"]