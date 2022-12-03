local ffi = require "ffi"


ffi.cdef[[
int yyjson_check(const char *dat, size_t len);
void *yyjson_sized_alc_new(size_t size);
void yyjson_sized_alc_destory(void *alc);
int yyjson_check_with_sized_alc(void *sized_alc, const char *dat, size_t len);
]]


local type = type
local ffi_gc = ffi.gc


local libyyjson
do
    local function find_shared_obj(cpath, so_name)
        for k in string.gmatch(cpath, "[^;]+") do
            local so_path = string.match(k, "(.*/)")
            so_path = so_path .. so_name

            -- Don't get me wrong, the only way to know if a file exist is
            -- trying to open it.
            local f = io.open(so_path)
            if f ~= nil then
                io.close(f)
                return so_path
            end
        end
    end

    local path = find_shared_obj(package.cpath, "libyyjson.so")
    libyyjson = ffi.load(path)
end


local function check_json(s)
    if type(s) ~= "string" then
        return false
    end

    return libyyjson.yyjson_check(s, #s) == 1
end


local _default_bufsize = 128 * 1024


--  The max memory size is (json_size / 2 * 16 * 1.5 + padding).
local function new_checker(bufsize)
    if not bufsize or bufsize < _default_bufsize then
        bufsize = _default_bufsize
    end

    local alc = ffi_gc(libyyjson.yyjson_sized_alc_new(bufsize), libyyjson.yyjson_sized_alc_destory)

    return function(s)
        if type(s) ~= "string" then
            return false
        end

        return libyyjson.yyjson_check_with_sized_alc(alc, s, #s) == 1
    end
end


return {
    check = check_json,
    new_checker = new_checker,
}
