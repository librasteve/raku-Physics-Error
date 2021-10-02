#!/usr/bin/env raku
use Physics::Measure :ALL;

# Physics::Error supports the three methods for making Measure objects with value, units & error

my $x1 = 12.5nm ± 1;                                                    #SI units as raku postfix operators
my $x2 = Length.new(value => 12.5, units => 'nm', error => '4.3%');     #standard .new syntax
my $x3 = ♎️ '12.5 ft ±0.5';                                             #libra prefix shortcut

my $x0 = 12.5nm;                                #or just omit the Error part to get a regular Measure

# Error values can be accessed via the .error object
say ~$x1;                                       #12.5nm ±4% or 12.5nm ±1.00e+00
say $x1.error.absolute;                         #1
say $x1.error.relative;                         #0.08
say $x1.error.relative.^name;                   #Rat
say $x1.error.percent;                          #8%

# Unit conversions and normalization
my $y = Length.new(value => 12.5e2, units => 'nm', error => '4.3%');
say ~$y.in('mm');                               #0.00125mm ±5.37e-05
say ~$y.norm;                                   #1.25μm ±5.37e-02


my $t = Time.new(value => 10, units => 'ms', error => 0.2);
say ~( 17 / $t );                               #1700Hz ±3.40e-01

# Measure math adjusts units and error automagically
say ~( $y / $t );                               #0.000125m/s ±7.87e-06

# works with add, subtract, multiply, divide, power and root
# add & subtract add absolute error
# multiply & divide add relative error
# power and root multiply relative error by power

my Length $w = Length.new(value => 10, units => 'm', error => '2%');
my $z = $w ** 3;                                #1000m^3 ±6.00e+01
$z = $z ** <1/3>;                               #10m ±2.00e-01

# As do Measure cmp operators (to within error limits)
say $w cmp $y;                                  #More

# Some global settings help to control Error output precision and rounding (here with default values)
$Physics::Error::default   = 'absolute';    #default error output [absolute|percent]
$Physics::Error::round-per = 0.001;         #control rounding of percent

# Use these with the global setting for Measure value output rounding (default is 14 decimal places)
# Here we choose to suppress all Measure value rounding due to the very small value of Em

#$Physics::Measure::round-val = Nil;

# Here's the mass of the electron Em in action...
my \Em = 9.109_383_701_5e-31kg   \
        ±0.000_000_002_8e-31;

say ~Em;                                        #9.1093837015e-31kg ±2.80e-40
say Em.error.absolute;                          #2.8e-40
say Em.error.relative;                          #3.0737534961217373e-10
say Em.error.relative.^name;                    #Num
say Em.error.percent;                           #0%

#EOF








