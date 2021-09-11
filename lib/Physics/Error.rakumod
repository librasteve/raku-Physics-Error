unit module Physics::Error:ver<1.0.0>:auth<Steve Roe (p6steve@furnival.net)>;

#`[
design
abs - truth - Real
rel - rat
both private
if error then
err.add = abs + abs
err.mul = rel + rel
guard rail err > 50%
set round to

err.pwr = n x rel
err.root = rel / n

angle on dec and secs?

trig drop (manual) or linear +warn?

thus
what to do if only one operand has an error
use case 1 - apply constant gauge calibration offset
use case 2 - apply linear gauge calibration factor
if operand is Real, Error (abs) is zero

things for v2
- reduction operators on List/Sequence of Errors (eg. sequence of readings)
- Standard Deviation (as a modal setting?)

todos
- fix make-same conversion

]

my regex number {
    \S+                     #grab chars
    <?{ +"$/" ~~ Real }>    #assert coerces via '+' to Real
}

class Error is export {
    has Real $.absolute is rw;

    #### Constructor ####
    method new( :$error, :$value ) {
        #return Nil without defined error value
        #Measure $.error attr remains Error:U
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
        ( $value !== 0 ) ?? ( $!absolute / $value ).abs !! Inf
    }
    method percent( Real $value --> Str ) {
        "{self.relative( $value ) * 100}%"
    }

    #private helper methods
#    method !ae { $.absolute }   #shorthand alias
#    method !re { $.relative}   #shorthand alias
#    method !vx { +"{self}" }     #value of caller Measure
    #viz. https://stackoverflow.com/questions/69101485/

    #math methods to implement operator overrides
#    method add( $argument ) {
#        my $res-value = self!vx + $argument!vx;
#        $res-value does Error( self!ae + $argument!ae )
#    }
#    method subtract( $argument ) {
#        my $res-value = self!vx - $argument!vx;
#        $res-value does Error( self!ae + $argument!ae )
#    }
#    method negate {
#        my $res-value = - self!vx;
#        $res-value does Error( self!ae )
#    }
#    method multiply( $argument ) {
#        my $res-value = self!vx * $argument!vx;
#        $res-value does Error( ( self!re + $argument!re ) * $res-value )
#    }
#    method multiply-const( Real:D $argument ) {
#        my $res-value = self!vx * $argument;
#        $res-value does Error( self!re * $res-value )
#    }
#    method divide( $argument ) {
#        my $res-value = self!vx / $argument!vx;
#        $res-value does Error( ( self!re + $argument!re ) * $res-value )
#    }
#    method reciprocal {
#        my $res-value = 1 / self!vx;
#        $res-value does Error( self!re * $res-value )
#    }


    #`[
    method divide-const( Real:D $right ) {
        $.value /= $right;
        return self
    }

    method power( Int:D $n ) {						#eg. Area ** 2 => Distance
        my $result = self;
        my $factor = self;
        for 2..$n {
            $result .= multiply( $factor );
        }
        return $result
    }
    method root( Int:D $n where 1 <= $n <= 4 ) {
        my $l = self.rebase;
        my $nuo = $.units.root-extract( $n );
        my $nmo = ::($nuo.type).new( value => $l.value, units => $nuo );
        $nmo.value = $l.value ** ( 1 / $n );
        return $nmo
    }
    method sqrt() {
        return self.root( 2 )
    }

    method cmp( $a: $b ) {
		my ($an,$bn);
        if ! $a.units.type eq $b.units.type {
            die "Cannot cmp two Measures of different Type!"
        }
        if ! $a.units.same-unit( $b.units ) {
			say "Converting right hand Measure to cmp!" if $db;
			$an = $a;
			$bn = $b.in( $a.units )
		} else {
			say "Rebasing Measures for cmp." if $db;
			$an = $a.rebase;
			$bn = $b.rebase;
		}
		return $an.value cmp $bn.value
    }
]

}

