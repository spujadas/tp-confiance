#include <stdio.h>
#include <openssl/bio.h>
#include <openssl/x509.h>
#include <openssl/pem.h>
#include <openssl/bn.h>
#include <openssl/asn1.h>

#include "gen_test_ev_roots.h"

int main (int argc, char **argv) {
  int res = 1 ;
  BIO *err=NULL;
  BIO *cert=NULL;
  BIO *out=NULL;
  X509 *x=NULL;
  
  /* Check command-line syntax */
  if (argc != 3) {
    fprintf (stderr, "Error - Expected syntax is:\n") ;
    fprintf (stderr,
      "gen_test_ev_roots <EV OID> <PEM-encoded CA certificate file>\n") ;
    res = 1 ;
    goto end ;
  }

  /* Initialise stderr/stdout BIO */
  err = BIO_new_fp(stderr,BIO_NOCLOSE);
  out = BIO_new_fp(stdout,BIO_NOCLOSE);
  
  /* Initialise input file BIO */
  if ((cert=BIO_new(BIO_s_file())) == NULL) {
    ERR_print_errors(err);
    goto end;
  }
  
  /* Open file for reading */
  if (!BIO_read_filename(cert,argv[1])) {
    BIO_printf(err, "Error - Cannot open file %s\n", argv[1]);
    ERR_print_errors(err);
    goto end;
  }

  /* Read PEM-encoded certificate */
  x = PEM_read_bio_X509(cert, NULL, NULL, NULL);
  if (x == NULL) {
    BIO_printf(err, 
      "Error - Cannot read certificate (hint: check content of file %s)\n",
      argv[1]);
    ERR_print_errors(err);
    goto end;
  }
  
  /*
  1_fingerprint 99:A6:9B:E6:1A:FE:88:6B:4D:2B:82:00:7C:B8:54:FC:31:7E:15:39
  2_readable_oid 2.16.840.1.114028.10.1.2
  3_issuer MIHDMQswCQYDVQQGEwJVUzEUMBIGA1UEChMLRW50cnVzdC5uZXQxOzA5BgNVBAsTMnd3dy5lbnRydXN0Lm5ldC9DUFMgaW5jb3JwLiBieSByZWYuIChsaW1pdHMgbGlhYi4pMSUwIwYDVQQLExwoYykgMTk5OSBFbnRydXN0Lm5ldCBMaW1pdGVkMTowOAYDVQQDEzFFbnRydXN0Lm5ldCBTZWN1cmUgU2VydmVyIENlcnRpZmljYXRpb24gQXV0aG9yaXR5
  4_serial N0rSQw==
*/

  if (res = output_fingerprint (out, err, x)) goto end ;
  if (res = output_OID (out, err, argv[2])) goto end ;
  if (res = output_issuer (out, err, x)) goto end ;
  if (res = output_serialNumber (out, err, x)) goto end ;
    
end:
  if (x != NULL) X509_free(x);
  if (cert != NULL) BIO_free(cert);
  return res ;
}

int output_fingerprint (BIO *out, BIO *err, X509 *x) {
  int j;
  unsigned int len;
  unsigned char md[EVP_MAX_MD_SIZE];
  
  if (!X509_digest(x,EVP_sha1(),md,&len)) {
    BIO_printf(err,
      "Error - Out of memory while calculating certificate fingerprint\n");
    return 1 ;
  }
  
  BIO_printf(out, "1_fingerprint ") ;
  for (j=0; j<len; j++) {
    BIO_printf(out,"%02X%c",md[j], (j+1 == (int)len)?'\n':':');
  }
  
  return 0 ;
}

int output_OID (BIO *out, BIO *err, char *oid) {
  if (OBJ_txt2obj(oid, 1) == NULL) {
    BIO_printf(err,"Error - Invalid OID %s\n", oid);
    return 1 ;
  }
  BIO_printf(out, "2_readable_oid %s\n", oid) ;
  return 0 ;
}

int output_issuer (BIO *out, BIO *err, X509 *x) {
  X509_NAME *issuer ;
  BIO *b64 ;

  if ((b64 = BIO_push(BIO_new(BIO_f_base64()), out)) == NULL) {
    BIO_printf(err,
      "Error - Cannot initialise Base64 output filter for issuer\n");
    return 1 ;
  } 
  BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL) ;
  
  BIO_printf(out, "3_issuer ") ;
  
  issuer = X509_get_issuer_name(x) ;
  ASN1_item_i2d_bio(ASN1_ITEM_rptr(X509_NAME), b64, issuer);
  BIO_flush(b64);
  
  BIO_printf(out, "\n") ;
  return 0 ;
}

#include <openssl/x509v3.h>

int output_serialNumber (BIO *out, BIO *err, X509 *x) {
  ASN1_INTEGER *serial ;
  BIO *b64 ;
  BIGNUM *bn = NULL ;
  unsigned char *binserial = NULL ;
  int len ;
  int res = 1 ;

  if ((b64 = BIO_push(BIO_new(BIO_f_base64()), out)) == NULL) {
    BIO_printf(err,
      "Error - Cannot initialise Base64 output filter for serial number\n");
    goto end ;
  } 
  BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL) ;
  
  serial = X509_get_serialNumber(x) ;
  bn = ASN1_INTEGER_to_BN (serial, NULL) ;
  len = BN_num_bytes(bn);
  binserial = malloc(len) ;
  if (BN_bn2bin(bn, binserial) != len) {
    BIO_printf(err,
      "Error - Cannot get a binary representation of serial number\n");
    goto end ;
  }
  
  BIO_printf(out, "4_serial ") ;
  /* Assuming that serial number is positive, prepend 0x00 if first byte
     of serial number is >= 0x80 */
  if (binserial[0] & 0x80) {
    BIO_write(b64, "\0", 1);
  }
  BIO_write(b64, binserial, len);
  BIO_flush(b64);

  BIO_printf(out, "\n") ;
  
  res = 0 ;
end:
  if (bn != NULL) BN_free (bn) ;
  if (binserial != NULL) free (binserial) ;
  return res ;
}
