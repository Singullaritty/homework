package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

const httpVar = "HTTP_PORT"

func main() {
	httpPort := ":8080"
	portFromEnv := os.Getenv(httpVar)
	// Start http server on port from evn or
	// default 8080
	if portFromEnv != "" {
		httpPort = ":" + portFromEnv
	}
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	// Listen to any http request to /
	http.HandleFunc("/", requestHandler)
	log.Printf("listening on %v\n", httpPort)
	if err := http.ListenAndServe(httpPort, logHandler(http.DefaultServeMux)); err != nil {
		log.Fatal(err)
	}
}

func requestHandler(w http.ResponseWriter, r *http.Request) {
	// Get system env vars
	env := os.Environ()
	fmt.Fprintln(w, "System environment variables:")
	for _, v := range env {
		fmt.Fprintf(w, "  %s\n", v)
	}
}

func logHandler(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s %s\n", r.RemoteAddr, r.Method, r.URL)
		h.ServeHTTP(w, r)
	})
}
