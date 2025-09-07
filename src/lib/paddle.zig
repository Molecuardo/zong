const rl = @import("raylib.zig").rl;
const ballFile = @import("ball.zig");

pub const Paddle = struct {
    position: rl.Vector2,
    // la velocidad en la pala es solo en el eje y (de ahí que no sea un vector)
    velocity: f32,
    width: c_int,
    height: c_int,
    color: rl.Color,
    isPlayer: bool,

    pub fn init(x: f32, isPlayer: bool) Paddle {
        return Paddle{
            .position = rl.Vector2{
                .x = x,
                .y = 20,
            },
            // velocidad solo en y
            .velocity = 5,
            .width = 30,
            .height = 150,
            .color = rl.WHITE,
            .isPlayer = isPlayer,
        };
    }
    pub fn update(self: *Paddle, ball: *ballFile.Ball) !void {
        if (!self.isPlayer) {
            // la maquina se mueve más lento
            // bola por encima del centro del rectangulo
            if (self.position.y + @as(f32, @floatFromInt(@divTrunc(self.height, 2))) >= ball.position.y) {
                // se mueve para arriba
                self.position.y -= self.velocity * 0.84;
            }
            // bola por debajo del rectangulo
            if (self.position.y + @as(f32, @floatFromInt(@divTrunc(self.height, 2))) <= ball.position.y) {
                // se mueve para abajo
                self.position.y += self.velocity * 0.84;
            }
        } else {
            if (rl.IsKeyDown(rl.KEY_UP)) {
                self.position.y -= self.velocity;
            } else if (rl.IsKeyDown(rl.KEY_DOWN)) {
                self.position.y += self.velocity;
            }
        }
    }
    pub fn draw(self: *const Paddle) void {
        rl.DrawRectangle(
            @as(c_int, @intFromFloat(self.position.x)),
            @as(c_int, @intFromFloat(self.position.y)),
            self.width,
            self.height,
            self.color,
        );
    }
};
