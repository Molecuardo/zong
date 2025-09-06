const rl = @import("raylib.zig").rl;

pub fn drawScore(score: u32) !void {
    const text = rl.TextFormat("puntuación: %d", @as(i32, @intCast(score)));
    rl.DrawText(text, 350, 0, 20, rl.WHITE);
}
