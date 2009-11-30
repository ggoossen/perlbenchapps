package PerlApps::Bench::App::PerlCritic;

use strict;
use warnings;

sub times {
    return 1;
}

sub name {
    return "perlcritic";
}

sub run_benchmark {
    my ($class, $perl_info) = @_;

    my $file = "data/perlcritic/exception.pm";
    my $x = `$perl_info->{perlbin} $perl_info->{binpath}/perlcritic $file 2>&1`;
    $x eq <<OUTPUT or die "unexpected output by '$perl_info->{name}':\n$x";
Package declaration must match filename at line 1, column 1.  Correct the filename or package statement.  (Severity: 5)
OUTPUT
    return;
}

1;
