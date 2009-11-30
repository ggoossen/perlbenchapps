package PerlApps::Bench::App::NetHttpGet;

use strict;
use warnings;

sub times {
    return 1;
}

sub name {
    return "net_http_get";
}

sub run_benchmark {
    my ($class, $perl_info) = @_;

    my $script = "data/req_time_remote_munin";
    my $pid = open(my $fh, '-|', $perl_info->{perlbin}, $script);
    waitpid $pid, 0 or die;
    return;
}

1;
