# raku-Physics-Error
some code to handle physical measurement errors (nothing to do with programming errors!)

[![Build Status](https://app.travis-ci.com/p6steve/raku-Physics-Error.svg?branch=main)](https://app.travis-ci.com/p6steve/raku-Physics-Error)

Take a look at your keyboard... there's probably a '±' key?

Physics::Error works with the [Physics::Measure](https://github.com/p6steve/raku-Physics-Measure) and [Physics::Unit](https://github.com/p6steve/raku-Physics-Unit) modules to do this:

```perl6
use Physics::Measure :ALL;

my $x1 = 12.5nm ± 1;                                                    #SI units as raku postfix operators
my $x2 = Length.new(value => 12.5, units => 'nm', error => '4.3%');     #standard raku .new syntax
my $x3 = ♎️ '12.5 ft ±0.5';                                              #libra prefix shorthand

# Error values are included in Measures when output
say ~$x1;                                       #12.5nm ±4% or 12.5nm ±1

# They can be accessed directly via the .error object
say $x1.error.absolute;                         #1
say $x1.error.relative;                         #0.08
say $x1.error.relative.^name;                   #Rat
say $x1.error.percent;                          #8%
```

All of the main Measure capabilities work as expected...

```perl6
# Unit conversions and normalization
my $y = Length.new(value => 12.5e2, units => 'nm', error => '4.3%');
say ~$y;                                        #1250nm ±53.75
say ~$y.in('mm');                               #0.00125mm ±0.0000538
say ~$y.norm;                                   #1.25μm ±0.05375

my $t = Time.new(value => 10, units => 'ms', error => 0.2);
say ~( 17 / $t );                               #1700Hz ±34

# Measure math adjusts units and error automagically
say ~( $y / $t );                               #0.000125m/s ±0.000007875e0

# works with add, subtract, multiply, divide, power and root
# add & subtract add absolute error
# multiply & divide add relative error
# power and root multiply relative error by power

my Length $w = Length.new(value => 10, units => 'm', error => '2%');
my $z = $w ** 3;  say ~$z;                      #1000m^3 ±60
$z = $z ** <1/3>; say ~$z;                      #10m ±2.00e-01

# As do Measure cmp operators (to within error limits)
say $w cmp $y;                                  #More
```
Controls for Error output format and rounding of percentage errors (here with default values). These only act on the .Str output rendering and leave the .error.absolute "truth" untouched.

```perl6
$Physics::Error::default   = 'absolute';    #default error output [absolute|percent]
$Physics::Error::round-per = 0.001;         #control rounding of percent
```
Two ways for Measure output precision control. These only act on the .Str output rendering and leave the Measure .value and .error.absolute "truth" untouched.
#### Automagic
This option uses .error.denorm to right shift the error value and align to the mantissa precision of the measure value. The number of significant digits in the error is then used to round the measure value.

```perl6
# Here's the mass of the electron Em in action...
my \Em = 9.109_383_701_5e-31kg ±0.000_000_002_8e-31;

say ~Em;                                        #9.1093837015e-31kg ±0.0000000028e-31
say Em.error.absolute;                          #2.8e-40
say Em.error.relative;                          #3.0737534961217373e-10
say Em.error.relative.^name;                    #Num
say Em.error.percent;                           #0%
```
#### Manual
Manual precision can be set - this overrides the automagic behaviour.
```perl6
$Physics::Measure::round-val = 0.01;

my $c = ♎️ '299792458 m/s';
my $ℎ = ♎️ '6.626070015e-34 J.s';

my \λ = 2.5nm; 
is ~λ, '2.5nm',									'~λ';

my \ν = $c / λ;  
is ~ν.norm, '119.92PHz',						'~ν.norm';

my \Ep = $ℎ * ν;  
is ~Ep.norm, '79.46aJ',						    '~Ep.norm';
```

In wikipedia, the general topic is https://en.wikipedia.org/wiki/Propagation_of_uncertainty
- this gets fairly heavy fairly quickly --- real world physical errors can be non-linear and accelerate rapidly
- this module is definitively LINEAR ONLY ;-) ... do not use in mission critical applications without knowing what you are doing

Physics::Error supports the three use cases for making Measure objects with value, units & error as outlined in the Physics::Measure [README.md](https://github.com/p6steve/raku-Physics-Measure/edit/master/README.md). The formats are dissected below:

####Option 1: Postfix Operator Syntax (SI Units)

```
my Length $x = 12.5nm ± 10%;
   ------ -- - ------ - ---
      |    | |   |  | |  |
      |    | |   |  | |  > Rat percent error [or '±4.2%' Rat relative error]
      |    | |   |  | |
      |    | |   |  | > ± symbol as custom raku infix operator
      |    | |   |  |
      |    | |   |  > 'nm' Unit constructor as custom raku postfix operator (no ws)
      |    | |   |
      |    | |   > Real number
      |    | |
      |    | > assignment of new Object from postfix rhs
      |    |
      |    > a scalar variable
      |
      > Type (Length is Measure) ... can be omitted
```
####Option 2: Object Constructor Syntax

```
my Length $x = Length.new(value => 12.5, units => 'nm', error => [0.5|'4.3%']);
say ~$x; #42 ±4.2nanometre
```

####Option 3: Libra Shorthand Syntax

```
my Length $x = ♎️ '12.5 nm ±0.05';
   ------ --   --  ---- -- -----
      |    |    |   |   |  |  |
      |    |    |   |   |  |  |
      |    |    |   |   |  |  >  Real absolute error [or '±4.2%' Rat relative error]
      |    |    |   |   |  |
      |    |    |   |   |  > '±' symbol as custom raku prefix operator
      |    |    |   |   |
      |    |    |   |   > Str units (of Type Length is Measure)
      |    |    |   |
      |    |    |   > Real number
      |    |    |
      |    |    > parse rhs string, construct object and assign to lhs (♎️ <-- custom <libra> operator)
      |    |
      |    > a scalar variable
      |
      > Type (Length is Measure) ... can be omitted
```

####Help Wanted

Over time I imagine an eco-system of equation parsing / pde plugins and machine calibration matrices - feel free to continue the journey in this direction with a pull request!
