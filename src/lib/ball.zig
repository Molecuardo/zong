const rl = @import("raylib.zig").rl;
const paddleFile = @import("paddle.zig");

pub const Ball = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    radius: f32,
    color: rl.Color,

    //iniciamos la pelota
    pub fn init() Ball {
        return Ball{
            .position = rl.Vector2{ .x = 350, .y = 100 },
            .velocity = rl.Vector2{ .x = 4, .y = 4 },
            .radius = 10.0,
            .color = rl.WHITE,
        };
    }

    // dependencia para update()
    pub fn isColliding(self: *Ball, paddle: *paddleFile.Paddle) bool {
        const ballCenter = self.position;
        const recPaddle = rl.Rectangle{
            .x = paddle.position.x,
            .y = paddle.position.y,
            .width = @as(f32, @floatFromInt(paddle.width)),
            .height = @as(f32, @floatFromInt(paddle.height)),
        };
        return rl.CheckCollisionCircleRec(ballCenter, self.radius, recPaddle);
    }
    // Función para el movimiento y rebote
    // de la pelota
    pub fn update(
        self: *Ball,
        paddleMach: *paddleFile.Paddle,
        paddleUser: *paddleFile.Paddle,
        choques: *u32,
        width: f32,
        height: f32,
    ) u32 {
        // update
        self.position.x += self.velocity.x;
        self.position.y += self.velocity.y;
        // choca con bordes horizontales
        if (self.position.x + self.radius >= width or self.position.x <= self.radius) {
            // NOTE: aqui el juego debería acabar, pero de momento, que rebote
            self.velocity.x *= -1;
            return choques.*;
        }
        // choca con borde vertical
        else if (self.position.y + self.radius >= height or self.position.y <= self.radius) {
            self.velocity.y *= -1;
            choques.* += 1;
            return choques.*;
        }
        // colisiones con la pala de la máquina
        if (isColliding(self, paddleMach)) {
            self.velocity.x *= -1;
            choques.* += 1;
            return choques.*;
        }
        if (isColliding(self, paddleUser)) {
            self.velocity.x *= -1;
            choques.* += 1;
            return choques.*;
        }
        // si no ha chocado, no le añadimos nada
        else {
            return choques.*;
        }
    }

    pub fn draw(self: *const Ball) !void {
        rl.DrawCircle(@as(c_int, @intFromFloat(self.position.x)), @as(c_int, @intFromFloat(self.position.y)), self.radius, self.color);
    }
};
