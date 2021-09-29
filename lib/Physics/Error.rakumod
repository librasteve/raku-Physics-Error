unit module Physics::Error:ver<1.0.0>:auth<Steve Roe (p6steve@furnival.net)>;

#`[
err.add = abs + abs -DONE
err.mul = rel + rel -DONE
err.pwr = n x rel -DONE
err.root = rel / n -DONE
Dimensionless for math -DONE
angle on decimal -DONE?
in -DONE
rebase -DONE
norm -DONE
cmp -DONE
output % -DONE
output abs (this is default for .gist) -DONE
inputs (option 1,3) -DONE
norm guard rails -DONE
set round-val -DONE
set sigfigS -DONE


document
- new prefix to replace assign and declaration - $a = ♎'39 °C';
- dimensionless (1) also (drop (1) from say?? mode)
- output precision, 3 controls
-- .norm (use SI prefixes to normalize)
-- $Physics::Measure::round-val #round output (default 14 decimal places)
--

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

v2 backlog
- reduction operators on List/Sequence of Errors (eg. sequence of readings)
- Standard Deviation (as a modal setting?)
- errors on unit definition factors
- method to define error propagation on functions eg. trig
- trig drop Error (manual)


]

our $sigfigs = 6; #control precision of absolute error
our $percent = 0; #optional 0=absolute|1=percent error
our $round-per = 0.0001; #controls rounding of percent

class Error is export {
    has Real $.absolute is rw;
    has Real $!mea-value;

    #### Constructor ####
    method new( :$error, :$value ) {
        #Measure $.error attr remains Error:U without defined error value
        return without $error;

        given $error {
            when Real {
                return self.bless( absolute => $error.abs )
            }
            when /^ ( <-[%]>* ) '%' $/ {
                return self.bless( absolute => ( +"$0" / 100 * $value ) )
            }
        }
    }

    # must be explicitly rebound on Error.new unless also Measure.new
    method bind-mea-value(\value) { $!mea-value := value };

    #### Getters ####
    method relative {
        return (0/0).Num if $!mea-value == 0 && $!absolute == 0;  #makes a NaN
        return Inf if $!mea-value == 0;
        ( $!absolute / $!mea-value ).abs
    }
    method percent {
        "{ self.relative.round( $round-per ) * 100 }%"
    }

    #### Formatting ###
    method Str {
        my $clipped = sprintf( "%.{$sigfigs}e", $!absolute);  #provides 6 sig digs
        return "{$percent ?? $.percent !! $clipped}"
    }

    #### Maths Ops ####
    multi method add-abs( Error:U ) {
        #nop
    }
    multi method add-abs( Error:D $r ) {
        self.absolute += $r.absolute
    }

    multi method add-rel( Error:U ) {
        return self.relative
    }
    multi method add-rel( Error:D $r ) {
        return self.relative + $r.relative
    }
}

