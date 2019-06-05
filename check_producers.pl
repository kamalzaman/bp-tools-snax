use strict;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);

# Modified for SNAX by Michael Smith (anarcist)
# Original Author: Eugene Luzgin @ EOS Tribe

my $main_node_url = "https://cdn.snax.one/v1/chain/get_info"; # This should be a "trustworthy" node
my $compare_node_url = "https://snax-node.anarcist.xyz/v1/chain/get_info"; # This is your node

my $email_from = '<YOUR EMAIL ADDRESS>';
my $email_to= '<YOUR EMAIL ADDRESS>';

my $prod1_stats = `curl -s --connect-timeout 2 $main_node_url`;
print "Main Producer: ".$prod1_stats."\n";
my $prod2_stats = `curl -s --connect-timeout 2 $compare_node_url`;
print "Compare Producer: ".$prod2_stats."\n";
my $message_body = "";

if($prod1_stats=~m/"head_block_num":(\d+)/) {
	my $prod1_head_block = $1;
	print "Main Producer Head Block: ".$prod1_head_block."\n";
	if($prod2_stats=~m/"head_block_num":(\d+)/) {
		my $prod2_head_block = $1;
		print "Compare Producer Head Block: ".$prod2_head_block."\n";
		my $block_diff = $prod1_head_block - $prod2_head_block;
		print "Block diff: $block_diff\n";
		if($block_diff < -10) {
			$message_body = "Main producer $block_diff blocks behind Compare producer!";
		} elsif($block_diff > 10) {
			$message_body = "Compare producer $block_diff blocks behind Main producer!";
		}
	} else {
		$message_body = "Compare producer timeout!";
	}
} else {
	$message_body = "Main producer timeout!";
}

if (not $message_body eq "") {
	my $message = Email::MIME->create(
		header_str => [
			From    => $email_from,
			To      => $email_to,
			Subject => $message_body,
		],
		attributes => {
			encoding => 'quoted-printable',
			charset  => 'ISO-8859-1',
		},
		body_str => $message_body
	);

	sendmail($message);
}
