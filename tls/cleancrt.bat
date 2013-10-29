@echo off
del tls-rootca-crt.pem
del tls-rootca-crt.srl
del tls-rootca-crt.srl.old

del tls-subca-crt.pem
del tls-subca-crt.srl
del tls-subca-crt.srl.old

del tls-server-crt.pem
del tls-rootca-ocsp-crt.pem
del tls-subca-ocsp-crt.pem

del tls-cafile-chain.pem
del tls-server-chain.pem

del tls-rootca-db.txt
del tls-rootca-db.txt.old
del tls-subca-db.txt
del tls-subca-db.txt.old
del tls-rootca-db.txt.attr
del tls-rootca-db.txt.attr.old
del tls-subca-db.txt.attr
del tls-subca-db.txt.attr.old

del test_ev_roots.txt

rmdir /s /q certs

call cleancrl.bat