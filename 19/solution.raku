my @stuff = "input".IO.slurp.split("\n\n");
my %workflows = ();
for @stuff[0].lines -> $workflow {
    if $workflow ~~ / (\w+) "\{" ( (\w+) ("<" | ">") (\d+) ":" (\w+ | R | A) "," )* (\w+ | R | A) "}" / {
        my $name = $0;
        my @rules = ();
        for @$1 -> $rule {
            my $check = $rule[0];
            my $condition = $rule[1];
            my $value = +$rule[2];
            my $branch = $rule[3];
            my %transformation = check=>$check, cond=>$condition, val=>$value, branch=>$branch;
            @rules.push(%transformation);
        }
        my $default = $2;
        %workflows{$name} = rules=>@rules, default=>$default;
    }
}
my $part1 = 0;
for @stuff[1].lines -> $rating {
    if $rating ~~ / "\{x=" (\d+) ",m=" (\d+) ",a=" (\d+) ",s=" (\d+) "}" / {
        my %register = x=>+$0, m=>+$1, a=>+$2, s=>+$3;
        my $method = "in";
        SHOOPIN: while not $method eq "R" and not $method eq "A" {
            my %ruleset = %workflows{$method};
            for @(%ruleset<rules>) -> %rule {
                if %rule<cond> eq ">" and %register{%rule<check>} > %rule<val> {
                    $method = %rule<branch>;
                    next SHOOPIN;
                }
                if %rule<cond> eq "<" and %register{%rule<check>} < %rule<val> {
                    $method = %rule<branch>;
                    next SHOOPIN;
                }
            }
            $method = %ruleset<default>;
        }
        if $method eq "A" {
            $part1 += $0 + $1 + $2 + $3
        }
    }
}
say $part1;
my $part2 = 0;
my @ranges = [{at=>"in", x=>(1, 4000), m=>(1, 4000), a=>(1, 4000), s=>(1, 4000)},];
WAHOO: while @ranges {
    my %hedron = @ranges.pop;
    if %hedron<at> eq "A" {
        $part2 += (%hedron<x>[1] - %hedron<x>[0] + 1) * (%hedron<m>[1] - %hedron<m>[0] + 1) * (%hedron<a>[1] - %hedron<a>[0] + 1) * (%hedron<s>[1] - %hedron<s>[0] + 1);
    } elsif %hedron<at> !eq "R" {
        my %ruleset = %workflows{%hedron<at>};
        for @(%ruleset<rules>) -> %rule {
            my $lower = %hedron{%rule<check>}[0];
            my $border = %rule<val>;
            my $higher = %hedron{%rule<check>}[1];
            if $lower < $border < $higher {
                my %newdron = %hedron.clone;
                my %neodrum = %hedron.clone;
                if %rule<cond> eq ">" {
                    %newdron{%rule<check>} = [$lower, $border];
                    %neodrum{%rule<check>} = [$border + 1, $higher];
                } else {
                    %newdron{%rule<check>} = [$border, $higher];
                    %neodrum{%rule<check>} = [$lower, $border - 1];
                }
                %neodrum<at> = %rule<branch>;
                @ranges.push(%newdron);
                @ranges.push(%neodrum);
                next WAHOO;
            }
        }
        %hedron<at> = %ruleset<default>;
        @ranges.push(%hedron);
    }
}
say $part2;