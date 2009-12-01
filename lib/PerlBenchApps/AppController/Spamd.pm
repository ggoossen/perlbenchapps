package PerlBenchApps::AppController::Spamd;

use strict;
use warnings;

sub times {
    return 1;
}

sub name {
    return "spamd";
}

sub run_benchmark {
    my ($class, $perl_info) = @_;

    my @args = ('-L', '-x', '-p' => 3173, );
    open my $olderr, '>&', STDERR;
    close STDERR;
    my $pid = open(my $fh, '-|', "$perl_info->{binpath}/spamd", @args);
    sleep 2; # wait for spamd to start.
    open STDERR, '>&', $olderr;
    my $x;
    my $file = "data/spamassassin/spam_2/00409.1faf0d6f87e8b70f0bb05b9040d56fca";
    $x = `$perl_info->{binpath}/spamc -l -y -p 3173 < $file 2>&1`;
    $x =~ m/^(AWL,)?DATE_IN_PAST_03_06,HTML_IMAGE_RATIO_06,HTML_MESSAGE,INVALID_DATE,MIME_HTML_ONLY,NORMAL_HTTP_TO_IP,RDNS_NONE,SUBJ_ALL_CAPS,URI_HEX$/
      or die "invalid repsonse by ($perl_info->{name}). got: '$x'";

    for my $file (glob("data/spamassassin/spam_2/004*")) {
        $x = `$perl_info->{binpath}/spamc -y -p 3173 < $file 2>&1`;
    }
    kill 9, $pid;
    waitpid $pid, 0 or die;
    sleep 2;
    return;
}

1;
