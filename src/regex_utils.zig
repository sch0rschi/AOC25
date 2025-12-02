const pcre2 = @cImport({
    @cDefine("PCRE2_CODE_UNIT_WIDTH", "8");
    @cInclude("pcre2.h");
});

pub const simple_regex = struct {
    code: *pcre2.pcre2_code_8,
    match: *pcre2.pcre2_match_data_8,

    pub fn setup_regex(pattern: [:0]const u8) simple_regex {
        var error_number: c_int = undefined;
        var error_offset: usize = undefined;

        const re = pcre2.pcre2_compile_8(
            pattern.ptr,
            pattern.len,
            0,
            &error_number,
            &error_offset,
            null,
        ) orelse {
            unreachable;
        };

        const jit_error = pcre2.pcre2_jit_compile_8(re, pcre2.PCRE2_JIT_COMPLETE);
        if (jit_error != 0) {
            unreachable;
        }

        const match_data =
            pcre2.pcre2_match_data_create_from_pattern_8(re, null) orelse unreachable;

        return simple_regex{
            .code = re,
            .match = match_data,
        };
    }

    pub fn matches(self: *const simple_regex, subject: []const u8) bool {
        const group_count = pcre2.pcre2_match_8(
            self.code,
            subject.ptr,
            subject.len,
            0,
            0,
            self.match,
            null,
        );
        return group_count >= 0;
    }

    pub fn free(self: *const simple_regex) void {
        pcre2.pcre2_code_free_8(self.code);
        pcre2.pcre2_match_data_free_8(self.match);
    }
};
