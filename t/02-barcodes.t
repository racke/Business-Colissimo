#!perl -T

use strict;
use warnings;

use Test::More;
use Business::Colissimo;



my ($colissimo, $tracking, $sorting, $tracking_expected, $sorting_expected,
    $len, %mode_values, $mode, $value_ref, $country, $international);

%mode_values = (access_f => {product_code => '8L', international => 0},
                expert_f => {product_code => '8V', international => 0}, 
                expert_om => {product_code => '7A', international => 0},
                expert_i => {product_code => 'CY', international => 1},
                expert_i_kpg => {product_code => 'EY', international => 1},
    );

plan tests => 9 * keys %mode_values;

while (($mode, $value_ref) = each %mode_values) {
    $country = 'BE';
    
    $colissimo = Business::Colissimo->new(mode => $mode);

    # test whether international is set correctly
    $international = $colissimo->international;

    ok($international == $mode_values{$mode}->{international}, 'international test')
        || diag "wrong value for international: $international";

    if ($international) {
        $colissimo->parcel_number('01234567');
        $colissimo->postal_code('1234');
        $colissimo->country_code($country);
    }
    else {
        $colissimo->parcel_number('0123456789');
        $colissimo->postal_code('72240');
    }

    $colissimo->customer_number('900001');
    $colissimo->weight(12340);

    # check tracking barcode
    $tracking = $colissimo->barcode('tracking');

    $len = length($tracking);

    ok($len == 13, 'tracking barcode length test')
        || diag "length for mode $mode is $len instead of 13: $tracking";

    if ($international) {
        $tracking_expected = $value_ref->{product_code} . '012345670FR';
    }
    else {
        $tracking_expected = $value_ref->{product_code} . '01234567895';
    }
    
    ok($tracking eq $tracking_expected, 'tracking barcode number test')
	|| diag "barcode $tracking instead of $tracking_expected";

    # check tracking barcode with spacing
    $tracking = $colissimo->barcode('tracking', spacing => 1);

    $len = length($tracking);

    ok($len == 16, 'tracking barcode length with spacing test')
	|| diag "length $len instead of 16: $tracking";

    if ($international) {
        $tracking_expected = $value_ref->{product_code} . ' 0123 4567 0FR';
    }
    else {
        $tracking_expected = $value_ref->{product_code} . ' 01234 56789 5';
    }
    
    ok($tracking eq $tracking_expected, 'tracking barcode number with spacing test')
	|| diag "barcode $tracking instead of $tracking_expected";

    # check sorting barcode
    $sorting = $colissimo->barcode('sorting');

    $len = length($sorting);

    ok($len == 24, 'sorting barcode test')
	|| diag "length $len instead of 24: $sorting";

    if ($international) {
        $sorting_expected = $value_ref->{product_code} . '2BE1239000011234000073';
    }
    else {
        $sorting_expected = $value_ref->{product_code} . '1722409000011234000097';
    }
    
    ok($sorting eq $sorting_expected, 'shipping barcode number test')
	|| diag "barcode $sorting instead of $sorting_expected";

    # check sorting barcode with spacing
    $sorting = $colissimo->barcode('sorting', spacing => 1);

    $len = length($sorting);

    ok($len == 28, 'sorting barcode number test with spacing')
	|| diag "length $len instead of 24: $sorting";

    if ($international) {
        $sorting_expected = $value_ref->{product_code} . '2 BE123 900001 1234 000073';
    }
    else {
        $sorting_expected = $value_ref->{product_code} . '1 72240 900001 1234 000097';
    }
    
    ok($sorting eq $sorting_expected, 'shipping barcode number test')
	|| diag "barcode $sorting instead of $sorting_expected";
}
