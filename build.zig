const std = @import("std");

const CrateResult = struct { name: []const u8, install_path: []const u8, step: *std.build.RunStep };

fn buildCrate(b: *std.build.Builder, mode: std.builtin.Mode, crate_path: []const u8) !*CrateResult {
    var cmd = b.addSystemCommand(&[_][]const u8{"cargo"});
    cmd.cwd = crate_path;
    cmd.addArg("build");

    const mode_dir_name = switch (mode) {
        .ReleaseFast, .ReleaseSafe, .ReleaseSmall => b: {
            cmd.addArg("--release");
            break :b "release";
        },
        else => "debug",
    };

    var res = try b.allocator.create(CrateResult);
    res.* = .{
        .name = std.fs.path.basename(crate_path),
        .step = cmd,
        .install_path = try std.fs.path.join(b.allocator, &.{crate_path, "target", mode_dir_name}),
    };
    return res;
}

fn linkCrate(b: *std.build.Builder, mode: std.builtin.Mode, step: anytype, crate_path: []const u8) !void {
    const crate = try buildCrate(b, mode, crate_path);
    step.step.dependOn(&crate.step.step);
    step.addLibraryPath(crate.install_path);
    step.addIncludePath(crate_path);
    step.linkSystemLibrary(crate.name);
    step.linkLibCpp();
}

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("zig-rust-regex", "src/main.zig");
    lib.setBuildMode(mode);
    linkCrate(b, mode, lib, "re") catch unreachable;
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);
    linkCrate(b, mode, main_tests, "re") catch unreachable;

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
