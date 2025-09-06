// Todas las dependencias necesarias
const rl = @import("lib/raylib.zig").rl;
const lib = @import("lib/functions.zig");
const constants = @import("lib/constants.zig");
const ball = @import("lib/ball.zig");
const paddle = @import("lib/paddle.zig");

pub fn main() !void {

    // FPS
    rl.SetTargetFPS(constants.FPS);

    // Bandera para que la ventana generada sea resizable
    rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE);
    rl.InitWindow(constants.initialWidth, constants.initialHeight, "Menudo escándalo niño");
    defer rl.CloseWindow();

    // cargamos textura
    const target = rl.LoadRenderTexture(constants.initialWidth, constants.initialHeight);
    defer rl.UnloadRenderTexture(target);

    // Iniciar bola
    var myBall = ball.Ball.init();
    var numChoques: u32 = 0;

    // Paddle de la máquina y del usuario
    var enemyPaddle = paddle.Paddle.init(40, false);
    var myPaddle = paddle.Paddle.init(750, true);

    // Iniciamos aquí el rectangulo semilla para no tener que declararlo por frame en el bucle
    const sourceRec = rl.Rectangle{
        .x = 0,
        .y = 0,
        .width = @as(f32, @floatFromInt(constants.initialWidth)),
        .height = -@as(f32, @floatFromInt(constants.initialHeight)),
    };

    // Bucle principal del juego
    while (!rl.WindowShouldClose()) {

        // Variables necesarias para la escala
        // no se pueden poner en constantes, no son comptime
        const actualWidth: f32 = @as(f32, @floatFromInt(rl.GetScreenWidth()));
        const actualHeight: f32 = @as(f32, @floatFromInt(rl.GetScreenHeight()));

        // escala para escalar el sourceRec a destRec
        const scale = @min(actualWidth / @as(f32, @floatFromInt(constants.initialWidth)), actualHeight / @as(f32, @floatFromInt(constants.initialHeight)));

        // La bola se actualiza y añadimos los choques con la pared al score
        numChoques = myBall.update(
            &enemyPaddle,
            &myPaddle,
            &numChoques,
            @as(f32, @floatFromInt(constants.initialWidth)),
            @as(f32, @floatFromInt(constants.initialHeight)),
        );

        // actualizar palas
        myPaddle.update(&myBall);
        enemyPaddle.update(&myBall);

        // iniciamos textura donde pintamos todo
        rl.BeginTextureMode(target);
        // limpiamos lo que haya y ponemos fondo negro
        rl.ClearBackground(rl.BLACK);
        // empezamos a pintar todo
        try lib.drawScore(numChoques);
        try myBall.draw();
        myPaddle.draw();
        enemyPaddle.draw();
        // terminamos de pintar en la textura
        rl.EndTextureMode();

        // empezamos a pintar
        rl.BeginDrawing();
        defer rl.EndDrawing();

        // el rectangulo con las proporciones por si el usuario manipula la ventana
        const destRec = rl.Rectangle{
            .x = 0.0,
            .y = 0.0,
            .width = @as(f32, @floatFromInt(constants.initialWidth)) * scale,
            .height = @as(f32, @floatFromInt(constants.initialHeight)) * scale,
        };
        // aquí es donde hacemos el display de la textura
        rl.DrawTexturePro(
            target.texture,
            sourceRec,
            destRec,
            rl.Vector2{ .x = 0, .y = 0 },
            0.0,
            rl.WHITE,
        );
    }
}
