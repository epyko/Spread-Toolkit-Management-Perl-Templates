#!/usr/bin/perl
use Event;
use Spread;
use Spread::Messaging::Content;
use Time::Local 'timelocal_nocheck';
use Spread::Messaging::Exception;
do"../../conf/receivers/receiver.sample.conf";
require"../../scripts/receivers/custom.sample.pm";
sub put_output {
        $spread->recv();
        $message = (ref($spread->message) eq "ARRAY" ? join(','< @{$spread->message}) : $spread->message);
        &custom::test($message);
}
eval{
        $spread = Spread::Messaging::Content->new();
        $spread->join_group("$group");
        Event->io(fd => $spread->fd, cb => \&put_output);
        Event::loop();
};if (my $ex = $@) {
        my $ref = ref($ex);
        if ($ref && $ex->isa('Spread::Messaging::Exception')) {
                $ex->errno;
                printf("Error: %s cased by: %s\n", $ex->errno, $ex->errstr);
        } else {
                warn $@;
        }
}
