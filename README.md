# raku-Physics-Error
some code to handle physical measurement errors (hopefully it has nothing to do with programming error§!)

look at the top left of your keyboard...
... there's probably a key marked '±'

this module lets you write something like:
* 0.5±0.01
* 0.5±10%

it also works with the [Physics::Measure](https://github.com/p6steve/raku-Physics-Measure) and [Physics::Unit](https://github.com/p6steve/raku-Physics-Unit) modules to do this:
* 23nm±1
* 30mph±10%



in wikipedia, the topic is https://en.wikipedia.org/wiki/Propagation_of_uncertainty
* this gets fairly heavy fairly quickly --- and realworld physical errors can be non-linear and accelerate rapidly
* right now this module is definitively LINEAR ONLY ;-) ... so please do not use it in mission critical applications unless you know what you are doing

this module assumes linear formulae - it is open to subclassing if you want to maintain the textual API and connexion with sister modules, but to override the error calculation for non-linear formulae or real-world machines
* over time I imagine an eco system of equation parsing / pde plugins and machine calibration matrices - feel free to continue the journey in this direction with a pull request
