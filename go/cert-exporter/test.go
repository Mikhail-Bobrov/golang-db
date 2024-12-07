package main

import (
	"crypto/x509"
	"encoding/pem"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"gopkg.in/yaml.v2"
	"golang.org/x/crypto/pkcs12"
)

var (
	configPath = flag.String("config.file", "", "Path to the configuration file")
	target     = flag.String("target", "", "Optional target label value")
	certExpiry *prometheus.GaugeVec
)

type CertificateConfig struct {
	Path     string `yaml:"path"`
	Format   string `yaml:"format"`
	Password string `yaml:"password,omitempty"`
}

type Config struct {
	Certificates []CertificateConfig `yaml:"certificates"`
}

func initMetrics() {
	if *target == "" {
		certExpiry = prometheus.NewGaugeVec(
			prometheus.GaugeOpts{
				Name: "probe_ssl_earliest_cert_expiry",
				Help: "Unix timestamp of SSL certificate expiry",
			},
			[]string{"filepath"},
		)
	} else {
		certExpiry = prometheus.NewGaugeVec(
			prometheus.GaugeOpts{
				Name: "probe_ssl_earliest_cert_expiry",
				Help: "Unix timestamp of SSL certificate expiry",
			},
			[]string{"filepath", "target"},
		)
	}
	prometheus.MustRegister(certExpiry)
}

func checkPEMCertificate(filepath string) {
	certPEM, err := ioutil.ReadFile(filepath)
	if err != nil {
		log.Printf("Failed to read certificate file %s - %v", filepath, err)
		return
	}

	block, _ := pem.Decode(certPEM)
	if block == nil || block.Type != "CERTIFICATE" {
		log.Printf("Failed to decode PEM block from file %s", filepath)
		return
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		log.Printf("Failed to parse certificate from file %s - %v", filepath, err)
		return
	}

	expiryTimestamp := cert.NotAfter.Unix()
	if *target == "" {
		certExpiry.WithLabelValues(filepath).Set(float64(expiryTimestamp))
	} else {
		certExpiry.WithLabelValues(filepath, *target).Set(float64(expiryTimestamp))
	}
}

func checkPFXCertificate(filepath, password string) {
	certPEM, err := ioutil.ReadFile(filepath)
	if err != nil {
		log.Printf("Failed to read PFX file %s - %v", filepath, err)
		return
	}

	blocks, err := pkcs12.ToPEM(certPEM, password)
	if err != nil {
		log.Printf("Failed to decode PFX file %s - %v", filepath, err)
		return
	}

	var cert *x509.Certificate
	for _, block := range blocks {
		if block.Type == "CERTIFICATE" {
			cert, err = x509.ParseCertificate(block.Bytes)
			if err != nil {
				log.Printf("Failed to parse certificate from PFX file %s - %v", filepath, err)
				return
			}
			break
		}
	}

	if cert == nil {
		log.Printf("No certificate found in PFX file %s", filepath)
		return
	}

	expiryTimestamp := cert.NotAfter.Unix()
	if *target == "" {
		certExpiry.WithLabelValues(filepath).Set(float64(expiryTimestamp))
	} else {
		certExpiry.WithLabelValues(filepath, *target).Set(float64(expiryTimestamp))
	}
}


func loadConfig(filepath string) (*Config, error) {
	file, err := os.Open(filepath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	decoder := yaml.NewDecoder(file)
	var config Config
	err = decoder.Decode(&config)
	if err != nil {
		return nil, err
	}

	return &config, nil
}

func checkCertificate(certConfig CertificateConfig) {
	switch certConfig.Format {
	case "pem":
		checkPEMCertificate(certConfig.Path)
	case "pfx":
		checkPFXCertificate(certConfig.Path, certConfig.Password)
	default:
		log.Printf("Unsupported certificate format: %s", certConfig.Format)
	}
}

func main() {
	flag.Parse()

	if *configPath == "" {
		log.Fatal("Please provide the path to the configuration file using --config.file")
	}

	config, err := loadConfig(*configPath)
	if err != nil {
		log.Fatalf("Failed to load configuration file %s - %v", *configPath, err)
	}

	initMetrics()

	http.HandleFunc("/metrics", func(w http.ResponseWriter, r *http.Request) {
		for _, certConfig := range config.Certificates {
			checkCertificate(certConfig)
		}
		promhttp.Handler().ServeHTTP(w, r)
	})

	log.Println("Starting server on :9116")
	log.Fatal(http.ListenAndServe(":9116", nil))
}
