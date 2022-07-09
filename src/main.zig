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

pub const Regex = struct {
    re: *c.re_t,

    pub fn init(regex: []const u8) error{could_not_compile}!Regex {
        var r = c.re_compile(regex.ptr, regex.len);
        if (r == null) return error.could_not_compile;
        return Regex{ .re = r.? };
    }

    pub fn search(self: *Regex, buf: []const u8) Matches {
        const matches = c.re_search(self.re, buf.ptr, buf.len);
        var ret: Matches = undefined;
        ret.matches.ptr = matches.ptr;
        ret.matches.len = matches.len;
        return ret;
    }

    pub fn deinit(self: *Regex) void {
        c.re_free(self.re);
    }
};

test "basic add functionality" {
    var re = try Regex.init("foo");
    defer re.deinit();

    var matches = re.search("foo bar baz");
    defer matches.deinit();

    try std.testing.expectEqual(matches.matches.len, 1);
    try std.testing.expectEqualSlices(Match, matches.matches, &.{.{ .start = 0, .end = 3 }});
}
