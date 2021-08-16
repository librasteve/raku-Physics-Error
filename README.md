# raku-Physics-Error
some code to handle physical errors


look at the top left of your keyboard...
... there's probably a key marked ±

this module lets you write something like:
* 0.5±0.01
* 0.5±10%
it also work with the [Physics::Measure](https://github.com/p6steve/raku-Physics-Measure) and [Physics::Unit](https://github.com/p6steve/raku-Physics-Unit) modules to do this:
* 23nm±1
* 30mph±10%

in wikipedia, the topic is https://en.wikipedia.org/wiki/Propagation_of_uncertainty

