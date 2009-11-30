package PerlApps::Bench::App::LwpRequest;

use strict;
use warnings;

sub times {
    return 1;
}

sub name {
    return "lwp-request";
}

sub run_benchmark {
    my ($class, $perl_info) = @_;

    my $script = "data/req_time_remote_munin";
    my $pid = open(my $fh, '-|', $perl_info->{perlbin},
                   "$perl_info->{binpath}/lwp-request",
                   "http://www.perlfoundation.org/");
    waitpid $pid, 0 or die;
    return;
}

1;
