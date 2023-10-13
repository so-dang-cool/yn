const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Compile
    const compile_step = b.step("yn", "Install Yn and yN executables");
    const cross_step = b.step("cross-compile", "Install cross-compiled executables");
    const cross_tar_step = b.step("cross", "Install and archive cross-compiled executables");

    const executables: [2][]const u8 = .{ "Yn", "yN" };
    inline for (executables) |name| {
        const source = std.Build.FileSource.relative("src/" ++ name ++ ".zig");
        const exe = b.addExecutable(.{
            .name = name,
            .root_source_file = source,
            .optimize = optimize,
            .target = target,
        });
        const install_exe = b.addInstallArtifact(exe, .{});
        compile_step.dependOn(&install_exe.step);

        inline for (TRIPLES) |TRIPLE| {
            const cross = b.addExecutable(.{
                .name = name,
                .root_source_file = source,
                .optimize = optimize,
                .target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = TRIPLE }),
            });

            const cross_install = b.addInstallArtifact(cross, .{
                .dest_dir = .{ .override = .{ .custom = "cross/" ++ TRIPLE } },
            });

            cross_step.dependOn(&cross_install.step);
        }
    }

    b.default_step.dependOn(compile_step);

    inline for (TRIPLES) |TRIPLE| {
        const cross_tar = b.addSystemCommand(&.{ "sh", "-c", "tar -czvf yn-" ++ TRIPLE ++ ".tgz Yn* yN*" });
        cross_tar.cwd = "./zig-out/cross/" ++ TRIPLE;

        cross_tar.step.dependOn(cross_step);
        cross_tar_step.dependOn(&cross_tar.step);
    }

    // Tests
    const testSource = std.Build.FileSource.relative("test/test.zig");

    const test_exe = b.addTest(.{
        .root_source_file = testSource,
        .optimize = optimize,
        .target = target,
    });

    const test_run = b.addRunArtifact(test_exe);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(compile_step);
    test_step.dependOn(&test_run.step);

    b.default_step.dependOn(test_step);
}

const TRIPLES = .{
    "aarch64-linux-gnu",
    "aarch64-linux-musleabi",
    "aarch64-macos-none",
    "arm-linux-musleabi",
    "arm-linux-musleabihf",
    "mips-linux-gnu",
    "mips-linux-musl",
    "mips64-linux-gnuabi64",
    "mips64-linux-musl",
    "mips64el-linux-gnuabi64",
    "mips64el-linux-musl",
    "mipsel-linux-gnu",
    "mipsel-linux-musl",
    "powerpc-linux-gnu",
    "powerpc-linux-musl",
    "powerpc64le-linux-gnu",
    "powerpc64le-linux-musl",
    "riscv64-linux-gnu",
    "riscv64-linux-musl",
    "wasm32-wasi-musl",
    "x86_64-linux-gnu",
    "x86_64-linux-musl",
    "x86_64-macos-none",
    "x86-linux-gnu",
    "x86-linux-musl",
};
