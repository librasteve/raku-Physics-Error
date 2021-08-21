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
