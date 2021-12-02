set aim 0

proc forward {n} { incr ::pos $n; incr ::depth [expr $n * $::aim] }
proc down {n} { incr ::aim $n }
proc up {n} { incr ::aim -$n }

source input.txt

puts [expr $pos * $depth]
