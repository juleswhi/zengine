const std = @import("std");
const json = std.json;

pub fn readJsonFile(allocator: std.mem.Allocator, file_path: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;

    const buffer = try allocator.alloc(u8, @intCast(file_size));
    errdefer allocator.free(buffer);

    const bytes_read = try file.readAll(buffer);
    if (bytes_read != file_size) {
        return error.UnexpectedEndOfFile;
    }

    return buffer;
}

pub fn writeJsonFile(file_path: []const u8, json_str: []const u8) !void {
    const file = try std.fs.cwd().createFile(file_path, .{});
    defer file.close();
    try file.writeAll(json_str);
}
