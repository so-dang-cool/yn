const yn = @import("yn.zig");
const Response = yn.Response;

pub fn main() !void {
    try yn.run(Response.yes);
}
