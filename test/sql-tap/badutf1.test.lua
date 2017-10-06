#!/usr/bin/env tarantool
test = require("sqltester")
test:plan(25)

--!./tcltestrunner.lua
-- 2007 May 15
--
-- The author disclaims copyright to this source code.  In place of
-- a legal notice, here is a blessing:
--
--    May you do good and not evil.
--    May you find forgiveness for yourself and forgive others.
--    May you share freely, never taking more than you give.
--
-------------------------------------------------------------------------
-- This file implements regression tests for SQLite library. 
--
-- This file checks to make sure SQLite is able to gracefully
-- handle malformed UTF-8.
--
-- $Id: badutf.test,v 1.2 2007/09/12 17:01:45 danielk1977 Exp $
-- ["set","testdir",[["file","dirname",["argv0"]]]]
-- ["source",[["testdir"],"\/tester.tcl"]]
test:do_test(
    "badutf-1.1",
    function()
        test:execsql "PRAGMA encoding='UTF8'"
        return test:execsql2("SELECT hex('\x80') AS x")
    end, {
        -- <badutf-1.1>
        "x", "80"
        -- </badutf-1.1>
    })

test:do_test(
    "badutf-1.2",
    function()
        return test:execsql2("SELECT hex('\x81') AS x")
    end, {
        -- <badutf-1.2>
        "x", "81"
        -- </badutf-1.2>
    })

test:do_test(
    "badutf-1.3",
    function()
        return test:execsql2("SELECT hex('\xbf') AS x")
    end, {
        -- <badutf-1.3>
        "x", "BF"
        -- </badutf-1.3>
    })

test:do_test(
    "badutf-1.4",
    function()
        return test:execsql2("SELECT hex('\xc0') AS x")
    end, {
        -- <badutf-1.4>
        "x", "C0"
        -- </badutf-1.4>
    })

test:do_test(
    "badutf-1.5",
    function()
        return test:execsql2("SELECT hex('\xe0') AS x")
    end, {
        -- <badutf-1.5>
        "x", "E0"
        -- </badutf-1.5>
    })

test:do_test(
    "badutf-1.6",
    function()
        return test:execsql2("SELECT hex('\xf0') AS x")
    end, {
        -- <badutf-1.6>
        "x", "F0"
        -- </badutf-1.6>
    })

test:do_test(
    "badutf-1.7",
    function()
        return test:execsql2("SELECT hex('\xff') AS x")
    end, {
        -- <badutf-1.7>
        "x", "FF"
        -- </badutf-1.7>
    })

-- commented as it uses utf16
if 0>0 then
sqlite3("db2", "")
test:do_test(
    "badutf-1.10",
    function()
        test:execsql "PRAGMA encoding='UTF16be'"
        return sqlite3_exec("db2", "SELECT hex('%80') AS x")
    end, {
        -- <badutf-1.10>
        0, "x 0080"
        -- </badutf-1.10>
    })

test:do_test(
    "badutf-1.11",
    function()
        return sqlite3_exec("db2", "SELECT hex('%81') AS x")
    end, {
        -- <badutf-1.11>
        0, "x 0081"
        -- </badutf-1.11>
    })

test:do_test(
    "badutf-1.12",
    function()
        return sqlite3_exec("db2", "SELECT hex('%bf') AS x")
    end, {
        -- <badutf-1.12>
        0, "x 00BF"
        -- </badutf-1.12>
    })

test:do_test(
    "badutf-1.13",
    function()
        return sqlite3_exec("db2", "SELECT hex('%c0') AS x")
    end, {
        -- <badutf-1.13>
        0, "x FFFD"
        -- </badutf-1.13>
    })

test:do_test(
    "badutf-1.14",
    function()
        return sqlite3_exec("db2", "SELECT hex('%c1') AS x")
    end, {
        -- <badutf-1.14>
        0, "x FFFD"
        -- </badutf-1.14>
    })

test:do_test(
    "badutf-1.15",
    function()
        return sqlite3_exec("db2", "SELECT hex('%c0%bf') AS x")
    end, {
        -- <badutf-1.15>
        0, "x FFFD"
        -- </badutf-1.15>
    })

test:do_test(
    "badutf-1.16",
    function()
        return sqlite3_exec("db2", "SELECT hex('%c1%bf') AS x")
    end, {
        -- <badutf-1.16>
        0, "x FFFD"
        -- </badutf-1.16>
    })

test:do_test(
    "badutf-1.17",
    function()
        return sqlite3_exec("db2", "SELECT hex('%c3%bf') AS x")
    end, {
        -- <badutf-1.17>
        0, "x 00FF"
        -- </badutf-1.17>
    })

test:do_test(
    "badutf-1.18",
    function()
        return sqlite3_exec("db2", "SELECT hex('%e0') AS x")
    end, {
        -- <badutf-1.18>
        0, "x FFFD"
        -- </badutf-1.18>
    })

test:do_test(
    "badutf-1.19",
    function()
        return sqlite3_exec("db2", "SELECT hex('%f0') AS x")
    end, {
        -- <badutf-1.19>
        0, "x FFFD"
        -- </badutf-1.19>
    })

