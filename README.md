# vtfuzz

A fuzzer for terminal emulators.

A quick and dirty zig program that pushes high volumes of seeded random data to
stdout. This can either be purely random bytes or constrained data such as only
CSI escapes, or a mix of various categories.

## WIP

This project is currently very new and does not do everything it should yet.
