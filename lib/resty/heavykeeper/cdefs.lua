local ffi = require("ffi")


-- generated from "just cbindgen", do not edit manually
ffi.cdef([[
static const int TOPK_ITER_CONTINUE = 0;

static const int TOPK_ITER_BREAK = 1;

typedef struct TopkContext TopkContext;

typedef int (*TopkListForeachCallback)(const uint8_t*, size_t, void*);

struct TopkContext *topk_new(size_t k, size_t width, size_t depth, double decay);

void topk_add(struct TopkContext *topk, const uint8_t *item, size_t item_len);

bool topk_query(struct TopkContext *topk, const uint8_t *item, size_t item_len);

void topk_list_foreach(struct TopkContext *topk, TopkListForeachCallback cb, void *userdata);

void topk_free(struct TopkContext *topk);
]])

-- From: https://github.com/openresty/lua-resty-signal/blob/master/lib/resty/signal.lua
local load_shared_lib
do
    local tostring = tostring
    local string_gmatch = string.gmatch
    local string_match = string.match
    local io_open = io.open
    local io_close = io.close
    local table_new = require("table.new")

    local cpath = package.cpath

    function load_shared_lib(so_name)
        local tried_paths = table_new(32, 0)
        local i = 1

        for k, _ in string_gmatch(cpath, "[^;]+") do
            local fpath = tostring(string_match(k, "(.*/)"))
            fpath = fpath .. so_name
            -- Don't get me wrong, the only way to know if a file exist is
            -- trying to open it.
            local f = io_open(fpath)
            if f ~= nil then
                io_close(f)
                return ffi.load(fpath)
            end

            tried_paths[i] = fpath
            i = i + 1
        end

        return nil, tried_paths
    end  -- function
end  -- do

local lib_name = ffi.os == "OSX" and "libheavykeeper.dylib" or "libheavykeeper.so"

local clib, tried_paths = load_shared_lib(lib_name)
if not clib then
    error(("could not load %s shared library from the following paths:\n"):format(lib_name) ..
          table.concat(tried_paths, "\n"), 2)
end


return {
    clib = clib,

    topk_free = function(c)
        clib.topk_free(c)
    end,
}