const ecs = @import("ecs");
const std = @import("std");
const rl = @import("raylib");
const comp = @import("components/components.zig");
const Debug = @import("components/debug.zig").Debug;
const sd = @import("stardust");

const Settings = struct {
    title: [256:0]u8 = undefined,  // Use fixed buffer for title
    width: i32 = 1500,
    height: i32 = 800,
    fps: i32 = 240
};

var REG: ?ecs.Registry = null;
var SETTINGS: Settings = .{};

pub export fn getRegistry() *ecs.Registry {
    return &REG.?;
}

pub export fn run(
    fps: i32,
    start: *const fn () callconv(.C) void,
    prerender: *const fn (dt: f32, frame_count: u32) callconv(.C) void,
    render: *const fn (dt: f32) callconv(.C) void,
) void {

    if(REG == null) {
        sd.err("Please call init() first" , .{});
        return;
    }

    REG = ecs.Registry.init(std.heap.page_allocator);
    defer REG.?.deinit();

    rl.initWindow(SETTINGS.width, SETTINGS.height, "Game");
    defer rl.closeWindow();

    rl.setTargetFPS(fps);

    var frame_counter: u32 = 0;
    var last_frame_time = rl.getTime();
    var dt: f32 = 0;

    start();

    sd.debug("Starting Game Loop", .{});

    while (!rl.windowShouldClose()) {
        const current_time = rl.getTime();
        dt = @floatCast(current_time - last_frame_time);
        last_frame_time = current_time;
        frame_counter += 1;

        prerender(dt, frame_counter);

        rl.beginDrawing();
        defer rl.endDrawing();

        render(dt);

        rl.clearBackground(.black);
    }
}

pub export fn init(
    title: [*:0]const u8,
    width: i32,
    height: i32,
    fps: i32,
    debug_active: bool
) void {
    Debug.active = debug_active;

    const len = std.mem.len(title);
    const copy_len = @min(len, 255);
    @memcpy(SETTINGS.title[0..copy_len], title[0..copy_len]);
    SETTINGS.title[copy_len] = 0;

    SETTINGS.width = width;
    SETTINGS.height = height;
    SETTINGS.fps = fps;

    REG = ecs.Registry.init(std.heap.page_allocator);

    sd.debug("Initiated ECS registry", .{});
}
