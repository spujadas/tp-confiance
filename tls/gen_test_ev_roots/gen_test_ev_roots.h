#include <openssl/bio.h>
#include <openssl/x509.h>

int output_fingerprint (BIO *out, BIO *err, X509 *x) ;
int output_OID (BIO *out, BIO *err, char *oid) ;
int output_issuer (BIO *out, BIO *err, X509 *x) ;
int output_serialNumber (BIO *out, BIO *err, X509 *x) ;
