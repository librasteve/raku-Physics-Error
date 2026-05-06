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

    method denorm {
        sub unpack-sme(Str() $number) {
            # get sign, mantissa & exponent Str from Num|FatRatStr (Real)   ###HMMM do this work for Rat / FatRat
            $number ~~ / (<[-+]>?) (<-[eE]>*) <[eE]>? (.*) /;

            my $sign = $0 // '';
            my $mantissa = $1;
            my $exponent = +$2;

            return($sign, $mantissa, $exponent)
        }

        # unpack absolute
        my $absolute  = $!absolute  ~~ FatRat ?? $!absolute.FatRatStr  !! $!absolute;
        my (Any, $mantissa, $err-exp) = unpack-sme($absolute);

        # get either side of decimal point
        $mantissa ~~ / (<-[.]>*) '.'? (.*) /;
        my $integer = ~$0;
        my $fraction = ~$1;

        # unpack mea-value exponent
        my $mea-value = $!mea-value ~~ FatRat ?? $!mea-value.FatRatStr !! $!mea-value;
        my (Any, Any, $mea-exp) = unpack-sme($mea-value);

        my $adjust-exp;
        my $error-str;

        # FIXME - what about "cross-terms" (eg. mea has exp, err not and viceversa) HMMM  #iamerejh
        if $fraction {
            say 47;
            if $err-exp {

                # case 1: 2.8 ... -10 => 0.0000000028

                # for fraction, count digits eg. x.｢8｣ => -1, x.｢0000000028｣ => -10
                $adjust-exp = -$fraction.chars;

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
                        when   * != 0,    * == 0   { 'e' ~ $err-exp }   #HMMM fixed #3810001250nm ±0.40020245 !...
                    }
                }

                $error-str = "0.{ $left-pad }{ $integer }{ $fraction }{ new-exp }";

            } else {
                say 48;
                # case 2: 54.288  ...  0 => 54.288
                $adjust-exp = -$fraction.chars;
                $error-str = "{ $integer }.{ $fraction }";
            }
        } else {
            say 49;
            # for integer, count right zero pad eg. 9000[.] => 3
            $integer ~~ / ('0'*) $ /;
            $adjust-exp = $0.chars;

            $error-str = "$mantissa";
        }

        say 33, $error-str;

        # make round value
        my $digits = $adjust-exp + $err-exp - 1;    #lift precision by 10x

        my FatRat() $round;
        $round  = 10 ** $digits;                    #start with FatRat (can over/under-flow)
        $round .= FatRatStr.Str;                    #need Str as arg for round()
        $round  = Nil if $!absolute == 0;           #do not round exact amounts

        return( $error-str, +$round );
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
