proc forward {n} { incr ::pos $n }
proc down {n} { incr ::depth $n }
proc up {n} { incr ::depth -$n }

source input.txt

puts [expr $pos * $depth]
