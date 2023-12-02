USING: accessors io kernel math prettyprint regexp sequences splitting math.parser math.order ;
IN: solution

TUPLE: game id rounds ;
TUPLE: roll color amount ;

: parse ( -- games ) 
    read-contents split-lines 
    [ 
        ": " split1
        "; " split-subseq
        [
            ", " split-subseq
            [
                " " split1
                roll new
                swap >>color swap
                dec> >>amount
            ] map
        ] map
        game new 
        swap >>rounds swap 
        " " split1 swap drop dec> >>id
    ] map
;

: part1 ( -- )
    parse 
    [
        rounds>>
        [
            [
                dup color>> "red" =
                    [ amount>> 12 <= ]
                    [ dup color>> "green" =
                        [ amount>> 13 <= ]
                        [ amount>> 14 <= ]
                    if ]
                if
            ] all?
        ] all?
    ] filter
    [ id>> ] map-sum
    .
;

TUPLE: triple 
    { red integer initial: 0 }
    { green integer initial: 0 }
    { blue integer initial: 0 }
;

: part2 ( -- )
    parse
    [ 
        rounds>> 
        concat
        triple new
        [
            dup color>> "red" =
                    [ amount>> swap dup red>> swapd max >>red ]
                    [ dup color>> "green" =
                        [ amount>> swap dup green>> swapd max >>green ]
                        [ amount>> swap dup blue>> swapd max >>blue ]
                    if ]
                if
        ] reduce
        dup dup
        red>>
        swap green>>
        swapd swap blue>>
        * *
    ] map-sum
    .
;

MAIN: part2
