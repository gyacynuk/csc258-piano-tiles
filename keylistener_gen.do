vlib work
vlog -timescale 1ns/1ns KeyListener.v
vsim KeyListener -l ouput_keylistener.txt
log {/*}
add wave {/*}
force {clk} 0

force {resetn} 0

force {KEY[3]} 0
force {KEY[2]} 0
force {KEY[1]} 0
force {KEY[0]} 0

run 20ns
force {clk} 1

run 20ns
force {clk} 0

force {resetn} 1

run 20ns
echo "assert 0000 reset"
examine {key_pressed[3]}
examine {key_pressed[2]}
examine {key_pressed[1]}
examine {key_pressed[0]}

run 20ns
echo "assert 0000 reset"
examine {key_held[3]}
examine {key_held[2]}
examine {key_held[1]}
examine {key_held[0]}

run 20ns
echo "assert 0000 reset"
examine {key_released[3]}
examine {key_released[2]}
examine {key_released[1]}
examine {key_released[0]}


run 20ns
echo "assert 0000 key_held"
examine {key_pressed[3]}
examine {key_pressed[2]}
examine {key_pressed[1]}
examine {key_pressed[0]}

run 20ns
echo "assert 0000 key_held"
examine {key_held[3]}
examine {key_held[2]}
examine {key_held[1]}
examine {key_held[0]}

run 20ns
echo "assert 0000 key_held"
examine {key_released[3]}
examine {key_released[2]}
examine {key_released[1]}
examine {key_released[0]}

force {KEY[0]} 1

run 20ns
force {clk} 1

run 20ns
force {clk} 0

force {KEY[0]} 0

run 20ns
echo "assert 0001 key_held"
examine {key_held[3]}
examine {key_held[2]}
examine {key_held[1]}
examine {key_held[0]}

force {clk} 1

run 20ns
force {clk} 0

run 20ns
echo "assert 0000 key_held"
examine {key_held[3]}
examine {key_held[2]}
examine {key_held[1]}
examine {key_held[0]}


run 20ns
echo "assert 0000 key_pressed"
examine {key_pressed[3]}
examine {key_pressed[2]}
examine {key_pressed[1]}
examine {key_pressed[0]}

run 20ns
echo "assert 0000 key_pressed"
examine {key_held[3]}
examine {key_held[2]}
examine {key_held[1]}
examine {key_held[0]}

run 20ns
echo "assert 0001 key_pressed"
examine {key_released[3]}
examine {key_released[2]}
examine {key_released[1]}
examine {key_released[0]}

force {KEY[0]} 1

run 20ns
force {clk} 1

run 20ns
force {clk} 0

run 20ns
echo "assert 0001 key_pressed"
examine {key_pressed[3]}
examine {key_pressed[2]}
examine {key_pressed[1]}
examine {key_pressed[0]}

force {clk} 1

run 20ns
force {clk} 0

force {KEY[0]} 0

run 20ns
echo "assert 0000 key_pressed"
examine {key_pressed[3]}
examine {key_pressed[2]}
examine {key_pressed[1]}
examine {key_pressed[0]}

force {clk} 1

run 20ns
force {clk} 0

run 20ns
echo "assert 0000 key_pressed"
examine {key_pressed[3]}
examine {key_pressed[2]}
examine {key_pressed[1]}
examine {key_pressed[0]}

