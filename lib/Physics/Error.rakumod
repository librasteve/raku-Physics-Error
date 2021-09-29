unit module Physics::Error:ver<1.0.0>:auth<Steve Roe (p6steve@furnival.net)>;

our $sigfigs = 6; #control precision of absolute error
our $default = 'absolute'; #optional [absolute|percent] error
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

    # must be bound on Error.new unless also constructing Measure.new
    method bind-mea-value(\value) { $!mea-value := value };

    #### Getters ####
    method relative {
        return (0/0).Num if $!mea-value == 0 && $!absolute == 0;  #makes a NaN
        return Inf if $!mea-value == 0;
        ( $!absolute / $!mea-value ).abs
    }
    method percent {
        #round to eg. 4 places eg. 13.02%
        "{ self.relative.round( $round-per ) * 100 }%"
    }

    #### Formatting ###
    method Str {
        #clip to eg. 6 significant digits
        my $clipped = sprintf( "%.{$sigfigs}e", $!absolute);
        return "{$default eq 'percent' ?? $.percent !! $clipped}"
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

#EOF