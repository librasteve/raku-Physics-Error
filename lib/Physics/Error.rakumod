unit module Physics::Error:ver<1.0.0>:auth<Steve Roe (p6steve@furnival.net)>;

our $default = 'absolute';  #set default error format [absolute|percent]
#our $default = 'percent';

our $round-per = 0.001;     #set rounding of percent

class Error is export {
    has Real $.absolute is rw;
    has Real $!mea-value;

    #### Constructor ####
    method new(:$error, :$value) {
        #Measure $.error attr remains Error:U without defined error value
        return without $error;

        given $error {
            when Real {
                return self.bless(absolute => $error.abs)
            }
            when /^ (<-[%]>*) '%' $/ {
                return self.bless(absolute => (+"$0" / 100 * $value))
            }
        }
    }
    # must be bound on Error.new unless also constructing Measure.new
    method bind-mea-value(\value) {
        $!mea-value := value
    };

    #### Getters ####
    method relative {
        return (0 / 0).Num if $!mea-value == 0 && $!absolute == 0;
        #makes a NaN
        return Inf if $!mea-value == 0;
        ($!absolute / $!mea-value).abs
    }
    method percent {
        #round to eg. 3 places eg. 13.042%
        "{ self.relative.round($round-per) * 100 }%"
    }

    #### Formatting ###
    method Str {
        "{ $default eq 'percent' ?? $.percent !! self.denorm[0] }"
    }

    sub unpack-sme(Str(Real) $number) {
        # get sign, mantissa & exponent Str from Int|Rat|Num (Real)
        $number ~~ / (<[-+]>?) (<-[eE]>*) <[eE]>? (.*) /;
        my $sign = $0 // '';
        my $mantissa = $1;
        my $exponent = +$2;

        return($sign, $mantissa, $exponent)
    }
    method denorm {
        # unpack absolute
        my (Any, $mantissa, $err-exp) = unpack-sme($!absolute);

        # get either side of decimal point
        $mantissa ~~ / (<-[.]>*) '.'? (.*) /;
        my $integer = ~$0;
        my $fraction = ~$1;

        #get mea-value exponent
        my (Any, Any, $mea-exp) = unpack-sme($!mea-value);

        my $adjust-exp;
        my $error-str;

        if $fraction {
            # for fraction, count significant digits eg. x.｢1093837015｣ => -10
            $adjust-exp = -$fraction.chars;

            # for fraction, denorm to match measure exponent...
            $integer = '' if $integer == '0';   #handle case of eg. 0.009
            my $exp-offset = -( $err-exp - $mea-exp + $integer.chars );

            # ... then left zero pad ...
            my $left-pad = '';
            $left-pad ~= '0' for 0..^$exp-offset;

            # ... and assemble with measure exponent
            my $new-exp = $err-exp == 0 ?? '' !! "e{$mea-exp}";
            $error-str = "0.{$left-pad}{$integer}{$fraction}{$new-exp}";

        } else {
            # for integer, count right zero pad eg. 9000[.] => 3
            $integer ~~ / ('0'*) $ /;
            $adjust-exp = $0.chars;

            $error-str = "$mantissa";
        }

        # make round-to argument to be applied to Measure value
        my $round-to  = "1e{ $adjust-exp + $err-exp - 1 }";  #give 10x precision
        $round-to = Nil if $!absolute == 0;

        return( $error-str, $round-to )
    }

    #### Maths Ops ####
    multi method add-abs(Error:U) {
        #nop
    }
    multi method add-abs(Error:D $r) {
        self.absolute += $r.absolute
    }

    multi method add-rel(Error:U) {
        return self.relative
    }
    multi method add-rel(Error:D $r) {
        return self.relative + $r.relative
    }
}

#EOF