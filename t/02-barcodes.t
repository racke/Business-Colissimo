#!perl -T

use strict;
use warnings;

use Test::More;
use Business::Colissimo;

plan tests => 4;

my ($colissimo, $tracking, $sorting, $len);

$colissimo = Business::Colissimo->new(mode => 'access',
    parcel_number => '0123456789',
    postal_code => '72240',
    customer_number => '900001',
    weight => 12340,
);

# check length of tracking barcode
$tracking = $colissimo->barcode('tracking');

$len = length($tracking);

ok($len == 13, 'tracking barcode length test')
    || diag "length $len instead of 13: $tracking";
    
ok($tracking eq '8L01234567895', 'tracking barcode number test')
    || diag "barcode $tracking instead of 8L01234567895";

# check length of sorting barcode
$sorting = $colissimo->barcode('sorting');

$len = length($sorting);

ok($len == 24, 'sorting barcode test')
    || diag "length $len instead of 24: $sorting";

ok($sorting eq '8L1722409000011234000097', 'shipping barcode number test')
    || diag "barcode $sorting instead of 8L1722409000011234000097";
