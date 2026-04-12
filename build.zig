const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Terminal interface
    const exe = b.addExecutable(.{
        .name = "zigway-game-life",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the terminal interface");
    run_step.dependOn(&run_exe.step);

    // Raylib GUI interface
    const raylib_exe = b.addExecutable(.{
        .name = "rayzigway-game-life",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/raylib.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Use bundled raylib from ./raylib-5.5_macos/
    raylib_exe.addIncludePath(b.path("raylib-5.5_macos/include"));
    raylib_exe.addLibraryPath(b.path("raylib-5.5_macos/lib"));
    raylib_exe.linkSystemLibrary("raylib");
    raylib_exe.linkLibC();

    // macOS system frameworks required by raylib
    raylib_exe.linkFramework("Cocoa");
    raylib_exe.linkFramework("IOKit");
    raylib_exe.linkFramework("CoreVideo");
    raylib_exe.linkFramework("OpenGL");

    b.installArtifact(raylib_exe);

    const run_raylib = b.addRunArtifact(raylib_exe);
    const run_raylib_step = b.step("run-raylib", "Run the raylib GUI");
    run_raylib_step.dependOn(&run_raylib.step);
}
