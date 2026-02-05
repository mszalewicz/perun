package main

import clay "../../external/clay-odin"
import "../crypto_helpers"
import "core:crypto"
import "core:encoding/hex"
import "core:fmt"
import "core:os"
import rl "vendor:raylib"


windowWidth: i32 = 1024
windowHeight: i32 = 768


main :: proc() {

	// Init Clay
	error_handler :: proc "c" (errorData: clay.ErrorData) {
		// Do something with the error data.
	}

	min_memory_size := clay.MinMemorySize()
	memory := make([^]u8, min_memory_size)
	arena: clay.Arena = clay.CreateArenaWithCapacityAndMemory(uint(min_memory_size), memory)
	clay.Initialize(
		arena,
		{cast(f32)windowWidth, cast(f32)windowHeight},
		{handler = error_handler},
	)

	// Example measure text function
	measure_text :: proc "c" (
		text: clay.StringSlice,
		config: ^clay.TextElementConfig,
		userData: rawptr,
	) -> clay.Dimensions {
		// clay.TextElementConfig contains members such as fontId, fontSize, letterSpacing, etc..
		// Note: clay.String->chars is not guaranteed to be null terminated
		return {width = f32(text.length * i32(config.fontSize)), height = f32(config.fontSize)}
	}

	// Tell clay how to measure text
	clay.SetMeasureTextFunction(measure_text, nil)

	// Update internal pointer position for handling mouseover / click / touch events
	// clay.SetPointerState({mouse_pos_x, mouse_pos_y}, is_mouse_down)


	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.InitWindow(windowWidth, windowHeight, "Raylib Odin Example")
	rl.SetTargetFPS(rl.GetMonitorRefreshRate(0))

	debugModeEnabled: bool = false

	for !rl.WindowShouldClose() {
		defer free_all(context.temp_allocator)

		window_width := rl.GetScreenWidth()
		window_height := rl.GetScreenHeight()

		// 2. Begin Layout
		clay.SetLayoutDimensions({f32(window_width), f32(window_height)})

		clay.BeginLayout()

		// 3. Define the UI
		// Root container: Fills the screen and centers its children

		if clay.UI(clay.ID("Root"))(
		{
			// Sizing and alignment live inside the 'layout' field
			layout = {
				sizing = {width = clay.SizingGrow({}), height = clay.SizingGrow({})},
				childAlignment = {x = .Center, y = .Center},
			},
		},
		) {
			clay.UI(clay.ID("Rectangle"))(
			{
				layout = {
					sizing = {width = clay.SizingPercent(0.5), height = clay.SizingPercent(0.5)},
				},
				backgroundColor = {200, 100, 100, 255},
				cornerRadius = {topLeft = 16, topRight = 16, bottomLeft = 16, bottomRight = 16},
			},
			)
		}

		render_commands := clay.EndLayout()

		// 4. Render (Minimal Raylib Loop)
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		//
		// In a real app, you would iterate through render_commands
		// and call rl.DrawRectangleRec based on the clay command data.
		for i in 0 ..< render_commands.length {
			cmd := clay.RenderCommandArray_Get(&render_commands, i)

			if cmd.commandType == .Rectangle {
				config := cmd.renderData.rectangle
				rect := cmd.boundingBox

				color := rl.Color {
					u8(config.backgroundColor.r),
					u8(config.backgroundColor.g),
					u8(config.backgroundColor.b),
					u8(config.backgroundColor.a),
				}

				// Convert pixel radius to Raylib's 0.0 - 1.0 'roundness'
				// Raylib roundness is relative to the short side of the rectangle
				radius := config.cornerRadius.topLeft
				roundness: f32 = 0.0
				if rect.width > 0 && rect.height > 0 {
					// Clay radius is pixels, Raylib is 0..1 relative to the smallest dimension
					roundness =
						(radius * 2.0) / (rect.width if rect.width < rect.height else rect.height)
				}

				rl.DrawRectangleRounded(
					{rect.x, rect.y, rect.width, rect.height},
					roundness,
					24, // segments (higher = smoother)
					color,
				)
			}
		}

		rl.EndDrawing()
	}

	// ---------------------- CRYPTO ----------------------

	// salt := crypto_helpers.generate_salt()

	// fmt.printf("salt: %s\n", salt)

	// hash, err := crypto_helpers.hash_string("test", salt)

	// if err != .None {
	// 	fmt.println(err)
	// 	os.exit(1)
	// }

	// fmt.printf("hash: %s\n", hex.encode(hash[:]))
}
