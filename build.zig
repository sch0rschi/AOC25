const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "AOC25",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.linkLibC();
    exe.linkSystemLibrary("pcre2-8");

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const debug_step = b.step("debug", "Run with debug optimization");
    const debug_exe = b.addExecutable(.{
        .name = "AOC25-debug",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = .Debug,
        }),
    });
    debug_exe.linkLibC();
    debug_exe.linkSystemLibrary("pcre2-8");
    b.installArtifact(debug_exe);

    const debug_run = b.addRunArtifact(debug_exe);
    debug_run.step.dependOn(b.getInstallStep());
    debug_step.dependOn(&debug_run.step);

    if (b.args) |args| {
        debug_run.addArgs(args);
    }
}
