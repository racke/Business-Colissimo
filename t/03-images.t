#!perl -T

use strict;
use warnings;

use Test::More;
use Business::Colissimo;

eval "use Image::Size";

if ($@) {
    plan skip_all => "Missing Image::Size module.";
}

plan tests => 6;

my ($colissimo, $tracking, $sorting, @info);

$colissimo = Business::Colissimo->new(mode => 'access',
    parcel_number => '0123456789',
    postal_code => '72240',
    customer_number => '900001',
    weight => 12340,
);

# check size and format of tracking barcode image
$tracking = $colissimo->barcode_image('tracking');

@info = imgsize(\$tracking);

ok ($info[0] > 1, 'tracking barcode image width');
ok ($info[1] > 1, 'tracking barcode image height');
ok ($info[2] eq 'PNG', 'tracking barcode image format'); 

# check size and format of sorting barcode
$sorting = $colissimo->barcode_image('sorting');

@info = imgsize(\$sorting);

ok ($info[0] > 1, 'sorting barcode image width');
ok ($info[1] > 1, 'sorting barcode image height');
ok ($info[2] eq 'PNG', 'sorting barcode image format'); 

