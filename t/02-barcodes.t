#!perl -T

use strict;
use warnings;

use Test::More;
use Business::Colissimo;



my ($colissimo, $tracking, $sorting, $tracking_expected, $sorting_expected,
    $len, %mode_values, $mode, $value_ref);

%mode_values = (access_f => {product_code => '8L'},
		expert_om => {product_code => '7A'},
    );

plan tests => 8 * keys %mode_values;

while (($mode, $value_ref) = each %mode_values) {
    $colissimo = Business::Colissimo->new(mode => $mode,
					  parcel_number => '0123456789',
					  postal_code => '72240',
					  customer_number => '900001',
					  weight => 12340,
	);

    # check tracking barcode
    $tracking = $colissimo->barcode('tracking');

    $len = length($tracking);

    ok($len == 13, 'tracking barcode length test')
	|| diag "length $len instead of 13: $tracking";

    $tracking_expected = $value_ref->{product_code} . '01234567895';
    
    ok($tracking eq $tracking_expected, 'tracking barcode number test')
	|| diag "barcode $tracking instead of $tracking_expected";

    # check tracking barcode with spacing
    $tracking = $colissimo->barcode('tracking', spacing => 1);

    $len = length($tracking);

    ok($len == 16, 'tracking barcode length with spacing test')
	|| diag "length $len instead of 16: $tracking";

    $tracking_expected = $value_ref->{product_code} . ' 01234 56789 5';

    ok($tracking eq $tracking_expected, 'tracking barcode number with spacing test')
	|| diag "barcode $tracking instead of $tracking_expected";

    # check sorting barcode
    $sorting = $colissimo->barcode('sorting');

    $len = length($sorting);

    ok($len == 24, 'sorting barcode test')
	|| diag "length $len instead of 24: $sorting";

    $sorting_expected = $value_ref->{product_code} . '1722409000011234000097';
    
    ok($sorting eq $sorting_expected, 'shipping barcode number test')
	|| diag "barcode $sorting instead of $sorting_expected";

    # check sorting barcode with spacing
    $sorting = $colissimo->barcode('sorting', spacing => 1);

    $len = length($sorting);

    ok($len == 28, 'sorting barcode number test with spacing')
	|| diag "length $len instead of 24: $sorting";

    $sorting_expected = $value_ref->{product_code} . '1 72240 900001 1234 000097';
    
    ok($sorting eq $sorting_expected, 'shipping barcode number test')
	|| diag "barcode $sorting instead of $sorting_expected";
}
