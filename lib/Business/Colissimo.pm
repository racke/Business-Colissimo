package Business::Colissimo;

use 5.006;
use strict;
use warnings;

use Barcode::Code128;

=head1 NAME

Business::Colissimo - Shipping labels for ColiPoste

=head1 VERSION

Version 0.0002

=cut

our $VERSION = '0.0002';

my %product_codes = (access_f => '8L', expert_f => '8V', expert_om => '7A');
my %attributes = (parcel_number => 'parcel number', 
		  postal_code => 'postal code', 
		  customer_number => 'customer number',
		  weight => 'parcel weight',
		  not_mechanisable => 'not mechanisable',

		  # expert mode
		  cod => 'cash on delivery',
		  level => 'insurance/recommendation level',
    );

my %logo_files = (access_f => 'AccessF',
		  expert_f => 'ExpertF',
		  expert_om => 'ExpertOM',
		  expert_i => 'ExpertInter',
    );

=head1 SYNOPSIS 

    use Business::Colissimo;

    $colissimo = Business::Colissimo->new(mode => 'access_f');

    # customer number
    $colissimo->customer_number('900001');

    # parcel number from your alloted range of numbers
    $colissimo->parcel_number('2052475203');

    # postal code for recipient
    $colissimo->postal_code('72240');

    # add weight in grams
    $colissimo->weight(250);

    # not mechanisable option
    $colissimo->not_mechanisable(1);
    
    # cash on delivery option (expert mode only)
    $colissimo->cod(1);

    # insurance level (expert mode only)
    $colissimo->level('01');

    # recommendation level (expert mode only)
    $colissimo->level('21');

=head1 DESCRIPTION

Business::Colissimo supports the following ColiPoste services:

=over 4

=item Access France
    
    $colissimo = Business::Colissimo->new(mode => 'access_f');

=item Expert France

    $colissimo = Business::Colissimo->new(mode => 'expert_f');

=item Expert Outre Mer

    $colissimo = Business::Colissimo->new(mode => 'expert_om');

=back

=head1 METHODS

=head2 new

    $colissimo = Business::Colissimo->new(mode => 'access_f',
         customer_number => '900001',
         parcel_number => '2052475203',
         postal_code => '72240',
         weight => 250);

    $colissimo = Business::Colissimo->new(mode => 'expert_f',
         customer_number => '900001',
         parcel_number => '2052475203',
         postal_code => '72240',
         weight => 250,
         cod => 1,
         level => '01');

=cut

sub new {
    my ($class, $self, %args);

    $class = shift;
    %args = @_;

    unless (defined $args{mode} && $product_codes{$args{mode}}) {
	die 'Please select valid mode for ', __PACKAGE__;
    }

    $self = {mode => delete $args{mode},
	     parcel_number => '',
	     postal_code => '',
	     customer_code => '',
	     not_mechanisable => '0',

	     # expert 
	     cod => '0',
	     level => '00',
    };

    bless $self, $class;

    for my $name (keys %args) {
	if (exists $attributes{$name}) {
	    $self->$name($args{$name});
	}
    }

    return $self;
}

=head2 barcode

Produces the tracking barcode:

    $colissimo->barcode('tracking');

Same with proper spacing for the shipping label:

    $colissimo->barcode('tracking', spacing => 1);

Produces the sorting barcode:

    $colissimo->barcode('sorting');

Same with proper spacing for the shipping label:

    $colissimo->barcode('sorting', spacing => 1);

=cut

sub barcode {
    my ($self, $type, %args) = @_;
    my ($barcode, $parcel_number, $control);

    $barcode = $product_codes{$self->{mode}};

    unless (length($self->{parcel_number})) {
	die "Missing $attributes{parcel_number}";
    }
    
    if ($type eq 'sorting') {
	# check if we have everything we need
	for my $name (qw/postal_code parcel_number customer_number weight/) {
	    unless (length($self->{$name})) {
		die "Missing $attributes{$name}";
	    }
	}

	# fixed sort code
	$barcode .= '1';

	# recipient postal code
	$barcode .= $self->postal_code;

	# customer code
	$control = $self->customer_number;

	# parcel weight
	$control .= $self->weight;

	# insurance/recommendation level
	$control .= $self->level;

	# not mechanisable 
	$control .= $self->not_mechanisable;

	# cash on delivery
	$control .= $self->cod;

	# control link digit (last digit of parcel number)
	$control .= substr($self->parcel_number, 9, 1);
	
	$barcode .= $control . $self->control_key($control);

	if ($args{spacing}) {
	    return join(' ', substr($barcode, 0, 3),
			substr($barcode, 3, 5),
			substr($barcode, 8, 6),
			substr($barcode, 14, 4),
			substr($barcode, 18, 6));	   
	}
    }
    else {
	$parcel_number = $self->parcel_number;
	$barcode .= $parcel_number;
	$barcode .= $self->control_key($parcel_number);

	if ($args{spacing}) {
	    return join(' ', substr($barcode, 0, 2),
			substr($barcode, 2, 5),
			substr($barcode, 7, 5),
			substr($barcode, 12, 1));
	}
    }

    return $barcode;
}

=head2 barcode_image

Produces PNG image for tracking barcode:

    $colissimo->barcode_image('tracking');

Produces PNG image for sorting barcode:

    $colissimo->barcode_image('sorting');

Produces PNG image for arbitrary barcode:

    $colissimo->barcode_image('8L20524752032');

=cut

sub barcode_image {
    my ($self, $type, %args) = @_;
    my ($barcode, $image, $code128, $png);

    if ($type eq 'tracking' || $type eq 'sorting') {
	$barcode = $self->barcode($type);
    }
    else {
	$barcode = $type;
    }

    $code128 = Barcode::Code128->new;
    $code128->show_text(0);

    $png = $code128->png($barcode);
}

