const std = @import("std");
const testing = std.testing;
const allocator = testing.allocator;

const ChildProcess = std.ChildProcess;

const Yn = "./zig-out/bin/Yn";
const yN = "./zig-out/bin/yN";

test "Yn --version" {
    const invocation = &[_][]const u8{ Yn, "--version" };

    const result = try ChildProcess.exec(.{ .allocator = allocator, .argv = invocation });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try testing.expectEqualStrings("yn 1.0\n", result.stdout);
}

test "yN --version" {
    const invocation = &[_][]const u8{ yN, "--version" };

    const result = try ChildProcess.exec(.{ .allocator = allocator, .argv = invocation });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try testing.expectEqualStrings("yn 1.0\n", result.stdout);
}
