# Required behavior
Reset is synchronous and active-low.
wr_en && !full performs one write.
rd_en && !empty performs one read.
Writes while full are ignored.
Reads while empty are ignored.
count reports the current number of stored elements.
full is asserted when count == DEPTH.
empty is asserted when count == 0.
Data must leave the FIFO in the same order it entered.
DEPTH is not guaranteed to be a power of two.
Simultaneous operations

When both wr_en and rd_en are asserted:

If neither blocked, perform both and leave count unchanged.
If empty, reject the read but accept the write.
If full, reject the write but accept the read.
The rejected operation must not affect its pointer.

For this exercise, do not implement fall-through behavior. A word written into an empty FIFO cannot be read during that same clock edge.

Important edge cases

Your design should correctly handle:

DEPTH = 1
Non-power-of-two depths such as 3, 5, and 10
Pointer wraparound
Repeated reads while empty
Repeated writes while full
Simultaneous reads and writes
Reset while the FIFO contains data

Avoid relying on pointer overflow alone for wraparound because $clog2(DEPTH) permits pointer values that are outside the memory for non-power-of-two depths.

# Verification targets

Write a self-checking testbench that covers at least:

Reset and confirm empty, !full, and count == 0.
Write one item and read it back.
Fill the FIFO and attempt one extra write.
Empty the FIFO and attempt one extra read.
Verify ordering across pointer wraparound.
Perform simultaneous reads and writes for several cycles.
Test with DEPTH = 5.
Compare every successful read against a queue-based scoreboard.