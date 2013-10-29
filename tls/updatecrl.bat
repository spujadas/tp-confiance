openssl ca -gencrl -config tls-rootca.cnf -name tls_rootca -crlexts tls_rootca_crl_ext -out tls-rootca-crl.pem
openssl ca -gencrl -config tls-subca.cnf -name tls_subca -crlexts tls_subca_crl_ext -out tls-subca-crl.pem
openssl crl -in tls-rootca-crl.pem -outform DER -out tls-rootca-crl.der
openssl crl -in tls-subca-crl.pem -outform DER -out tls-subca-crl.der
