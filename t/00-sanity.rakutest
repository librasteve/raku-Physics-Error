use lib '../lib';
use Test;

use Physics::Error;

plan 6;

# Physics::Error is intended as a dependency of Physics::Measure
# Most test is done by Physics::Measure ./t/14-err.t
# This test is just the absolute basics

my $error = 10;
my $value = 100;
my $x = Error.new( :$error, :$value );
$x.bind-mea-value( $value );

is $x.^name, 'Physics::Error::Error',               '.^name';
is ~$x, '10',                                       '.Str';
ok $x.absolute == 10,                               '.absolute';
ok $x.relative == 0.1,                              '.relative';
is $x.relative.^name, 'Rat',                        '.percent.^name';
is $x.percent, '10%',                               '.percent';

# done-testing;
