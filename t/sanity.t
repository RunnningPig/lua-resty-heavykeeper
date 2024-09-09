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

=== TEST 1: sanity
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local heavykeeper = require("resty.heavykeeper")

            local topk = heavykeeper.new(2)

            topk:add("item1")

            local existing = topk:query("item1")
            ngx.say(existing)

            existing = topk:query("item2")
            ngx.say(existing)
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