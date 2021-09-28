unit module Physics::Error:ver<1.0.0>:auth<Steve Roe (p6steve@furnival.net)>;

#`[
err.add = abs + abs -DONE
err.mul = rel + rel -DONE
err.pwr = n x rel -DONE
err.root = rel / n -DONE

in -DONE
rebase -DONE
norm -DONE
cmp -DONE
output % -DONE
output abs (this is default for .gist) -DONE

inputs (option 1,3)

guard rail err > 50%
set round to (value and error)
set sigfig s


eg. value => 12.5e2, error => '4.3%' ...
error => Physics::Error::Error.new(absolute => 53.74999999999999e0



angle on decimal -DONE?
trig drop Error (manual)

Dimensionless for math -DONE?
(drop (1) from say?? mode)

thus
what to do if only one operand has an error
use case 1 - apply constant gauge calibration offset
use case 2 - apply linear gauge calibration factor
if operand is Real, Error (abs) is zero

v2 backlog
- reduction operators on List/Sequence of Errors (eg. sequence of readings)
- Standard Deviation (as a modal setting?)
- errors on unit definition factors

todos
- design, implement & document application of Error to Duration (if any)
- layer in error to assignment section of Measure.rakumod

document new prefix to replace assign and declaration
- $a = ♎'39 °C';


]

my regex number {
    \S+                     #grab chars
    <?{ +"$/" ~~ Real }>    #assert coerces via '+' to Real
}

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
            when /(<number>) '%'/ {
                return self.bless( absolute => ( $0 / 100 * $value ) )
            }
        }
    }

    # value must be explicitly rebound on Error.new but not Measure.new
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

