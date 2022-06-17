const std = @import("std");
const c = @cImport(@cInclude("re.h"));
const testing = std.testing;

pub const Match = c.match_t;

pub const Matches = struct {
    matches: []const Match,

    pub fn deinit(self: Matches) void {
        c.re_free_matches(c.matches_t{ .ptr = self.matches.ptr, .len = self.matches.len });
    }
};

pub fn search(regex: []const u8, buf: []const u8) Matches {
    const matches = c.re_search(regex.ptr, regex.len, buf.ptr, buf.len);
    var ret: Matches = undefined;
    ret.matches.ptr = matches.ptr;
    ret.matches.len = matches.len;
    return ret;
}

test "basic add functionality" {
    var matches = search("foo", "foo bar baz");
    defer matches.deinit();
    try std.testing.expectEqual(matches.matches.len, 1);
    try std.testing.expectEqualSlices(Match, matches.matches, &.{.{ .start = 0, .end = 3 }});
}
