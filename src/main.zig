// Todas las dependencias necesarias
const rl = @import("lib/raylib.zig").rl;
const lib = @import("lib/functions.zig");
const constants = @import("lib/constants.zig");
const ball = @import("lib/ball.zig");
const paddle = @import("lib/paddle.zig");

pub const screenState = enum(u8) {
    gameplay,
    endingWin,
    endingLose,
};

pub fn main() !void {
    //enum para poner gameover cuando la bola toque uno de los bordes horizontales
    var currentScreen: screenState = .gameplay;

    // FPS
    rl.SetTargetFPS(constants.FPS);

    rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE);
    rl.InitWindow(constants.initialWidth, constants.initialHeight, "Zigma balls");
    // Bandera para que la ventana generada sea resizable
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

        const destRec = rl.Rectangle{
            .x = 0.0,
            .y = 0.0,
            .width = @as(f32, @floatFromInt(constants.initialWidth)) * scale,
            .height = @as(f32, @floatFromInt(constants.initialHeight)) * scale,
        };

        switch (currentScreen) {
            .gameplay => {
                // La bola, los choques y el estado del juego se actualizan (mediante punteros)
                try myBall.update(
                    &enemyPaddle,
                    &myPaddle,
                    &numChoques,
                    @as(f32, @floatFromInt(constants.initialWidth)),
                    @as(f32, @floatFromInt(constants.initialHeight)),
                    &currentScreen,
                );

                // actualizar palas
                try myPaddle.update(&myBall);
                try enemyPaddle.update(&myBall);

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
                // aquí es donde hacemos el display de la textura
                rl.DrawTexturePro(
                    target.texture,
                    sourceRec,
                    destRec,
                    rl.Vector2{
                        .x = 0,
                        .y = 0,
                    },
                    0.0,
                    rl.WHITE,
                );
            },
            .endingWin => {
                if (rl.IsKeyPressed(rl.KEY_ENTER)) {
                    myBall = ball.Ball.init();
                    currentScreen = .gameplay;
                }
                // iniciamos textura donde pintamos todo
                rl.BeginTextureMode(target);
                // limpiamos lo que haya y ponemos fondo negro
                rl.ClearBackground(rl.BLACK);
                // empezamos a pintar todo
                rl.DrawText(
                    "Has ganado!",
                    150,
                    100,
                    60,
                    rl.WHITE,
                );
                rl.DrawText(
                    "Presiona ENTER para reiniciar",
                    150,
                    180,
                    20,
                    rl.WHITE,
                );
                rl.EndTextureMode();
                rl.BeginDrawing();
                defer rl.EndDrawing();
                rl.DrawTexturePro(
                    target.texture,
                    sourceRec,
                    destRec,
                    rl.Vector2{
                        .x = 0,
                        .y = 0,
                    },
                    0.0,
                    rl.WHITE,
                );
            },
            .endingLose => {
                if (rl.IsKeyPressed(rl.KEY_ENTER)) {
                    myBall = ball.Ball.init();
                    currentScreen = .gameplay;
                }
                // iniciamos textura donde pintamos todo
                rl.BeginTextureMode(target);
                // limpiamos lo que haya y ponemos fondo negro
                rl.ClearBackground(rl.BLACK);
                // empezamos a pintar todo
                rl.DrawText("Has Perdido!", 150, 100, 60, rl.WHITE);
                rl.DrawText("Presiona ENTER para reiniciar", 150, 180, 20, rl.WHITE);
                rl.EndTextureMode();
                rl.BeginDrawing();
                defer rl.EndDrawing();
                rl.DrawTexturePro(
                    target.texture,
                    sourceRec,
                    destRec,
                    rl.Vector2{
                        .x = 0,
                        .y = 0,
                    },
                    0.0,
                    rl.WHITE,
                );
            },
        }
    }
}
