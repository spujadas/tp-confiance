use strict ;
use warnings ;

use HTTP::Daemon;

# Change values below as required
my $port = 80 ;

my $tsa_cnf_file = 'tsa-ts.cnf' ;
my $tsa_section = 'tsa' ;
my $tsa_key_file = 'tsa-key.pem' ;
my $tsa_crt_file = 'tsa-crt.pem' ;
# Change values above as required

my $tmp_infile = 'temp.tsq' ;
my $tmp_outfile = 'temp.tsr' ;

my $daemon = HTTP::Daemon->new(LocalPort => $port) || die;

print 'Timestamp server running at URL ' . $daemon->url . "\n";

while (my $conn = $daemon->accept) {
  while (my $req = $conn->get_request) {
    if ($req->method eq 'POST') {
      # Write binary TimeStampReq from incoming HTTP POST request
      # to a temporary file
      open REQ, '>'.$tmp_infile ;
      binmode REQ ;
      print REQ $req->content ;
      close REQ ;
      
      # Generate TimeStampResp from TimeStampReq by invoking openssl
      unlink $tmp_outfile if -e $tmp_outfile ;
      system ('openssl', 'ts', '-reply', '-config', $tsa_cnf_file,
        '-section', $tsa_section, '-queryfile', $tmp_infile,
        '-inkey', $tsa_key_file, '-signer', $tsa_crt_file,
        '-out', $tmp_outfile) ;
      
      # If a file was generated by the previous command, then send it back to
      # the client...
      if (-e $tmp_outfile) {
        $conn->send_status_line ;
        $conn->send_header('Content-Type', 'application/timestamp-reply') ;
        $conn->send_header('Content-Length', -s $tmp_outfile) ;
        $conn->send_crlf ;
        $conn->send_file($tmp_outfile) ;
        $conn->close ;
      }
      # ... otherwise send an HTTP error
      else {
          $conn->send_error() ;
      }
    }
    else {
        $conn->send_error()
    }
  }
  $conn->close;
  undef($conn);
}