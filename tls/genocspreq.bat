openssl ocsp -sha256 -issuer tls-rootca-crt.pem -cert tls-subca-crt.pem -reqout tls-subca-ocspreq.der
openssl ocsp -sha256 -issuer tls-subca-crt.pem -cert tls-server-crt.pem -reqout tls-server-ocspreq.der
