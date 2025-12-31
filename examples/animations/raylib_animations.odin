package main

import "core:math"
import "core:fmt"

import osui "../../"
import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(800, 600, "OSUI Test app")
    defer rl.CloseWindow()

    columns :: 6
    column_width := 800 / columns
    row_height := 600 / (len(osui.Easing_Types) / columns)

    time : f64 = 0.0
    TIME_SCALE :: 10.0

    animations := osui.Animation_List(len(osui.Easing_Types)){}
    processed_ids : u64 = 0
    for easing in osui.Easing_Types {
        osui.start(&animations, processed_ids, 0.0, TIME_SCALE, easing)
        processed_ids += 1
    }

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLANK)
        
        time += f64(rl.GetFrameTime())
        osui.update_all(&animations, f64(rl.GetFrameTime()))

        processed_ids : u64 = 0
        for type in osui.Easing_Types {
            x := (int(processed_ids) % columns) * column_width
            y := ((int(processed_ids) / columns) + 1) * row_height
        
            y_offset := osui.get(&animations, processed_ids, f64(row_height))
            x_offset := f64(column_width) * (time / TIME_SCALE)

            rl.DrawRectangleLines(i32(x), i32(y), i32(column_width), -i32(row_height), rl.WHITE)
            rl.DrawCircle(i32(f64(x) + x_offset), i32(f64(y) - y_offset), 8, rl.GREEN)

            cstr := fmt.caprint(type)
            rl.DrawText(cstr, i32(x), i32(y - row_height), 12, rl.BLUE)
            delete(cstr)

            processed_ids += 1
        }

        // Debug red circle, linear to time
        // rl.DrawCircle(0 + i32(f64(column_width) * time), i32(f64(row_height) - f64(row_height) * time), 8, rl.RED)

        if(time >= TIME_SCALE) {
            time = 0.0

            processed_ids : u64 = 0
            for easing in osui.Easing_Types {
                osui.start(&animations, processed_ids, 0.0, TIME_SCALE, easing)
                processed_ids += 1
            }
        }

        rl.EndDrawing()
    }
}