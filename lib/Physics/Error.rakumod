#viz. https://www.mathsisfun.com/measure/error-measurement.html
#viz. https://www.geol.lsu.edu/jlorenzo/geophysics/uncertainties/Uncertaintiespart1.html
#viz. https://en.wikipedia.org/wiki/IEEE_754#Decimal ... IEEE_754 preserves 17 decimal digits for binary64

use FatRatStr;

our $default = 'absolute';  #set default error format [absolute|percent]
#our $default = 'percent';

our $round-per = 0.001;     #set rounding of percent for get & set (0.001 == 0.01% )

class Error is export {
    has Real() $.absolute is rw;
    has Real() $!mea-value;

    #### Constructor ####
    method new(:$error, :$value) {
        #Measure $.error attr cleared without defined error value
        return Nil without $error;

        #Stringify percent to avoid circular dependency
        given $error {
            when Real {
                self.bless(absolute => $error.abs)
            }
            when /^ (<-[%]>*) '%' $/ {
                my $percent = +"$0";
                self.bless( absolute => ($percent / 100 * $value).round($round-per) )
            }
            when /^ (<-[%]>*) 'percent' $/ {
                my $percent = +"$0";
                self.bless( absolute => ($percent / 100 * $value).round($round-per) )
            }
            default {
                Nil     #clear Measure $.error attr
            }
        }
    }
    # must be bound on Error.new unless also constructing Measure.new
    method bind-mea-value(\value) {
        $!mea-value := value
    };

    #### Getters ####
    method relative {
        return (0 / 0).Num if $!mea-value == 0 && $!absolute == 0; #makes a NaN
        return Inf if $!mea-value == 0;
        ($!absolute / $!mea-value).abs
    }
    method percent {
        #round to eg. 3 places eg. 13.042%
        "{ self.relative.round($round-per) * 100 }%"
    }

    #### Formatting & Rounding ###
    method Str {
        "{ $default eq 'percent' ?? $.percent !! self.denorm[0] }"
    }
    method gist {
        self.Str
    }

    #iamerejh
    #| general idea is to denormalize (right shift) the error Num to align with the mea(sure) value
    #|  9.1093837015e-31kg ±0.0000000028e-31, can also be formatted
    #|  9.1093837015e-31kg    ... value is normalized   (add \n?)
    #| ±0.0000000028e-31      ... error is denormalized to align
    #|
    #| rules:
    #|  - value is a Real (often a FatRat)
    #|  - error.absolute is a Real (often a FatRat)
    #|  - any combination of Real types may be encountered
    #|  - does not affect the object values

    #| denormalized error for use in .Str output
    method denorm(-->Str) {

        my ($err-exp, $mantissa, $integer, $fraction)
                    = $!absolute.FatRatStr.unpack<exponent mantissa integer fraction>;
        my $mea-exp = $!mea-value.FatRatStr.unpack<exponent>;

        my Str $error;

        if $fraction {
            if $err-exp {
                # case 1: 2.8 ... -10 => 0.0000000028

                # for fraction, denorm to match measure exponent...
                $integer = '' if $integer == '0';
                #handle case of eg. 0.009
                my $exp-offset = -($err-exp - $mea-exp + $integer.chars);

                # ... then left zero pad ...
                my $left-pad = '';
                $left-pad ~= '0' for ^$exp-offset;

                # ... and assemble with measure exponent
                sub new-exp {
                    given     $err-exp,  $mea-exp  {
                        when   * == 0,    *        { '' }
                        when   * != 0,    * != 0   { 'e' ~ $mea-exp }
                        when   * != 0,    * == 0   { '' }
                    }
                }

                $error = "0.{ $left-pad }{ $integer }{ $fraction }{ new-exp }";

            } else {
                # case 2: 54.288  ...  0 => 54.288
                $error = "{ $integer }.{ $fraction }";
            }
        } else {
             $error = "$mantissa";
        }

        return( $error );
    }

    #| scale (Num literal Str) for round($scale)
    method scale(--> Str()) {
        my ($err-exp, $integer, $fraction) = $!absolute.FatRatStr.unpack<exponent integer fraction>;

        my $adjust-exp;
        if $fraction {
            # for fraction, count digits eg. x.｢8｣ => -1, x.｢0000000028｣ => -10
            $adjust-exp = -$fraction.chars;
        } else {
            # for integer, count right zero pad eg. 9000[.] => 3
            $integer ~~ / ('0'*) $ /;
            $adjust-exp = $0.chars;
        }

        my $digits = $adjust-exp + $err-exp - 1;    #lift precision by 10x

        my FatRat() $scale;                         #make FatRat (can over/under-flow)
        $scale  = 10 ** $digits;
        $scale .= FatRatStr;                        #avoids infecting precision

        return( $scale );
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
