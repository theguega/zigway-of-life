const std = @import("std");
const Grid = @import("game.zig").Grid;

const W = 60;
const H = 30;
const TICK_MS = 100;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const seed: u64 = @bitCast(std.Io.Timestamp.now(io, .real).toMilliseconds());
    var prng = std.Random.DefaultPrng.init(seed);
    var grid = Grid(W, H).initRandom(prng.random());

    var buf: [16384]u8 = undefined;
    var fw = std.Io.File.stdout().writerStreaming(io, &buf);
    const w = &fw.interface;

    var gen: u64 = 0;

    try w.writeAll("\x1b[?25l"); // hide cursor
    try w.writeAll("\x1b[2J"); // clear screen once
    defer {
        w.writeAll("\x1b[?25h") catch {}; // restore cursor
        w.flush() catch {};
    }

    while (true) {
        try w.writeAll("\x1b[H"); // move cursor to top-left

        for (grid.cells) |row| {
            for (row) |cell| {
                try w.writeAll(if (cell) "█" else " ");
            }
            try w.writeByte('\n');
        }

        try w.print(" gen {d:<10}\r", .{gen});
        try w.flush();

        grid.step();
        gen += 1;
        try io.sleep(.fromMilliseconds(TICK_MS), .awake);
    }
}
