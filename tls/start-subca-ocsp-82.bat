openssl ocsp -index tls-subca-db.txt -port 0.0.0.0:82 -rsigner tls-subca-ocsp-crt.pem -rkey tls-subca-ocsp-key.pem -CA tls-subca-crt.pem -text
