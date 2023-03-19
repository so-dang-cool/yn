const command = @import("command.zig");
const Response = command.Response;

pub fn main() !void {
    try command.run(Response.yes);
}