test:do_test(
    "badutf-1.20",
    function()
        return sqlite3_exec("db2", "SELECT hex('%ff') AS x")
    end, {
        -- <badutf-1.20>
        0, "x FFFD"
        -- </badutf-1.20>
    })
end


test:do_test(
    "badutf-2.1",
    function()
        return test:execsql2("SELECT '\x80'=CAST(x'80' AS text) AS x")
    end, {
        -- <badutf-2.1>
        "x", 1
        -- </badutf-2.1>
    })

test:do_test(
    "badutf-2.2",
    function()
        return test:execsql2("SELECT CAST('\x80' AS blob)=x'80' AS x")
    end, {
        -- <badutf-2.2>
        "x", 1
        -- </badutf-2.2>
    })



test:do_test(
    "badutf-3.1",
    function()
        return test:execsql2("SELECT length('\x80') AS x")
    end, {
        -- <badutf-3.1>
        "x", 1
        -- </badutf-3.1>
    })

test:do_test(
    "badutf-3.2",
    function()
        return test:execsql2("SELECT length('\x61\x62\x63') AS x")
    end, {
        -- <badutf-3.2>
        "x", 3
        -- </badutf-3.2>
    })

test:do_test(
    "badutf-3.3",
    function()
        return test:execsql2("SELECT length('\x7f\x80\x81') AS x")
    end, {
        -- <badutf-3.3>
        "x", 3
        -- </badutf-3.3>
    })

test:do_test(
    "badutf-3.4",
    function()
        return test:execsql2("SELECT length('\x61\xc0') AS x")
    end, {
        -- <badutf-3.4>
        "x", 2
        -- </badutf-3.4>
    })

test:do_test(
    "badutf-3.5",
    function()
        return test:execsql2("SELECT length('\x61\xc0\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80') AS x")
    end, {
        -- <badutf-3.5>
        "x", 2
        -- </badutf-3.5>
    })

test:do_test(
    "badutf-3.6",
    function()
        return test:execsql2("SELECT length('\xc0\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80') AS x")
    end, {
        -- <badutf-3.6>
        "x", 1
        -- </badutf-3.6>
    })

test:do_test(
    "badutf-3.7",
    function()
        return test:execsql2("SELECT length('\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80') AS x")
    end, {
        -- <badutf-3.7>
        "x", 10
        -- </badutf-3.7>
    })

test:do_test(
    "badutf-3.8",
    function()
        return test:execsql2("SELECT length('\x80\x80\x80\x80\x80\xf0\x80\x80\x80\x80') AS x")
    end, {
        -- <badutf-3.8>
        "x", 6
        -- </badutf-3.8>
    })

test:do_test(
    "badutf-3.9",
    function()
        return test:execsql2("SELECT length('\x80\x80\x80\x80\x80\xf0\x80\x80\x80\xff') AS x")
    end, {
        -- <badutf-3.9>
        "x", 7
        -- </badutf-3.9>
    })

test:do_test(
    "badutf-4.1",
    function()
        return test:execsql2("SELECT hex(trim('\x80\x80\x80\xf0\x80\x80\x80\xff','\x80\xff')) AS x")
    end, {
        -- <badutf-4.1>
        "x", "F0"
        -- </badutf-4.1>
    })

test:do_test(
    "badutf-4.2",
    function()
        return test:execsql2("SELECT hex(ltrim('\x80\x80\x80\xf0\x80\x80\x80\xff','\x80\xff')) AS x")
    end, {
        -- <badutf-4.2>
        "x", "F0808080FF"
        -- </badutf-4.2>
    })

test:do_test(
    "badutf-4.3",
    function()
        return test:execsql2("SELECT hex(rtrim('\x80\x80\x80\xf0\x80\x80\x80\xff','\x80\xff')) AS x")
    end, {
        -- <badutf-4.3>
        "x", "808080F0"
        -- </badutf-4.3>
    })

test:do_test(
    "badutf-4.4",
    function()
        return test:execsql2("SELECT hex(trim('\x80\x80\x80\xf0\x80\x80\x80\xff','\xff\x80')) AS x")
    end, {
        -- <badutf-4.4>
        "x", "808080F0808080FF"
        -- </badutf-4.4>
    })

test:do_test(
    "badutf-4.5",
    function()
        return test:execsql2("SELECT hex(trim('\xff\x80\x80\xf0\x80\x80\x80\xff','\xff\x80')) AS x")
    end, {
        -- <badutf-4.5>
        "x", "80F0808080FF"
        -- </badutf-4.5>
    })

test:do_test(
    "badutf-4.6",
    function()
        return test:execsql2("SELECT hex(trim('\xff\x80\xf0\x80\x80\x80\xff','\xff\x80')) AS x")
    end, {
        -- <badutf-4.6>
        "x", "F0808080FF"
        -- </badutf-4.6>
    })

test:do_test(
    "badutf-4.7",
    function()
        return test:execsql2("SELECT hex(trim('\xff\x80\xf0\x80\x80\x80\xff','\xff\x80\x80')) AS x")
    end, {
        -- <badutf-4.7>
        "x", "FF80F0808080FF"
        -- </badutf-4.7>
    })

--db2("close")


test:finish_test()