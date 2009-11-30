package PerlApps::Bench::App::Perldoc;

use strict;
use warnings;

sub times {
    return 1;
}

sub name {
    return "perldoc";
}

sub run_benchmark {
    my ($class, $perl_info) = @_;

    my $res = `$perl_info->{perlbin} $perl_info->{binpath}/perldoc$perl_info->{version} -onroff data/perlfunc.pod`;
    my $lines = $res =~ tr/\n//c;
    if ( $lines < 340000 ) {
        die "Unexpected output lines: $lines";
    }
    return;
}

1;
