const std = @import("std");

const ByteCode = union(enum) { load_number: i64, add: void, print: void, eof: void };

const VM = struct {
    const Self = @This();
    const stack_size = 1024;
    const byte_code_size = 1024;

    byte_code: [byte_code_size]ByteCode,
    number_of_byte_code_instructions: u64,
    stack: [stack_size]i64,
    stack_pointer: u64,
    instruction_pointer: u64,

    fn new() Self {
        return Self{ 
            .byte_code = [_]ByteCode{ByteCode.eof} ** byte_code_size, 
            .number_of_byte_code_instructions = 0,
            .stack = [_]i64{0} ** stack_size,
            .stack_pointer = 0,
            .instruction_pointer = 0,
        };
    }

    fn add_byte(self: *Self, byte: ByteCode) void {
        self.byte_code[self.number_of_byte_code_instructions] = byte;
        self.number_of_byte_code_instructions += 1;
    }

    fn add_bytes(self: *Self, bytes: []ByteCode) void {
        for(bytes) |byte| {
            self.add_byte(byte);
        }
    }

    fn print_byte_code(self: *const Self) void {
        var index: u64 = 0;
        while(index < self.number_of_byte_code_instructions) : (index += 1) {
            const byte = self.byte_code[index];
            std.debug.print("{} :: {}\n", .{ index, byte});
        }
    }

    fn print_stack(self: *const Self) void {
        var index: u64 = 0;
        std.debug.print("===== :: STACK INFO :: =====\n", .{});
        while(index < self.stack_pointer) : (index += 1) {
            const value = self.stack[index];
            std.debug.print("{} :: {}\n", .{ index, value});
        }
        std.debug.print("===== :: STACK INFO :: =====\n", .{});
    }

    fn push_to_stack(self: *Self, value: i64) void {
        self.stack[self.stack_pointer] = value;
        self.stack_pointer += 1;
    }

    fn pop_off_stack(self: *Self) i64 {
        const value = self.stack[self.stack_pointer - 1];
        self.stack_pointer -= 1;
        return value;
    }

    fn top_off_stack(self: *const Self) i64 {
        return self.stack[self.stack_pointer - 1];
    }

    fn run_vm(self: *Self) void {
        while(self.instruction_pointer < self.number_of_byte_code_instructions) : (self.instruction_pointer += 1) {
            const current_instruction = self.byte_code[self.instruction_pointer];

            switch (current_instruction) {
                .load_number => |value| {
                    self.push_to_stack(value);
                },
                .add => {
                    self.push_to_stack(
                        self.pop_off_stack() + self.pop_off_stack()
                    );
                },
                .print => {
                    std.debug.print("{}\n", .{self.pop_off_stack()});
                },
                .eof => {}
            }
        }
    }
};

fn run_vm_with(bytes: []ByteCode) VM {
    var vm = VM.new();
    vm.add_bytes(bytes);
    vm.run_vm();
    return vm;
}

pub fn main() !void {
    var vm = VM.new();
    var bytes = [_]ByteCode{
        ByteCode{.load_number = 100},
        ByteCode{.load_number = 200},
        ByteCode.add,
        ByteCode.print
    };
    vm.add_bytes(bytes[0..]);
    vm.run_vm();
}   

test "adding test" {
    var vm = VM.new();
    var bytes = [_]ByteCode{
        ByteCode{.load_number = 100},
        ByteCode{.load_number = 200},
        ByteCode.add,
    };
    vm.add_bytes(bytes[0..]);
    vm.run_vm();

    try std.testing.expect(vm.top_off_stack() == 300);
}
