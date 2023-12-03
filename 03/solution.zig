// assumes newlines are \n and input has a trailing newline
const std = @import("std");
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    // comment desired line
    std.debug.print("{}\n", .{try part1()});
    // std.debug.print("{}\n", .{try part2()});
}

fn check_symbolic(input: []u8, start: usize, end: usize) bool {
    for (start..end) |i| {
        const c = input[i];
        if (!('0' <= c and c <= '9') and c != '.') {
            return true;
        }
    }
    return false;
}

fn check_gears(input: []u8, start: usize, end: usize, num: u64, adjacents: *[]u8, powers: *[]u64) void {
    for (start..end) |i| {
        const c = input[i];
        if (c == '*') {
            adjacents.*[i] += 1;
            if (adjacents.*[i] <= 2) {
                powers.*[i] *= num;
            }
        }
    }
}

fn part1() !u64 {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(alloc.deinit() == .ok);
    const gpa = alloc.allocator();

    var file = try std.fs.cwd().openFile("input", .{});
    var input = try file.readToEndAlloc(gpa, 65536);
    defer gpa.free(input);

    var width: usize = 0;
    for (0..input.len) |i| {
        if (input[i] == '\n') {
            width = i + 1;
            break;
        }
    }

    const height = input.len / width;

    var digits: usize = 0;
    var in_number = false;
    var sum: u64 = 0;

    for (0..height) |y| {
        for (0..width) |x| {
            const i = y * width + x;
            const c = input[i];
            if ('0' <= c and c <= '9') {
                if (in_number) {
                    digits += 1;
                } else {
                    digits = 1;
                    in_number = true;
                }
            } else {
                if (in_number) {
                    in_number = false;
                    const start = i - digits;
                    const end = i;
                    const slice = input[start..end];
                    const parsed = try parseInt(u64, slice, 10);

                    var symbolic = false;
                    if (y > 0) {
                        var slice_start = start - width;
                        var slice_end = end - width;
                        if (x - digits > 0) {
                            slice_start -= 1;
                        }
                        if (x < width - 1) {
                            slice_end += 1;
                        }
                        symbolic = symbolic or check_symbolic(input, slice_start, slice_end);
                    }
                    if (y < height - 1) {
                        var slice_start = start + width;
                        var slice_end = end + width;
                        if (x - digits > 0) {
                            slice_start -= 1;
                        }
                        if (x < width - 1) {
                            slice_end += 1;
                        }
                        symbolic = symbolic or check_symbolic(input, slice_start, slice_end);
                    }
                    if (x - digits > 0) {
                        symbolic = symbolic or check_symbolic(input, start - 1, start);
                    }
                    if (x < width - 1) {
                        symbolic = symbolic or check_symbolic(input, end, end + 1);
                    }

                    if (symbolic) {
                        sum += parsed;
                    }
                }
            }
        }
    }
    return sum;
}

fn part2() !u64 {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(alloc.deinit() == .ok);
    const gpa = alloc.allocator();

    var file = try std.fs.cwd().openFile("input", .{});
    var input = try file.readToEndAlloc(gpa, 65536);
    defer gpa.free(input);

    var width: usize = 0;
    for (0..input.len) |i| {
        if (input[i] == '\n') {
            width = i + 1;
            break;
        }
    }

    const height = input.len / width;

    var gear_adjacents = try gpa.alloc(u8, input.len);
    defer gpa.free(gear_adjacents);
    for (0..gear_adjacents.len) |i| {
        gear_adjacents[i] = 0;
    }

    var gear_powers = try gpa.alloc(u64, input.len);
    defer gpa.free(gear_powers);
    for (0..gear_powers.len) |i| {
        gear_powers[i] = 0;
    }

    for (0..height) |y| {
        for (0..width) |x| {
            const i = y * width + x;
            const c = input[i];
            if (c == '*') {
                gear_powers[i] = 1;
            }
        }
    }

    var digits: usize = 0;
    var in_number = false;
    for (0..height) |y| {
        for (0..width) |x| {
            const i = y * width + x;
            const c = input[i];
            if ('0' <= c and c <= '9') {
                if (in_number) {
                    digits += 1;
                } else {
                    digits = 1;
                    in_number = true;
                }
            } else {
                if (in_number) {
                    in_number = false;
                    const start = i - digits;
                    const end = i;
                    const slice = input[start..end];
                    const parsed = try parseInt(u64, slice, 10);

                    if (y > 0) {
                        var slice_start = start - width;
                        var slice_end = end - width;
                        if (x - digits > 0) {
                            slice_start -= 1;
                        }
                        if (x < width - 1) {
                            slice_end += 1;
                        }
                        check_gears(input, slice_start, slice_end, parsed, &gear_adjacents, &gear_powers);
                    }
                    if (y < height - 1) {
                        var slice_start = start + width;
                        var slice_end = end + width;
                        if (x - digits > 0) {
                            slice_start -= 1;
                        }
                        if (x < width - 1) {
                            slice_end += 1;
                        }
                        check_gears(input, slice_start, slice_end, parsed, &gear_adjacents, &gear_powers);
                    }
                    if (x - digits > 0) {
                        check_gears(input, start - 1, start, parsed, &gear_adjacents, &gear_powers);
                    }
                    if (x < width - 1) {
                        check_gears(input, end, end + 1, parsed, &gear_adjacents, &gear_powers);
                    }
                }
            }
        }
    }

    var sum: u64 = 0;
    for (gear_powers, 0..) |power, i| {
        if (gear_adjacents[i] == 2) {
            sum += power;
        }
    }
    return sum;
}
