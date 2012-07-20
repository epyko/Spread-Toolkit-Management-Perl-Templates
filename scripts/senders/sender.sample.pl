#!/usr/bin/perl
use File::Tail;
use Spread::Messaging::Content;
use Spread;
use Spread::Messaging::Exception; 
do "../../conf/senders/sender.sample.conf";
sub main{
        eval{
                $spread = Spread::Messaging::Content->new( -port => "$port", -host => "$host", -private_name => "$private_name");
                my $outf;
                open( $outf, ">>$path") || die "$O: couldn't open $path";
                select($outf); $|=1; select(STDOUT);
                my $file=File::Tail->new(name=>$path, maxinterval=>1, interval=>1);
                while (defined(my $line=$file->read)) {
                                $spread->group("$group");
                                $spread->type("0");
                                $spread->message("$ip $line");
                                $spread->send();
                }
        };if (my $ex = $@) {
                my $ref = ref($ex);
                if ($ref && $ex->isa('Spread::Messaging::Exception')) {
                        $ex->errno;
                        printf("Error: %s cased by: %s\n", $ex->errno, $ex->errstr);
                } else {
                        warn $@;
                }
        }
}
&main;
