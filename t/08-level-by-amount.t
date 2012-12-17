#! perl
#
# Tests for level_by_amount method

use strict;
use warnings;

use Test::More;
use Business::Colissimo;

my @tests = ([{mode => 'expert_f'}, [0.01], '01'],
             [{mode => 'expert_f'}, [1], '01'],
             [{mode => 'expert_f'}, [150], '01'],
             [{mode => 'expert_f'}, [200], '02'],
             [{mode => 'expert_f'}, [300], '02'],
             [{mode => 'expert_f'}, [1350], '09'],
             [{mode => 'expert_f'}, [1350.01], '10'],
             [{mode => 'expert_f'}, [2000], '10'],
             [{mode => 'expert_f'}, [20, 1], '21'],
             [{mode => 'expert_f'}, [31, 1], '21'],
             [{mode => 'expert_f'}, [31.01, 1], '22'],
             [{mode => 'expert_f'}, [50, 1], '22'],
             [{mode => 'expert_f'}, [50.01, 1], '22'],
             [{mode => 'expert_f'}, [153, 1], '22'],
             [{mode => 'expert_f'}, [153.01, 1], '23'],
             [{mode => 'expert_f'}, [300, 1], '23'],
             [{mode => 'expert_f'}, [458, 1], '23'],
             [{mode => 'expert_f'}, [458.01, 1], '04'],
             [{mode => 'expert_f'}, [500, 1], '04'],
             [{mode => 'expert_i'}, [20, 1], '01'],
            );

plan tests => 2 * scalar(@tests);

for (@tests) {
    my ($test_parms, $level_parms, $expected) = @$_;
    my ($colissimo, $level, $ret);

    $colissimo = Business::Colissimo->new(%$test_parms);

    $ret = $colissimo->level_by_amount(@$level_parms);

    ok ($ret eq $expected,
        "Testing level_by_amount with $level_parms->[0]")
        || diag "Unexpected result: $ret instead of $expected.";

    $level = $ret;

    $ret = $colissimo->level($level);

    ok ($ret eq $level,
        "Testing level with $level")
        || diag "Unexpected result: $ret instead of $level.";
}
