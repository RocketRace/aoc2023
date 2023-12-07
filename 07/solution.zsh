#!/bin/zsh

# set this to either "part1" or "part2"
part=part2

hands=()
bets=()
while true; do 
    read -u 0 -k 5 hand -t || break
    read -u 0 -k 1 
    read -u 0 bet 
    hands+=($hand)
    bets+=($bet)
done

function card-value() {
    if [[ $2 == part2 && $1 == J ]]; then
        echo 1
    else
        case $1 in
            [2-9]) echo $1 ;;
            T) echo a ;;
            J) echo b ;;
            Q) echo c ;;
            K) echo d ;;
            A) echo e ;;
        esac
    fi
}

function shape() {
    hand=$1
    part=$2
    cards=(2 3 4 5 6 7 8 9 T J Q K A)
    counts=(0 0 0 0 0 0 0 0 0 0 0 0 0)
    for ((i=0; i<5; i++)); do
        for ((j=1; j<=$#cards; j++)); do
            char=${hand:$i:1}
            if [[ $char == $cards[j] ]]; then
                ((counts[j]+=1))
            fi
        done
    done
    frequent=(${(O@)counts})
    if [[ $frequent[1] == 5 ]]; then
        shape=6;
    elif [[ $frequent[1] == 4 ]]; then
        shape=5;
    elif [[ ($frequent[1] == 3) && ($frequent[2] == 2) ]]; then
        shape=4;
    elif [[ $frequent[1] == 3 ]]; then
        shape=3;
    elif [[ ($frequent[1] == 2) && ($frequent[2] == 2) ]]; then
        shape=2;
    elif [[ $frequent[1] == 2 ]]; then
        shape=1;
    else;
        shape=0;
    fi
    if [[ $part == part1 ]]; then
        echo $shape
    else
        jokers=$counts[10] # joker is the 10th card (1-indexed)
        case "$shape $jokers" in
            (0 0) echo 0;;
            (0 1) echo 1;; # Jabcd -> aabcd; high card -> pair
            (1 0) echo 1;;
            (1 1) echo 3;; # Jaabc -> aaabc; pair -> 3 of a kind
            (1 2) echo 3;; # JJabc -> aaabc; pair -> 3 of a kind
            (2 0) echo 2;;
            (2 1) echo 4;; # Jaabb -> aaabb; 2 pair -> full house
            (2 2) echo 5;; # JJaab -> aaaab; pair -> 4 of a kind
            (3 0) echo 3;;
            (3 1) echo 5;; # Jaaab -> aaaab; 3 of a kind -> 4 of a kind
            (3 3) echo 5;; # JJJab -> aaaab; 3 of a kind -> 4 of a kind
            (4 0) echo 4;;
            (4 2) echo 6;; # JJaaa -> aaaaa; full house -> 5 of a kind
            (4 3) echo 6;; # JJJaa -> aaaaa; full house -> 5 of a kind
            (5 0) echo 5;;
            (5 1) echo 6;; # Jaaaa -> aaaaa; 4 of a kind -> 5 of a kind
            (5 4) echo 6;; # JJJJa -> aaaaa; 4 of a kind -> 5 of a kind
            (6 0) echo 6;;
            (6 5) echo 6;; # well at this point you're just flexing
        esac
    fi
}

function key() {
    hand=$1
    part=$2
    key="$(shape $hand $part)"
    for ((i=0; i<5; i++)) do
        char=$(card-value "${hand:$i:1}" $part)
        key="$key$char"
    done
    echo $key
}

keys=()
for hand in $hands; do
    key=$(key $hand $part)
    keys+=($key)
done
sorted=(${(o)keys})

total=0
for ((i=1; i<=$#hands; i++)); do
    key=$keys[i]
    rank=$sorted[(ie)$key]
    ((winning = bets[i] * rank))
    ((total += winning))
done

echo $total

