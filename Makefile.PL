#! perl

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile (
    NAME            => 'PerlBenchApps',
    VERSION_FROM    => 'lib/PerlBenchApps/Controller.pm',
    PREREQ_PM       => {
        'Scriptalicious'            => 0,
    },
    AUTHOR          => 'Gerard Goossen <gerard[at]ggoossen.net>',
    ABSTRACT        => 'Compare relative performances of different revisions of perl',
);
