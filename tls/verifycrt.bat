openssl verify -untrusted tls-subca-crt.pem -CAfile tls-cafile-chain.pem -crl_check_all -verbose tls-server-crt.pem
