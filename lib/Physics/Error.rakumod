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
output abs??

inputs (option 1,3)

guard rail err > 50%
set round to (value and error)
set sigfig s

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
- design, implement & document application of Error to Duration

]

my regex number {
    \S+                     #grab chars
    <?{ +"$/" ~~ Real }>    #assert coerces via '+' to Real
}

class Error is export {
    has Real $.absolute is rw;

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

    #### Getter Methods ####
    method relative( Real $value --> Real ) {
        return (0/0).Num if $value == 0 && $!absolute == 0;
        return Inf if $value == 0;
        ( $!absolute / $value ).abs
    }
    method percent( Real $value --> Str ) {
        "{self.relative( $value ) * 100}%"
    }

    #### Meth Methods ####


}

