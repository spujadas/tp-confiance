openssl ocsp -sha256 -index tls-rootca-db.txt -port 0.0.0.0:81 -rsigner tls-rootca-ocsp-crt.pem -rkey tls-rootca-ocsp-key.pem -CA tls-rootca-crt.pem -text
