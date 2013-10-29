cat nul > tls-rootca-db.txt
cat nul > tls-subca-db.txt

md certs

openssl x509 -req -in tls-rootca-req.pem -extfile tls-rootca.cnf -extensions tls_rootca_crt_ext -signkey tls-rootca-key.pem -sha256 -days 3652 -out tls-rootca-crt.pem

openssl rand -hex 8 -out tls-rootca-crt.srl
openssl ca -batch -in tls-subca-req.pem -config tls-rootca.cnf -name tls_rootca -extensions tls_subca_crt_ext -policy tls_ca_crt_dnpolicy -days 2191 -out tls-subca-crt.pem

openssl rand -hex 8 -out tls-rootca-crt.srl
openssl ca -batch -in tls-rootca-ocsp-req.pem -config tls-rootca.cnf -name tls_rootca -extensions tls_rootca_ocsp_crt_ext -policy tls_server_crt_dnpolicy -days 2191 -out tls-rootca-ocsp-crt.pem

openssl rand -hex 8 -out tls-subca-crt.srl
openssl ca -batch -in tls-server-req.pem -config tls-subca.cnf -name tls_subca -extensions tls_server_crt_ext -policy tls_server_ev_crt_dnpolicy -days 365 -out tls-server-crt.pem

openssl rand -hex 8 -out tls-subca-crt.srl
openssl ca -batch -in tls-subca-ocsp-req.pem -config tls-subca.cnf -name tls_subca -extensions tls_subca_ocsp_crt_ext -policy tls_server_crt_dnpolicy -days 2191 -out tls-subca-ocsp-crt.pem

gen_test_ev_roots\gen_test_ev_roots tls-rootca-crt.pem 1.2.840.113556.1.8000.2554.29563.49294.43847.16581.44480.6974059.2493436.1.3 > test_ev_roots.txt

cat tls-server-crt.pem tls-subca-crt.pem > tls-server-chain.pem
cat tls-subca-crt.pem tls-rootca-crt.pem > tls-subca.cafile

call cleancrl.bat
