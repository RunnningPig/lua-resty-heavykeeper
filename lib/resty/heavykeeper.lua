local ffi = require("ffi")
local cdefs = require("resty.heavykeeper.cdefs")


local setmetatable = setmetatable
local insert_tab = table.insert
local new_tab = require("table.new")
local ffi_gc = ffi.gc
local ffi_str = ffi.string


local clib = cdefs.clib
local topk_free = cdefs.topk_free


local _M = {
    _VERSION = "0.1"
}
local _MT = { __index = _M }


function _M.new(k, opts)
    if k <= 0 then
        return nil, "k too small"
    end

    local opts = opts or {}
    local width = opts.width or 8
    local depth = opts.depth or 7
    local decay = opts.decay or 0.9

    local topk = clib.topk_new(k, width, depth, decay)

    local self = setmetatable({
        k = k,
        topk = ffi_gc(topk, topk_free)
    }, _MT)

    return self
end

function _M.add(self, item)
    clib.topk_add(self.topk, item, #item)
end

function _M.query(self, item)
    local ok = clib.topk_query(self.topk, item, #item)
    return ok
end

function _M.list(self)
    local list = new_tab(self.k, 0)
    local cb = function(item_ptr, item_len)
        local item = ffi_str(item_ptr, item_len)
        insert_tab(list, item)
        return clib.TOPK_ITER_CONTINUE;
    end
    clib.topk_list_foreach(self.topk, cb, nil)
    return list
end

return _M
