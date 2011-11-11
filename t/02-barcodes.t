#!perl -T

use strict;
use warnings;

use Test::More;
use Business::Colissimo;

plan tests => 2;

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

ok($len == 13, 'tracking barcode test')
    || diag "length $len instead of 13: $tracking";
    
# check length of sorting barcode
$sorting = $colissimo->barcode('sorting');

$len = length($sorting);

ok($len == 24, 'sorting barcode test')
    || diag "length $len instead of 24: $sorting";
