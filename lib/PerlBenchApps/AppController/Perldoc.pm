package PerlBenchApps::AppController::Perldoc;

use strict;
use warnings;

sub times {
    return 10;
}

sub name {
    return "perldoc";
}

sub run_benchmark {
    my ($class, $perl_info) = @_;

    local $ENV{PERLDOC_POD2} = "";
    my $perldoc = "$perl_info->{binpath}/perldoc$perl_info->{version}";
    $perldoc = "$perl_info->{binpath}/perldoc" if not -e $perldoc;
    my $res = `$perl_info->{perlbin} $perldoc -onroff data/perlfunc.pod`;
    my $lines = $res =~ tr/\n//c;
    if ( $lines < 340000 ) {
        die "Unexpected output lines: $lines by $perl_info->{name}";
    }
    return;
}

1;
