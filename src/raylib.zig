const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});
const Grid = @import("game.zig").Grid;

const COLS = 80;
const ROWS = 50;
const CELL = 12;
const FPS = 10;

pub fn main() !void {
    const seed: u64 = @bitCast(std.time.milliTimestamp());
    var prng = std.Random.DefaultPrng.init(seed);
    var grid = Grid(COLS, ROWS).initRandom(prng.random());

    rl.InitWindow(COLS * CELL, ROWS * CELL + 28, "Conway's Game of Life");
    rl.SetTargetFPS(FPS);
    defer rl.CloseWindow();

    var paused = false;
    var gen: u64 = 0;

    while (!rl.WindowShouldClose()) {
        // Controls
        if (rl.IsKeyPressed(rl.KEY_SPACE)) paused = !paused;
        if (rl.IsKeyPressed(rl.KEY_R)) {
            const new_seed: u64 = @bitCast(std.time.milliTimestamp());
            var new_prng = std.Random.DefaultPrng.init(new_seed);
            grid = Grid(COLS, ROWS).initRandom(new_prng.random());
            gen = 0;
        }
        if (rl.IsKeyPressed(rl.KEY_C)) {
            grid = Grid(COLS, ROWS).initEmpty();
            gen = 0;
        }

        // Draw with left mouse button
        if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)) {
            const mx = rl.GetMouseX();
            const my = rl.GetMouseY();
            if (mx >= 0 and my >= 0) {
                const cx: usize = @intCast(@divTrunc(mx, CELL));
                const cy: usize = @intCast(@divTrunc(my, CELL));
                if (cx < COLS and cy < ROWS) grid.cells[cy][cx] = true;
            }
        }
        // Erase with right mouse button
        if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT)) {
            const mx = rl.GetMouseX();
            const my = rl.GetMouseY();
            if (mx >= 0 and my >= 0) {
                const cx: usize = @intCast(@divTrunc(mx, CELL));
                const cy: usize = @intCast(@divTrunc(my, CELL));
                if (cx < COLS and cy < ROWS) grid.cells[cy][cx] = false;
            }
        }

        if (!paused) {
            grid.step();
            gen += 1;
        }

        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);

        for (0..ROWS) |y| {
            for (0..COLS) |x| {
                if (grid.cells[y][x]) {
                    rl.DrawRectangle(
                        @intCast(x * CELL),
                        @intCast(y * CELL),
                        CELL - 1,
                        CELL - 1,
                        rl.GREEN,
                    );
                }
            }
        }

        // HUD
        var buf: [64]u8 = undefined;
        const label = if (paused) "PAUSED" else "RUNNING";
        const text = std.fmt.bufPrintZ(&buf, "Gen {d}  [{s}]  SPACE:pause R:reset C:clear", .{ gen, label }) catch "?";
        rl.DrawText(text, 8, ROWS * CELL + 4, 16, rl.RAYWHITE);

        rl.EndDrawing();
    }
}
