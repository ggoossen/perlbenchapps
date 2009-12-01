package PerlBenchApps::AppController::Lcov;

use strict;
use warnings;

use File::Temp qw(tempfile);

sub times {
    return 10;
}

sub name {
    return "lcov";
}

sub run_benchmark {
    my ($class, $perl_info) = @_;

    my ($tmp_fh, $tmp_filename) = tempfile( CLEANUP => 1 );
    my $res = `$perl_info->{perlbin} data/lcov --capture --directory data/lcov-perl -o $tmp_filename 2>/dev/null`;
    if ( -s $tmp_filename < 1258000 ) {
        die "Unexpected output file size (" . (-s $tmp_filename) . ") by $perl_info->{name}";
    }

    return;
}

1;
