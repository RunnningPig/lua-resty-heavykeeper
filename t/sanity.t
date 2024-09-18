# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * blocks() * 5;

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
    lua_package_cpath "$pwd/target/debug/?.so;;";
};

no_long_string();
no_diff();

run_tests();

__DATA__

=== TEST 1: query
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local heavykeeper = require("resty.heavykeeper")

            local topk = heavykeeper.new(3)

            topk:add("item1")

            local topking = topk:query("item1")
            ngx.say(topking)

            topking = topk:query("item2")
            ngx.say(topking)
        }
    }
--- request
GET /t
--- response_body
true
false
--- no_error_log
[error]
[warn]
[crit]



=== TEST 2: query(add more items)
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local heavykeeper = require("resty.heavykeeper")

            local topk = heavykeeper.new(3)

            local item_counts = {
                { name = "item1", count = 100 },
                { name = "item2", count = 200 },
                { name = "item3", count = 300 },
                { name = "item4", count = 400 },
                { name = "item5", count = 500 },
                { name = "item6", count = 600 },
            }
            local random_item = function()
                if #item_counts == 0 then
                    return nil
                end
                local n = math.random(#item_counts)
                local item = item_counts[n]
                item.count = item.count - 1
                if item.count == 0 then
                    table.remove(item_counts, n)
                end
                return item.name
            end

            local total_count = 0
            while true do
                local item = random_item()
                if not item then
                    break
                end
                topk:add(item)
                total_count = total_count+1
            end

            ngx.say(total_count)

            local topking = topk:query("item6")
            ngx.say(topking)

            topking = topk:query("item1")
            ngx.say(topking)
        }
    }
--- request
GET /t
--- response_body
2100
true
false
--- no_error_log
[error]
[warn]
[crit]



=== TEST 3: list
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local heavykeeper = require("resty.heavykeeper")

            local topk = heavykeeper.new(3)

            topk:add("item1")
            topk:add("item2")

            local items = topk:list()
            for _, item in ipairs(items) do
                ngx.say(item)
            end
        }
    }
--- request
GET /t
--- response_body
item1
item2
--- no_error_log
[error]
[warn]
[crit]



=== TEST 4: list(add more items)
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local heavykeeper = require("resty.heavykeeper")

            local topk = heavykeeper.new(3)

            local item_counts = {
                { name = "item1", count = 100 },
                { name = "item2", count = 200 },
                { name = "item3", count = 300 },
                { name = "item4", count = 400 },
                { name = "item5", count = 500 },
                { name = "item6", count = 600 },
            }
            local random_item = function()
                if #item_counts == 0 then
                    return nil
                end
                local n = math.random(#item_counts)
                local item = item_counts[n]
                item.count = item.count - 1
                if item.count == 0 then
                    table.remove(item_counts, n)
                end
                return item.name
            end

            local total_count = 0
            while true do
                local item = random_item()
                if not item then
                    break
                end
                topk:add(item)
                total_count = total_count+1
            end

            ngx.say(total_count)

            local items = topk:list()
            for _, item in ipairs(items) do
                ngx.say(item)
            end
        }
    }
--- request
GET /t
--- response_body
2100
item6
item5
item4
--- no_error_log
[error]
[warn]
[crit]
