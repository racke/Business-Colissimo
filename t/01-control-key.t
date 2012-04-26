#!perl -T

use strict;
use warnings;

use Test::More;
use Business::Colissimo;

my ($colissimo, $name, $value, $control_key, $tests);

my %control_keys = (access_f => { 
                        # control keys for tracking
                        2052475203 => 2,
                        4139207826 => 0,
                        4139212825 => 5,
                        # control keys for sorting
                        900001086000003 => 7,
                    },
                    expert_i => {
                        # control keys for tracking
                        2456198 => 3,
                        # control keys for sorting
                        900001086000003 => 7,
                    },
    );

$tests = 0;

for my $mode (keys %control_keys) {
    $tests += scalar keys %{$control_keys{$mode}};
}

plan tests => $tests;

for my $mode (keys %control_keys) {
    $colissimo = Business::Colissimo->new(mode => $mode);

    while (($name, $value) = each %{$control_keys{$mode}}) {
        $control_key = $colissimo->control_key($name);

        ok ($control_key == $value, "Test control key for mode $mode and $name.")
            || diag ("Mode $mode, Control $name, expected: $value, got: $control_key");
    }
}

