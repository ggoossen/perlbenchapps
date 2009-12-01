package PerlBenchApps::AppController::Spamassassin;

use strict;
use warnings;

sub times {
    return 10;
}

sub name {
    return "spamassassin";
}

sub run_benchmark {
    my ($class, $perl_info) = @_;

    my $perl = shift;
    my $file = "data/spamassassin/spam_2/00409.1faf0d6f87e8b70f0bb05b9040d56fca";
    my $x = `$perl_info->{perlbin} -T $perl_info->{binpath}/spamassassin -L < $file 2>&1`;

    return;
}

1;
