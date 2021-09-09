#!/usr/bin/env raku

use Physics::Error;

#Option 0
#--------

my $x = 12.5 does Error(0.5);       #Rat
my $y = 12.5e2 does Error(0.5e2);   #Num

#my $z = -$x;
#my $z = $x + $y;
my $z = $x + 17;
#my $z = 17 + $y;
#my $z = $x - $y;
#my $z = $y - $x;
#my $z = $x - $x;
#my $z = $x * $y;
#my $z = 17 * $x;
#my $z = $x / $y;
#my $z = 17 / $x;


say +$z;
say $z.abs-error;
say $z.rel-error;
say $z.percent-error;

#`[
#viz. https://www.mathsisfun.com/measure/error-measurement.html

Option 0: Standalone Errors

my $x = 12.5 does Error(0.5);

No opportunity for fancy slang, Grammar
Can override math functions
Not possible due to inability to unambiguously tighten infix sigs
Revert back to mixins later at Measure objects?

Option 1: Postfix Operator Syntax (SI Units)

my Length $l = 12.5nm ±10%;
   ------ -- - ------ ----
      |    | |   |  |  |
      |    | |   |  |  > Rat relative error [or '±4.2%' Rat relative error]
      |    | |   |  |
      |    | |   |  > 'nm' Unit constructor as custom raku postfix operator
      |    | |   |
      |    | |   > Real number
      |    | |
      |    | > assignment of new Object from postfix rhs
      |    |
      |    > a scalar variable
      |
      > Type (Length is Measure) ... can be omitted

#12.5nm ±10% is a List of two terms, first with postfix, second with prefix
#so can you implement via object $l taking a list? - maybe use that same lvalue thing?




Option 2: Object Constructor Syntax

my Length $l = Length.new(value => 12.5, units => 'nm', error => [4.2|10%]);

say ~$l; #42 ±4.2 nanometre


Option 3: Libra Shorthand Syntax

my Length $l ♎️ '12.5 ±0.05 nm';
   ------ -- --  ---- ----- --
      |    |  |   |   |  |  |
      |    |  |   |   |  |  |
      |    |  |   |   |  |  > Str units (of Type Length is Measure)
      |    |  |   |   |  |
      |    |  |   |   |  > Real absolute error [or '±4.2%' Rat relative error]
      |    |  |   |   |
      |    |  |   |   > '±' symbol as custom raku prefix operator
      |    |  |   |
      |    |  |   > Real number
      |    |  |
      |    |  > parse rhs string, construct object and assign to lhs (♎️ <-- custom <libra> operator)
      |    |
      |    > a scalar variable
      |
      > Type (Length is Measure) ... can be omitted




Notes:
- while very tempting to handle the relative case with a '%' postfix operator, this is not needed and possibly quite confusing with hash sigil
- would be nice to feed a Rat object or literal <1/2> into the relative error window



]



