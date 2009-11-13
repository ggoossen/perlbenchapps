#! perl

use strict;
use warnings;

{
    package TestBench;

    our @ISA = ();

    sub times { 100 };
    sub name { 'testbench' }
    sub run_benchmark { 
        my ($class, $perl_info) = @_;
        system("$perl_info->{perlbin} -e 1") == 0 or die "failed";
        return;
    }
}

package main;

use Test::More 'no_plan';

use Scriptalicious ();
$Scriptalicious::VERBOSE = -1;

use PerlApps::Bench;

*extract_perl_setup = \&PerlApps::Bench::extract_perl_setup;
*run_benchmark = \&PerlApps::Bench::run_benchmark;
*report_from_result = \&PerlApps::Bench::report_from_result;

my $perl_info = extract_perl_setup( $^X );
ok( -e $perl_info->{perlbin} );
ok( -d $perl_info->{binpath} );
ok( $perl_info->{name} );

my $perl_info_2 = extract_perl_setup( $^X );

my $result = run_benchmark( perl => [$perl_info],
                            times => 10,
                            benchmarks => 'TestBench',
                        );

ok( $result->{'testbench'} );
ok( $result->{'testbench'}{$perl_info->{name}} );
ok( $result->{'testbench'}{$perl_info->{name}}{average} );
ok( $result->{'testbench'}{$perl_info->{name}}{uncertainty} );

for (1..5) {
    my $result2 = run_benchmark( perl => [$perl_info, $perl_info_2],
                                 times => 10,
                                 benchmarks => 'TestBench',
                             );
    my $test_res_1 = $result2->{'testbench'}{$perl_info->{name}};
    my $test_res_2 = $result2->{'testbench'}{$perl_info_2->{name}};
    my $diff = $test_res_1->{average} - $test_res_2->{average};

    ok(abs($diff) < 6*(sqrt($test_res_1->{uncertainty}**2 + $test_res_2->{uncertainty}**2)),
       "difference of average is within tolerance of unertainties") or
         diag("$diff - $test_res_1->{average} - $test_res_2->{average} - $test_res_1->{uncertainty} - $test_res_2->{uncertainty}");
}

$result = {
          'testbench' => {
                           'A' => {
                                    'uncertainty' => '9.14298000499047e-06',
                                    'average' => '0.002437851'
                                  },
                           'B' => {
                                    'uncertainty' => '1.50229353599443e-05',
                                    'average' => '0.025072162'
                                  },
                         }
        };

my $report = report_from_result( $result );
is($report, <<'EXPECT');
testbench
  A: 0.244(1)*10^-2
  B: 2.5072(15)*10^-2
EXPECT
