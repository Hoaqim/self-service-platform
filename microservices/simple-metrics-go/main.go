package main

import (
	"fmt"
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var opsProcessed = promauto.NewCounter(
	prometheus.CounterOpts{
		Name: "Total events",
		Help: "Total number of processed events",
	})

func main() {
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "OK")
	})

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		opsProcessed.Inc()
		fmt.Fprint(w, "Welcome in this simple go app")
	})

	http.Handle("/metrics", promhttp.Handle())

	http.ListenAndServe(":8080", nil)
}