=head2 customer_number

Get current customer number:

    $colissimo->customer_number;

Set current customer number:

    $colissimo->customer_number('900001');

=cut

sub customer_number {
    my $self = shift;
    my $number;

    if (@_ > 0 && defined $_[0]) {
	$number = $_[0];
	
        $number =~ s/\s+//g;

	if ($number !~ /^\d{6}$/) {
	    die 'Please provide valid customer number (6 digits) for barcode';
	}

	$self->{customer_number} = $number;
    }    

    return $self->{customer_number};
}

=head2 parcel_number

Get current parcel number:

    $colissimo->parcel_number;
    
Set current parcel number:

    $colissimo->parcel_number('2052475203');

=cut

sub parcel_number {
    my $self = shift;
    my $number;

    if (@_ > 0 && defined $_[0]) {
	$number = $_[0];
	
        $number =~ s/\s+//g;

	if ($number !~ /^\d{10}$/) {
	    die 'Please provide valid parcel number (10 digits) for barcode';
	}

	$self->{parcel_number} = $number;
    }

    return $self->{parcel_number};
}

=head2 postal_code

Get current postal code:

    $colissimo->postal_code

Set current postal code:

    $colissimo->postal_code('72240');

=cut

sub postal_code {
    my $self = shift;
    my $string; 

    if (@_ > 0 && defined $_[0]) {
	$string = $_[0];
	
        $string =~ s/\s+//g;

	if ($string !~ /^[A-Z0-9]{5}/) {
	    die 'Please provide valid postal code (5 alphanumerics) for barcode';
	}

	$self->{postal_code} = $string;
    }

    return $self->{postal_code};
}

=head2 weight

Get current weight:

   $colissimo->weight;

Set weight in grams:

   $colissimo->weight(250);

=cut

sub weight {
    my $self = shift;
    my $number;

    if (@_ > 0 && defined $_[0]) {
	$number = $_[0];
	
        $number =~ s/\s+//g;

	if ($number !~ /^\d{1,5}$/) {
	    die 'Please provide valid parcel weight (less than 100 kg) for barcode';
	}

	$self->{weight} = sprintf('%04d', int($number / 10));
    }

    return $self->{weight};
}

=head2 not_mechanisable

Get current value of not mechanisable option:

    $colissimo->not_mechanisable;

Set current value of not mechanisable option:

    $colissimo->not_mechanisable(1);

Possible values are 0 (No) and 1 (Yes).

=cut

sub not_mechanisable {
    my $self = shift;
    my $number;

    if (@_ > 0 && defined $_[0]) {
	$number = $_[0];
	
        $number =~ s/\s+//g;

	if ($number !~ /^[01]$/) {
	    die 'Please provide valid value for not mechanisable (0 or 1)';
	}

	$self->{not_mechanisable} = $number;
    }

    return $self->{not_mechanisable};
}

=head2 cod

Get current value of cash on delivery option:

    $colissimo->cod;

Set current value of cash on delivery option:

    $colissimo->cod(1);

The cash on delivery option is available only in export mode,
possible values are 0 (No) and 1 (Yes).

=cut

sub cod {
    my $self = shift;
    my $number;

    if (@_ > 0 && defined $_[0]) {
	$number = $_[0];
	
        $number =~ s/\s+//g;

	if ($number !~ /^[01]$/) {
	    die 'Please provide valid value for cash on delivery option (0 or 1)';
	}

	if ($self->{mode} eq 'access' 
	    && $number eq '1') {
	    die 'Cash on delivery option not available in access mode.';
	}

	$self->{cod} = $number;
    }

    return $self->{cod};
}

=head2 level

Get current insurance resp. recommendation level:

    $colissimo->level;

Set current insurance resp. recommendation level:

    $colissimo->level('O1');
    $colissimo->level('21');

The level option is only available in expert mode, 
possible values are 01 ... 10 for insurance level
and 21 ... 23 for recommendation level.

=cut

sub level {
    my $self = shift;
    my $number;

   if (@_ > 0 && defined $_[0]) {
	$number = $_[0];
	
        $number =~ s/\s+//g;

	if ($number !~ /^([0\d]|10|2[123])$/ ) {
	    die 'Please provide valid value for insurance/recommendation level.';
	}

	if ($self->{mode} eq 'access' 
	    && $number ne '00') {
	    die 'Insurance/recommendation level not available in access mode.';
	}

	$self->{level} = $number;
    }

    return $self->{level};
}
    
=head2 control_key

Returns control key for barcode.

=cut

sub control_key {
    my ($self, $characters) = @_;
    my (@codes, $even, $odd, $key, $mod);

    @codes = split(//, $characters);
    
    if (@codes % 2) {
	# pad characters for sorting control key
	unshift (@codes, '0');
    }

    while (@codes) {
	$odd += shift(@codes);
	$even += shift(@codes);
    }

    $key = (3 * $even) + $odd;
    $mod = $key % 10;

    return $mod ? 10 - $mod : 0;
}

=head2 logo

Returns logo file name for selected service.

=cut

sub logo {
    my $self = shift;

    return $logo_files{$self->{mode}} . '.bmp';
}

=head1 AUTHOR

Stefan Hornburg (Racke), C<< <racke at linuxia.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-business-colissimo at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Business-Colissimo>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Business::Colissimo


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-Colissimo>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Business-Colissimo>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Business-Colissimo>

=item * Search CPAN

L<http://search.cpan.org/dist/Business-Colissimo/>

=back


=head1 ACKNOWLEDGEMENTS

Thanks to Ton Verhagen for being a big supporter of my projects in all aspects.

=head1 LICENSE AND COPYRIGHT

Copyright 2011-2012 Stefan Hornburg (Racke).

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Business::Colissimo
