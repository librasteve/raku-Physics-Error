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


set round to (value and error)
set sigfig s


document
- new prefix to replace assign and declaration - $a = ♎'39 °C';
- dimensionless (1) also (drop (1) from say?? mode)

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

# this option to set the general relative error
# this is the minimum permitted error
# viz. https://pml.nist.gov/cgi-bin/cuu/Value?plkm#mid = 1.1 x 10^-5
our $relative-standard-uncertainty = 1.1e-5;


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
        "{ self.relative * 100 }%"
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

