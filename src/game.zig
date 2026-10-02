const std = @import("std");

pub fn Grid(comptime W: usize, comptime H: usize) type {
    return struct {
        cells: [H][W]bool,

        const Self = @This();

        pub fn initRandom(rng: std.Random) Self {
            var self = Self{ .cells = @splat(@splat(false)) };
            for (0..H) |y| {
                for (0..W) |x| {
                    self.cells[y][x] = rng.boolean();
                }
            }
            return self;
        }

        pub fn initEmpty() Self {
            return .{ .cells = @splat(@splat(false)) };
        }

        pub fn toggle(self: *Self, x: usize, y: usize) void {
            if (x < W and y < H) self.cells[y][x] = !self.cells[y][x];
        }

        pub fn countNeighbors(self: *const Self, x: usize, y: usize) u8 {
            var count: u8 = 0;
            const ix: isize = @intCast(x);
            const iy: isize = @intCast(y);
            for ([_]isize{ -1, 0, 1 }) |dy| {
                for ([_]isize{ -1, 0, 1 }) |dx| {
                    if (dx == 0 and dy == 0) continue;
                    const nx = ix + dx;
                    const ny = iy + dy;
                    if (nx < 0 or ny < 0 or nx >= W or ny >= H) continue;
                    if (self.cells[@intCast(ny)][@intCast(nx)]) count += 1;
                }
            }
            return count;
        }

        pub fn step(self: *Self) void {
            var next: Self = self.*;
            for (0..H) |y| {
                for (0..W) |x| {
                    const n = self.countNeighbors(x, y);
                    // if a living cell has 2 or 3 neighbors -> stay alive; else die
                    // if an empty cell has 3 neighbors -> become alive; else stay empty
                    next.cells[y][x] = if (self.cells[y][x]) n == 2 or n == 3 else n == 3;
                }
            }
            self.* = next;
        }
    };
}
