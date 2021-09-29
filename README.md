# raku-Physics-Error
some code to handle physical measurement errors (nothing to do with programming errors!)

[![Build Status](https://app.travis-ci.com/p6steve/raku-Physics-Error.svg?branch=main)](https://app.travis-ci.com/p6steve/raku-Physics-Error)

WORK IN PROGRESS

look at the top left of your keyboard...
... there's probably a key marked '±'

this module lets you write something like:
* 0.5±0.012
* 0.5±2.4%

it also works with the [Physics::Measure](https://github.com/p6steve/raku-Physics-Measure) and [Physics::Unit](https://github.com/p6steve/raku-Physics-Unit) modules to do this:
* 23nm±1            (uses Physics::Measure postfix syntax)
* '30 mph ± 10%'    (uses ♎️ libra notation)

then you can go:
* $x.error;         #<1/10> as Rat
* $x.error.Str;     #±10% as Str 
* $x.error.Measure; #3 mph

Conceptually Length = '12.5 ±0.05 m' && Length = 12.5nm ±[1.25nm|1.25|10%]   (FIXME v2 will implement errors)
viz. https://www.mathsisfun.com/measure/error-measurement.html

things to consider:
* reducing a list / set of measurements
* interoperation with the raku [Stats module](https://github.com/MattOates/Stats)
* delineating precision vs. accuracy

in wikipedia, the topic is https://en.wikipedia.org/wiki/Propagation_of_uncertainty
* this gets fairly heavy fairly quickly --- and realworld physical errors can be non-linear and accelerate rapidly
* this module is definitively LINEAR ONLY ;-) ... do not use in mission critical applications without knowing what you are doing

this module assumes linear formulae
* it is open to subclassing if you want to maintain the textual API and connexion with sister modules, but to override the error calculation for non-linear formulae or real-world machines
* over time I imagine an eco system of equation parsing / pde plugins and machine calibration matrices - feel free to continue the journey in this direction with a pull request






- test
- synopsis
- readme

document
- new prefix to replace assign and declaration - $a = ♎'39 °C';
- dimensionless (1) also (drop (1) from say?? mode)
- output precision, 4 controls
  -- .norm (use SI prefixes to normalize)
  -- $Physics::Measure::round-val #round output (default 14 decimal places)
  -- $Physics::Error::sigfigs #control precision of absolute error (default 6 sigfigs)
- format controls
  -- percent / round-per
- time hms (no error, secs > 60 only )

sigfig
- viz. https://pml.nist.gov/cgi-bin/cuu/Value?me|search_for=atomnuc!
- \Em = 9.109_383_701_5e-31kg
-      ±0.000_000_002_8e-31;  (standard uncertainty)
-
- value: 1.10 = 11 significant digits
- error: 0.10 = 10 significant digits (padding 0s count if towards '.')
-
- round-to off
- ~Em      => 9.1093837015e-31kg ±2.8e-40
- ~Em.norm => 0.0009109383701500001yg ±2.8000000000000007e-13   [clipped to yg]
-
- norm:  0.14 = 14 significant digits
-
-
- viz. https://en.wikipedia.org/wiki/IEEE_754#Decimal
- IEEE_754 preserves 17 decimal digits for binary64


round-to
- naive constraint on the value
- is ~ν.norm, '119.92PHz'
- applied on output Str

thus
what to do if only one operand has an error
use case 1 - apply constant gauge calibration offset
use case 2 - apply linear gauge calibration factor
if operand is Real, Error (abs) is zero
