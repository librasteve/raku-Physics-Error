#!/usr/bin/env raku
use Physics::Measure :ALL;


#Option 1
#--------

#my Length $x = 12.5nm ± 1;
#my Length $x = 12.5nm ± 10%;
#my Length $x = 12.5nm;

#Option 2
#--------

#my Length $x = Length.new(value => 12.5, units => 'nm');
#my Length $x = Length.new(value => 12.5, units => 'nm', error => 0);
#my Length $x = Length.new(value => 0, units => 'nm', error => 0.5);
#my Length $x = Length.new(value => 12.5, units => 'nm', error => 0.5);
#my Length $x = Length.new(value => 12.5, units => 'nm', error => '4.3%');

#Option 3
#--------

#my Length $x = ♎️ '12.5 ft ±0.5';
#my Length $x = ♎️ '12.5 ft ±10.5%';
#my Length $x = ♎️ '12.5 ft';

#say $x;
#say ~$x; #12.5nm ±4%
#say $x.error.absolute;
#say $x.error.relative;
#say $x.error.percent;
#say $x.error.relative.WHAT;

#my Length $y = Length.new(value => 12.5e2, units => 'nm', error => '4.3%');
#my Length $y = Length.new(value => 12.5e2, units => 'μm');

#say $y;
#say ~$y; #1250μm ±4.3%
#say $y.error.absolute;
#say $y.error.relative;
#say $y.error.percent;
#say $y.error.relative.WHAT;
#say ~$y.in('nm');
#say ~$y.norm;

#my $z = -$x;
#my $z = $x + $y;
#my $z = $y + $x;
#my $z = $x + 17;
#my $z = .2 - $x;
#my $z = 17 + $y;
#my $z = $x - $y;
#my $z = $y - $x;
#my $z = $x - $x;
#my $z = $x * $y;
#my $z = 17 * $x;
#my $z = $x / $y;

#my Time $t = Time.new(value => 10, units => 'ms', error => '4.3%');
#say ~$t;
#my $z = 17 / $t;

#my Length $w = Length.new(value => 10, units => 'm', error => '2%');
#my $z = $w ** 3;
#$z = $z ** <1/3>;

#my $z = $x - $y;
#$z .= norm;

#say $x cmp $y;

#say $z;
#say ~$z; #42 ±4.2 nanometre
#say ~$z.norm;
#say $z.norm.magnitude;
#say $z.error.absolute;
#say $z.error.relative;
#say $z.error.percent;
#say $z.error.relative.WHAT;

$Physics::Measure::round-val = Nil;

#my \Em = 9.109_383_7015e-31m ±0.000_000_0028e-31; #guard rail test (lower)
#my \Em = 9109_383_7015e30kg ±28e30;                #guard rail test (upper)


my \Em = 9.109_383_701_5e-31kg ±0.000_000_002_8e-31;
say ~Em;
#say ~Em.error;
#say Em.^name;
#say ~Em.norm;
#say ~Em.norm.error;
say Em.error.absolute;
say Em.error.relative;
say Em.error.percent;
say Em.error.relative.WHAT;

#`[
#viz. https://www.mathsisfun.com/measure/error-measurement.html
#viz. https://www.geol.lsu.edu/jlorenzo/geophysics/uncertainties/Uncertaintiespart1.html

Option 0: Standalone Errors   <=== nope!

my $x = 12.5 does Error(0.5);

No opportunity for fancy slang, Grammar
Can't override math functions due to ambiguities in infix signatures
Recommend use of Dimensionless Measure objects

Option 1: Postfix Operator Syntax (SI Units)

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

#12.5nm ±10% is a List of two terms, first with postfix, second with prefix
#so can you implement via object $x taking a list? - maybe use that same lvalue thing?

Option 2: Object Constructor Syntax

my Length $x = Length.new(value => 12.5, units => 'nm', error => [0.5|'4.3%']);

say ~$x; #42 ±4.2nanometre


Option 3: Libra Shorthand Syntax

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




Notes:
- while very tempting to handle the relative case with a '%' postfix operator, this is not needed and possibly quite confusing with hash sigil
- would be nice to feed a Rat object or literal <1/2> into the relative error window



]



