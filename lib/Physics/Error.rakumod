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
]

role Error is export {
    has Real $.abs-error;       #set public attr in does mixin

    #override getter - abs-error always +ve (using .abs method)
    method abs-error( --> Real ) { $!abs-error.abs }

    #other getter/setter methods are filters on abs-error value
    method rel-error( --> Real ) { ( $!abs-error / self ).abs }
    method percent-error( --> Str ) { "{self.rel-error * 100}%" }

    #private helper methods
    method !ae { $.abs-error }   #shorthand alias
    method !re { $.rel-error }   #shorthand alias
    method !vx { +"{self}" }     #extract unadorned value of $x
    #viz. https://stackoverflow.com/questions/69101485/

    #math methods to implement operator overrides
    method add( $right ) {
        my $out-val = self!vx + $right!vx;
        $out-val does Error( self!ae + $right!ae )
    }
    method subtract( $right ) {
        my $out-val = self!vx - $right!vx;
        $out-val does Error( self!ae + $right!ae )
    }
    method negate {
        my $out-val = - self!vx;
        $out-val does Error( self!ae )
    }
    method multiply( $right ) {
        my $out-val = self!vx * $right!vx;
        $out-val does Error( ( self!re + $right!re ) * $out-val )
    }
    method multiply-const( Real:D $right ) {
        my $out-val = self!vx * $right;
        $out-val does Error( self!re * $out-val )
    }
    method divide( $right ) {
        my $out-val = self!vx / $right!vx;
        $out-val does Error( ( self!re + $right!re ) * $out-val )
    }
    method reciprocal {
        my $out-val = 1 / self!vx;
        $out-val does Error( self!re * $out-val )
    }


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

sub infix-prep( $left, $right ) {
    #clone object (e.g. Rat+{Physics::Error::Error}) as container for result
    #mixin Error to other arg. unless already has [same, zero]
    #don't forget to swap sides back e.g.for intransigent operations

    my ( $result, $argument );
    if $left ~~ Error && $right ~~ Error {
        $result   = $left.clone;
        $argument = $right;
    }
    #`[elsif $left ~~ Measure {
        $result   = $left.clone;
        $argument = $left.clone.new: $right;
    } elsif $right ~~ Measure {
        $result   = $right.clone.new: $left;
        $argument = $right.clone;
    }]
    return( $result, $argument );
}

#math

multi prefix:<-> ( Error:D $x ) is default { $x.negate }

multi infix:<+> ( Error:D $left, Error:D $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.add( $argument );
}
#`[
multi infix:<+> ( Measure:D $left, $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.add( $argument );
}
multi infix:<+> ( $left, Measure:D $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.add( $argument );
}
#]
multi infix:<-> ( Error:D $left, Error:D $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.subtract( $argument );
}
#`[
multi infix:<-> ( Measure:D $left, $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.subtract( $argument );
}
multi infix:<-> ( $left, Measure:D $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.subtract( $argument );
}

multi infix:<*> ( Measure:D $left, Real:D $right ) is export {
    my $result   = $left.clone;
    my $argument = $right;
    return $result.multiply-const( $argument );
}

multi infix:<*> ( Real:D $left, Error:D $right ) is export {
    my $result   = $right.clone;   #iamerejh
    my $argument = $left;
    return $result.multiply-const( $argument );
}
#]
multi infix:<*> ( Error:D $left, Error:D $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.multiply( $argument );
}
#`[
multi infix:<*> ( Measure:D $left, $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.multiply( $argument );
}
multi infix:<*> ( $left, Measure:D $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.multiply( $argument );
}

multi infix:</> ( Measure:D $left, Real:D $right ) is equiv( &infix:</> ) is export {
    my $result   = $left.clone;
    my $argument = $right;
    return $result.divide-const( $argument );
}

multi infix:</> ( Real:D $left, Error:D $right ) is equiv( &infix:</> ) is export {
    my $result   = $right.clone;
    my $argument = $left;
    my $recip = $result.reciprocal;
    return $recip.multiply-const( $argument );
}
#]

multi infix:</> ( Error:D $left, Error:D $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.divide( $argument );
}
#`[
multi infix:</> ( Measure:D $left, $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.divide( $argument );
}
multi infix:</> ( $left, Measure:D $right ) is export {
    my ( $result, $argument ) = infix-prep( $left, $right );
    return $result.divide( $argument );
}

multi infix:<**> ( Measure:D $left, Int:D $right where 2..4 ) is equiv( &infix:<**> ) is export {
    # 2(square),3(cube),4(fourth) e.g. T**4 for Boltzmann constant
    my $result   = $left.clone;
    my $argument = $right;
    return $result.power( $argument );
}
multi infix:<**> ( Measure:D $left, Rat:D $right where (<1/2>,<1/3>,<1/4>).one ) is equiv( &infix:<**> ) is export {
    # 1/2 (sqrt), 1/3 (curt), 1/4 (fort) - NB also method sqrt() defined in Measure Class
    my $result   = $left.clone;
    my $argument = ( 1 / $right ).Int;
    return $result.root( $argument );
}
multi sqrt ( Measure:D $left ) is export {
    return $left.clone.sqrt;
}

multi infix:<cmp> ( Measure:D $a, Measure:D $b ) is equiv( &infix:<cmp> ) is export {
    return $a.cmp( $b );
}
multi infix:<==> ( Measure:D $a, Measure:D $b ) is equiv( &infix:<==> ) is export {
    if $a.cmp( $b) ~~ Same { return True; }
    else { return False; }
}
multi infix:<!=> ( Measure:D $a, Measure:D $b ) is equiv( &infix:<!=> ) is export {
    if $a.cmp( $b) ~~ Same { return False; }
    else { return True; }
}]
