# just manual: https://github.com/casey/just#readme

SHLIB_EXE := if os() == "macos" {"dylib"} else {"so"}

OPENRESTY_PREFIX := "/usr/local/openresty"
LUA_LIB_DIR := env_var_or_default("LUA_LIB_DIR", OPENRESTY_PREFIX + "/lualib")
CARGO_BUILD_TARGET := env_var_or_default("CARGO_BUILD_TARGET", "")
RELEASE_DIR := "target/" + CARGO_BUILD_TARGET + "/release"
DEBUG_DIR := "target/" + CARGO_BUILD_TARGET + "/debug"
DESTDIR := env_var_or_default("DESTDIR", LUA_LIB_DIR)
INSTALL := "install"

_default:
    just --list

lint:
    cargo clippy -q --all-targets --all-features
    luacheck -q ./lib

build:
    cargo build --release

build-debug:
    cargo build

install-lualib:
    {{INSTALL}} -d {{DESTDIR}}/resty/heavykeeper
    {{INSTALL}} -m 664 lib/resty/heavykeeper/*.lua {{DESTDIR}}/resty/heavykeeper
    {{INSTALL}} -m 664 lib/resty/heavykeeper.lua {{DESTDIR}}/resty

install: build install-lualib
    {{INSTALL}} -m 775 {{RELEASE_DIR}}/libheavykeeper.{{SHLIB_EXE}} {{DESTDIR}}/libheavykeeper.{{SHLIB_EXE}}


install-debug: build-debug install-lualib
    {{INSTALL}} -m 775 {{DEBUG_DIR}}/libheavykeeper.{{SHLIB_EXE}} {{DESTDIR}}/libheavykeeper.{{SHLIB_EXE}}

export PATH := OPENRESTY_PREFIX + "/nginx/sbin:" + env_var_or_default("PATH", "")
export LUA_PATH := "lib/?.lua;lib/?/init.lua;" + env_var_or_default("LUA_PATH", "")
export LUA_CPATH := DEBUG_DIR + "/?.so;" + env_var_or_default("LUA_CPATH", "")
test:
    prove -r t/

export TEST_NGINX_VALGRIND := '--num-callers=100 -q --tool=memcheck --leak-check=full --show-possibly-lost=no --gen-suppressions=all --suppressions=valgrind.suppress --track-origins=yes'
export TEST_NGINX_USE_VALGRIND := '1'
valgrind:
    prove -r t/ 2>&1 | tee /dev/stderr | grep -q "match-leak-kinds: definite" && exit 1 || exit 0


cbindgen:
    #!/usr/bin/env bash
    set -euxo pipefail

    function cleanup {
        rm -rf "$WORK_DIR" || true
    }
    trap cleanup EXIT

    WORK_DIR=$(mktemp -d)

    if ! cargo expand > $WORK_DIR/expanded.rs; then
        exit $?
    fi

    if ! cbindgen -c cbindgen.toml $WORK_DIR/expanded.rs; then
        exit $?
    fi