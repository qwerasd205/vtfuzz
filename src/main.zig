const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout);
    const stdout_buffered = bw.writer();

    var prng = std.rand.DefaultPrng.init(0x3141592);
    const rnd = prng.random();

    var buf: [4096]u8 = undefined;
    while (true) {
        var offset: u16 = 0;
        while (offset < (4096 - 0xFF) and rnd.boolean()) {
            offset += randomCSI(rnd, buf[offset..]);
        }
        const rnd_offset = offset + @as(u16, @intCast(rnd.int(u8)));
        rnd.bytes(buf[offset..rnd_offset]);
        try stdout_buffered.writeAll(buf[0..rnd_offset]);
        try bw.flush();
    }
}

inline fn randomCSI(rnd: std.rand.Random, buf: []u8) u16 {
    var offset: u16 = 0;

    // CSI:
    buf[offset] = 0x1B;
    offset += 1;
    buf[offset] = '[';
    offset += 1;

    // Private marker (0x3C to 0x3F):
    if (rnd.boolean()) {
        buf[offset] = 0x3C + @as(u8, @intCast(rnd.int(u2)));
        offset += 1;
    }

    // Params:
    const param_count: u4 = rnd.int(u4);
    for (0..param_count) |_| {
        while (rnd.boolean()) {
            buf[offset] = randomDigit(rnd);
            offset += 1;
        }
        buf[offset] = ';';
        offset += 1;
    }
    offset -= 1; // remove last separator

    // Intermediate character (0x20 to 0x2F):
    if (rnd.boolean()) {
        buf[offset] = 0x20 + @as(u8, @intCast(rnd.int(u4)));
        offset += 1;
    }

    // Final (0x40 to 0x7E):
    buf[offset] = 0x40 + @as(u8, @intCast(rnd.int(u6) % 0x3E));

    return offset;
}

inline fn randomDigit(rnd: std.rand.Random) u8 {
    return '0' + @as(u8, @intCast(rnd.int(u4) % 10));
}
