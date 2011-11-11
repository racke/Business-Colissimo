#!perl -T

use strict;
use warnings;

use Test::More;
use Business::Colissimo;

my ($colissimo, $name, $value, $control_key);

my %control_keys = (
    # control keys for tracking
    2052475203 => 2,
    4139207826 => 0,
    4139212825 => 5,
    # control keys for sorting
    900001086000003 => 7,
    );

plan tests => scalar keys %control_keys;

$colissimo = Business::Colissimo->new(mode => 'access');

while (($name, $value) = each %control_keys) {
    $control_key = $colissimo->control_key($name);

    ok ($control_key == $value, "Control $name, expected: $value, got: $control_key");
}
