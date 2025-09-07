const rl = @import("raylib.zig").rl;
const paddleFile = @import("paddle.zig");
const mainFile = @import("../main.zig");

pub const Ball = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    radius: f32,
    color: rl.Color,

    //iniciamos la pelota
    pub fn init() Ball {
        return Ball{
            .position = rl.Vector2{
                .x = 350,
                .y = 100,
            },
            .velocity = rl.Vector2{
                .x = 7,
                .y = 8,
            },
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
        choques: *u32, // como es un puntero, deberíamos poder modificar su valor sin devolver nada
        width: f32,
        height: f32,
        state: *mainFile.screenState, // lo mismo aquí
    ) !void {
        // update
        self.position.x += self.velocity.x;
        self.position.y += self.velocity.y;
        // choca con bordes horizontales:
        // borde horizontal derecho (pierde el jugador)
        if (self.position.x + self.radius >= width) {
            state.* = .endingLose;
        }
        // borde horizontal izquierdo (pierde la máquina)
        if (self.position.x <= self.radius) {
            state.* = .endingWin;
        }
        // choca con borde vertical
        else if (self.position.y + self.radius >= height or self.position.y <= self.radius) {
            self.velocity.y *= -1;
            //            return choques.*;
        }
        // colisiones con la cara horizontal de la pala de la máquina
        if (isColliding(self, paddleMach) and self.position.x <= paddleMach.position.x + @as(f32, @floatFromInt(paddleMach.width))) {
            self.velocity.y *= -1;
            choques.* += 1;
            //           return choques.*;
        }
        // colisiones con la cara vertical de la pala de la máquina
        if (isColliding(self, paddleMach)) {
            self.velocity.x *= -1;
            choques.* += 1;
            //          return choques.*;
        }
        // colisiones con la cara horizontal de la pala del usuario
        if (isColliding(self, paddleUser) and self.position.x >= paddleUser.position.x - @as(f32, @floatFromInt(paddleUser.width))) {
            self.velocity.y *= -1;
            choques.* += 1;
            //         return choques.*;
        }
        // colisiones con la cara vertical de la pala del usuario
        if (isColliding(self, paddleUser)) {
            self.velocity.x *= -1;
            choques.* += 1;
            //        return choques.*;
        }
        // si no ha chocado, no le añadimos nada
        else {
            //       return choques.*;
        }
    }

    pub fn draw(self: *const Ball) !void {
        rl.DrawCircle(@as(c_int, @intFromFloat(self.position.x)), @as(c_int, @intFromFloat(self.position.y)), self.radius, self.color);
    }
};
