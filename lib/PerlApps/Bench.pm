package PerlApps::Bench;

use strict;
use warnings;

use Scriptalicious;
use List::Util qw[shuffle max];
use Cwd qw[cwd];
use Time::HiRes qw|tv_interval gettimeofday|;
use File::Spec ();
use Perl6::Form;
use POSIX;

my @tests = qw(PerlCritic);

sub tests {
    return map { "PerlApps::Bench::App::$_" } @tests;
}

our $new_name = "A";

sub extract_perl_setup {
    my ($perlbin) = @_;
    my ($volume, $path, $filename) = File::Spec->splitpath($perlbin);
    my $binpath = File::Spec->catpath($volume, $path);
    return { binpath => $binpath, perlbin => $perlbin, name => $new_name++ };
}

sub run_benchmark {
    my %options = @_;

    my $times = $options{'times'};
    my @tests = $options{'benchmarks'};
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
            my $variance_variance = ($item->{sum_sq_sq} / $item->{count}) - ($average**2)**2;
            my $uncertainty_variance = sqrt($variance_variance / ($item->{count}-1));
            my $uncertainty = sqrt($variance / ($item->{count}-1));
            # warn "$item->{sum} - $item->{sum_sq} - $average - $variance - $uncertainty_variance - $uncertainty";
            %{$item} = ( average => $average,
                         uncertainty => $uncertainty,
                         uncertain => ($uncertainty_variance > $variance),
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
            POSIX::floor( log($_->{average})/log(10.0) )
          } values %{$bench_res};

        $report .= "$benchname\n";

        my @res;
        for my $perl (sort keys %{$bench_res}) {
            my $r = $bench_res->{$perl};

            my $b_avg = $r->{average} / 10.0**$base;

            my $acc = - POSIX::floor(log( $r->{uncertainty} / ($r->{average}) )/log(10.0));

            $report .= "  $perl: ";
            if ($r->{uncertain}) {
                $report .= "*uncertain* ";
            }
            $report .= sprintf "%.${acc}f(%d)*10^%d\n",
              $b_avg, floor(0.5 + $r->{uncertainty} / (10**($base-$acc))), $base;
        }
    }
    return $report;
}

1;
