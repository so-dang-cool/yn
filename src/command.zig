const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

const VERSION = "yn 1.0\n";

const USAGE =
    \\USAGE:
    \\    Yn PROMPT
    \\    yN PROMPT
    \\
    \\FLAGS:
    \\    -h, --help    Display help message
    \\    -V, --version Display version
    \\
    \\Presents a user with a yes/no prompt, and reads one line of standard
    \\input. To avoid ambiguity with whitespaces, the prompt must be exactly
    \\one argument.
    \\
    \\If the user response begins with 'y' or 'Y' the program completes with a
    \\successful 0 exit code. If it begins with 'n' or 'N' the program
    \\completes with a failure 1 exit code.
    \\
    \\When the user gives any other input:
    \\* Yn defaults to yes
    \\* yN defaults to no
    \\
;

pub const Response = enum {
    yes,
    no,

    pub fn parse(raw: []const u8, default: Response) Response {
        const left = std.mem.trimLeft(u8, raw, " \t\r\n");

        if (std.mem.startsWith(u8, left, "y") or std.mem.startsWith(u8, left, "Y")) {
            return .yes;
        } else if (std.mem.startsWith(u8, left, "n") or std.mem.startsWith(u8, left, "N")) {
            return .no;
        }
        return default;
    }

    pub fn toExitCode(self: Response) u8 {
        return switch (self) {
            .yes => 0,
            .no => 1,
        };
    }
};

pub fn run(default: Response) !void {
    var args = std.process.args();

    const programPath = args.next().?;
    const program = std.fs.path.basename(programPath);
    const argument = args.next() orelse {
        try stderr.print("ERROR: Expected exactly one input argument for {s}.\n", .{program});
        std.os.exit(1);
    };

    // TODO: Fail if more args presented?

    // Argument is a cry for help.
    if (std.mem.eql(u8, "-h", argument) or std.mem.eql(u8, "--help", argument)) {
        try stdout.print("{s}", .{USAGE});
        std.os.exit(0);
    }

    // Argument wants to know the version.
    if (std.mem.eql(u8, "-V", argument) or std.mem.eql(u8, "--version", argument)) {
        try stdout.print("{s}", .{VERSION});
        std.os.exit(0);
    }

    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    // For now, argument is the prompt.
    // TODO: Split main() into two separate executables.
    try stdout.print("{s} [{s}]: ", .{ argument, program });
    const rawResponse = stdin.readUntilDelimiterOrEofAlloc(alloc.allocator(), '\n', 128) catch |err| {
        const message = switch (err) {
            error.StreamTooLong => "Response was too many characters.",
            else => "Unable to read response.",
        };
        try stderr.print("ERROR: {s}\n", .{message});
        std.os.exit(1);
    } orelse {
        std.os.exit(default.toExitCode());
    };

    const response = Response.parse(rawResponse, default);

    std.os.exit(response.toExitCode());
}
