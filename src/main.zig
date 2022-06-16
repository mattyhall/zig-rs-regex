const std = @import("std");
const c = @cImport(@cInclude("re.h"));
const testing = std.testing;

test "basic add functionality" {
    c.hello();
}
