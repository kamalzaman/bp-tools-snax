use strict;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);

# Modified for SNAX by Michael Smith (anarcist)
# Original Author: Eugene Luzgin @ EOS Tribe

# Change values:
my $node_dir = "/opt/snax/data/snaxnode";
my $producer = 'anarcist';
my $email_from = '<YOUR EMAIL ADDRESS>';
my $email_to= '<YOUR EMAIL ADDRESS>';

open LOG, "<$node_dir/bp_position.last";
my $last_position = <LOG>;
chomp $last_position;
close LOG;

my @REGDATA = `$node_dir/clisnax.sh system listproducers`;
my $bp_position = "50+";
my $counter = 0;
foreach my $regbp (@REGDATA) {
   if($regbp=~m/^(\w+)\s+(SNAX\w+)\s/) {
      $counter++;
      if($1 eq $producer) { $bp_position = $counter };	
   }
}

if($bp_position != $last_position) {
   my $message = Email::MIME->create(
      header_str => [
         From    => $email_from,
         To      => $email_to,
         Subject => 'SNAX Producer Position #'.$bp_position,
      ],
      attributes => {
         encoding => 'quoted-printable',
         charset  => 'ISO-8859-1',
      },
      body_str => "$producer moved #".$last_position." -> #".$bp_position,
   );

   sendmail($message);

	open LOG, ">$node_dir/bp_position.last";
	print LOG $bp_position;
	close LOG;

	print "Sent Email!";
}

