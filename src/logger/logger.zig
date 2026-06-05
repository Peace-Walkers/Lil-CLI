const std = @import("std");

const LIL_COLOR = "\x1b[38;2;255;121;112m";
const BOLD = "\x1b[1m";
const RESET = "\x1b[0m";
const DIM = "\x1b[90m";
const RED = "\x1b[31m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const BLUE = "\x1b[34m";
const CYAN = "\x1b[36m";

pub var verbose: bool = false;

var depth: usize = 0;
var step_stack: [16][]const u8 = undefined;

var ephemeral_lines: usize = 0;
var detail_buf: [512]u8 = undefined;
var detail_len: usize = 0;

const print = std.debug.print;

fn clearEphemeral() void {
    if (verbose or ephemeral_lines == 0) return;
    var i: usize = 0;
    while (i < ephemeral_lines) : (i += 1) {
        print("\x1b[1F\x1b[2K", .{});
    }
    ephemeral_lines = 0;
}

fn drawEphemeral() void {
    if (verbose) return;

    var i: usize = 0;
    while (i < depth) : (i += 1) {
        print("  ", .{});
        var indent: usize = 0;
        while (indent < i) : (indent += 1) print("  ", .{});
        print("{s}➔{s} {s}\n", .{ DIM, RESET, step_stack[i] });
        ephemeral_lines += 1;
    }

    if (detail_len > 0) {
        print("  ", .{});
        var indent: usize = 0;
        while (indent < depth) : (indent += 1) print("  ", .{});
        print("{s}{s}{s}\n", .{ DIM, detail_buf[0..detail_len], RESET });
        ephemeral_lines += 1;
    }
}

pub fn beginStep(name: []const u8) void {
    clearEphemeral();
    detail_len = 0;

    if (depth < step_stack.len) step_stack[depth] = name;

    if (verbose) {
        print("  ", .{});
        var indent: usize = 0;
        while (indent < depth) : (indent += 1) print("  ", .{});
        print("{s}➔{s} {s}\n", .{ DIM, RESET, name });
    }

    depth += 1;
    drawEphemeral();
}

pub fn endStep() void {
    clearEphemeral();
    detail_len = 0;
    if (depth > 0) depth -= 1;
    drawEphemeral();
}

pub fn trace(comptime format: []const u8, args: anytype) void {
    clearEphemeral();

    const msg = std.fmt.bufPrint(&detail_buf, format, args) catch return;
    detail_len = msg.len;

    if (verbose) {
        print("  ", .{});
        var indent: usize = 0;
        while (indent < depth) : (indent += 1) print("  ", .{});
        print("{s}{s}{s}\n", .{ DIM, msg, RESET });
        detail_len = 0;
    }

    drawEphemeral();
}

pub fn printLogo() void {
    std.debug.print("{s}  ■ ■\n  ■  {s}", .{ LIL_COLOR, RESET });
}

pub fn header(comptime format: []const u8, args: anytype) void {
    printLogo();
    std.debug.print("{s}", .{BOLD});
    std.debug.print(format, args);
    std.debug.print("{s}\n\n", .{RESET});
}

pub fn step(comptime format: []const u8, args: anytype) void {
    clearEphemeral();
    std.debug.print("  {s}{s}➔{s} {s}", .{ CYAN, BOLD, RESET, DIM });
    std.debug.print(format, args);
    std.debug.print("{s}\n", .{RESET});
    drawEphemeral();
}

pub fn info(comptime format: []const u8, args: anytype) void {
    clearEphemeral();
    std.debug.print("  {s}{s}ℹ{s} ", .{ BLUE, BOLD, RESET });
    std.debug.print(format ++ "\n", args);
    drawEphemeral();
}

pub fn success(comptime format: []const u8, args: anytype) void {
    clearEphemeral();
    std.debug.print("  {s}{s}✔{s} ", .{ GREEN, BOLD, RESET });
    std.debug.print(format ++ "\n", args);
    drawEphemeral();
}

pub fn warning(comptime format: []const u8, args: anytype) void {
    clearEphemeral();
    std.debug.print("  {s}{s}⚠ Warning:{s} ", .{ YELLOW, BOLD, RESET });
    std.debug.print(format ++ "\n", args);
    drawEphemeral();
}

pub fn err(comptime format: []const u8, args: anytype) void {
    clearEphemeral();
    std.debug.print("  {s}{s}✖ Error:{s} ", .{ RED, BOLD, RESET });
    std.debug.print(format ++ "\n", args);
    drawEphemeral();
}
