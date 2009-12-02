package PerlBenchApps::Controller;

use strict;
use warnings;

use Scriptalicious;
use List::Util qw[shuffle max];
use Cwd qw[cwd];
use Time::HiRes qw|tv_interval gettimeofday|;
use File::Spec ();
use POSIX qw(floor);

use version; our $VERSION = qv("v0.1");

my @tests = qw(PerlCritic Lcov LwpRequest NetHttpGet NetHttpGetConfig Perldoc Spamassassin Spamd);

sub tests {
    return map { "PerlBenchApps::AppController::$_" } @tests;
}

our $new_name = "A";

sub extract_perl_setup {
    my ($perlbin) = @_;
    my ($volume, $path, $filename) = File::Spec->splitpath($perlbin);
    my $binpath = File::Spec->catpath($volume, $path);
    open(my $fh, '-|', $perlbin, '-e', q[use Config %Config; print $Config{version}]) or die;
    my $version = <$fh>;
    close $fh or die;
    return { binpath => $binpath, perlbin => $perlbin, name => $new_name++, version => $version };
}

sub run_benchmark {
    my %options = @_;

    my $times = $options{'times'};
    my @tests = @{ $options{'benchmarks'} };
    my @perls = @{ $options{perl} };
    my $rootdir = cwd();
    my $res = {};

    for my $i (0..$times) {
        print "." if $VERBOSE >= 0;
        for my $testclass (shuffle @tests) {
            for (1..$testclass->times) {
                for my $perl (shuffle @perls) {

                    chdir($rootdir) or die "failed chdir";

                    my $t0 = [gettimeofday];
                    $testclass->run_benchmark($perl);
                    my $diff = tv_interval($t0, [gettimeofday]);

                    next if $i == 0;

                    my $item = $res->{$testclass->name}{$perl->{name}}
                      ||= {
                          sum => 0.0,
                          sum_sq => 0.0,
                          count => 0,
                      };
                    $item->{sum} += $diff;
                    $item->{sum_sq} += $diff**2;
                    $item->{sum_sq_sq} += ($diff**2)**2;
                    $item->{count}++;
                }
            }
        }
    }
    print "\n" if $VERBOSE >= 0;

    for my $testclass (shuffle @tests) {
        for my $perl (@perls) {
            my $item = $res->{$testclass->name}{$perl->{name}};
            my $average = $item->{sum} / $item->{count};
            my $variance = ($item->{sum_sq} / ($item->{count}-1))
              - ($item->{count}/($item->{count}-1)) * $average**2;
            my $uncertainty = sqrt($variance / ($item->{count}-1));
            %{$item} = ( average => $average,
                         uncertainty => $uncertainty,
                     );
        }
    }

    return $res;
}

sub report_from_result {
    my ($result) = @_;
    my $report;
    for my $benchname (sort keys %{$result}) {

        my $bench_res = $result->{$benchname};

        my $base = max map {
            floor( log($_->{average})/log(10.0) )
          } values %{$bench_res};

        $report .= "$benchname\n";

        my @res;
        for my $perl (sort keys %{$bench_res}) {
            my $r = $bench_res->{$perl};

            my $b_avg = $r->{average} / 10.0**$base;

            my $acc = - floor(log( $r->{uncertainty} / (2 * 10**$base) )/log(10.0));

            $report .= "  $perl: ";
            $report .= sprintf "%.${acc}f(%d)*10^%d\n",
              $b_avg, floor(0.5 + $r->{uncertainty} / (10**($base-$acc))), $base;
        }
    }
    return $report;
}

1;
