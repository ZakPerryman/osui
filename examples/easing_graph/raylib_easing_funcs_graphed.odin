package main

import "core:fmt"
import osui "../../"
import rl "vendor:raylib"

gradient_calc :: proc(start: rl.Color, end: rl.Color, easing_type: osui.Easing_Types, p: f64) -> rl.Color {
    easing_result := osui._apply_easing(easing_type, p)

    if easing_result > 1.0 { return rl.ColorLerp(end, rl.WHITE, f32(clamp(easing_result - 1.0, 0.0, 1.0))) }
    if easing_result < 0.0 { return rl.ColorLerp(start, rl.BLACK, f32(clamp(abs(easing_result), 0.0, 1.0))) }

    return rl.ColorLerp(start, end, f32(easing_result))
}

main :: proc() {
    rl.InitWindow(800, 600, "OSUI Test app")
    defer rl.CloseWindow()

    time : f64 = 0

    columns :: 6
    column_width := 800 / columns
    row_height := 600 / (len(osui.Easing_Types) / columns)

    easing_gradients := [osui.Easing_Types]rl.Image{}
    easing_gradient_textures := [osui.Easing_Types]rl.Texture{}

    grad_start := rl.ORANGE
    grad_end := rl.RED

    for easing in osui.Easing_Types {
        easing_gradients[easing] = rl.GenImageColor(i32(column_width), i32(row_height), rl.WHITE)
        gradient := &easing_gradients[easing] 

        for y in 0..<row_height {
            p := f64(y) / f64(row_height)
            rl.ImageDrawLine(gradient, 0, i32(y), i32(column_width), i32(y), gradient_calc(grad_start, grad_end, easing, p))
        }
    
        easing_gradient_textures[easing] = rl.LoadTextureFromImage(gradient^)
    }

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLANK)
        
        processed_ids : u64 = 0
        for type in osui.Easing_Types {
            x := int(processed_ids) % columns
            y := int(processed_ids) / columns
        
            rl.DrawTexture(easing_gradient_textures[type], i32(x * column_width), i32(y * row_height), rl.WHITE)
            cstr := fmt.caprint(type)
            rl.DrawText(cstr, i32(x * column_width), i32(y * row_height), 12, rl.BLUE)
            delete(cstr)
            processed_ids += 1
        }

        rl.EndDrawing()
    }
}