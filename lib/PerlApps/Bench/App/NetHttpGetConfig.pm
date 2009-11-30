package PerlApps::Bench::App::NetHttpGetConfig;

use strict;
use warnings;

sub times {
    return 1;
}

sub name {
    return "net_http_get_config";
}

sub run_benchmark {
    my ($class, $perl_info) = @_;

    my $script = "data/req_time_remote_munin";
    my $pid = open(my $fh, '-|', $perl_info->{perlbin}, $script, "config");
    waitpid $pid, 0 or die;
    return;
}

1;
