const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const shared = b.option(bool, "shared", "Build as shared library") orelse false;

    const main_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = if (shared)
        b.addSharedLibrary(.{
            .name = "zengine",
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        })
    else
        b.addStaticLibrary(.{
            .name = "zengine",
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        });

    const raylib_options = b.addOptions();
    raylib_options.addOption([]const u8, "linux_display_backend", "x11");

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const ecs_dep = b.dependency("ecs", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");
    const ecs = ecs_dep.module("zig-ecs");

    lib.linkLibrary(raylib_artifact);
    lib.root_module.addImport("raylib", raylib);
    lib.root_module.addImport("ecs", ecs);
    lib.root_module.addImport("raygui", raygui);
    lib.root_module.addOptions("raylib_options", raylib_options);

    b.installArtifact(lib);

    const lib_tests = b.addTest(.{
        .root_module = main_mod,
    });

    const run_lib_tests = b.addRunArtifact(lib_tests);
    run_lib_tests.addFileInput(b.path("src/tests.zig"));

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_tests.step);
}
