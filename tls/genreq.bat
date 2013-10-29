openssl req -new -newkey rsa:2048 -nodes -keyout tls-rootca-key.pem -subj "/C=FR/O=Mon Organisme/OU=0002 147258369/OU=OpenSSL TLS Root CA" -sha256 -config req-empty-ev.cnf -out tls-rootca-req.pem
openssl req -new -newkey rsa:2048 -nodes -keyout tls-subca-key.pem -subj "/C=FR/O=Mon Organisme/OU=0002 147258369/OU=OpenSSL TLS Subordinate CA" -sha256 -config req-empty-ev.cnf -out tls-subca-req.pem
openssl req -new -newkey rsa:2048 -nodes -keyout tls-server-key.pem -subj "/jurC=FR/businessCategory=Private Organization/serialNumber=789456123/C=FR/postalCode=99000/ST=France/L=Ma Ville/street=1 rue du Village/O=Ma Boutique/OU=0002 789456123/CN=localhost" -sha256 -config req-empty-ev.cnf -out tls-server-req.pem
openssl req -new -newkey rsa:2048 -nodes -keyout tls-rootca-ocsp-key.pem -subj "/C=FR/O=Mon Organisme/OU=0002 147258369/CN=OpenSSL TLS Root CA OCSP Responder" -sha256 -config req-empty-ev.cnf -out tls-rootca-ocsp-req.pem
openssl req -new -newkey rsa:2048 -nodes -keyout tls-subca-ocsp-key.pem -subj "/C=FR/O=Mon Organisme/OU=0002 147258369/CN=OpenSSL TLS Subordinate CA OCSP Responder" -sha256 -config req-empty-ev.cnf -out tls-subca-ocsp-req.pem

call cleancrt.bat
