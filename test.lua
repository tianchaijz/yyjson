local cjson = require "cjson.safe"
local jsonc = require "yyjson_checker"


local function do_test(check_json)
    assert(check_json(cjson.encode({})))
    assert(check_json(" { } \n"))
    assert(check_json(cjson.encode({["你好"] = "世界"})))
    assert(check_json(cjson.encode({"你好", "世界", "Foo © bar 𝌆 baz ☃ qux"})))
    assert(check_json(cjson.encode({"\0"})))
    assert(check_json('["\\u0000"]'))
    assert(cjson.decode('["\\u0000"]')[1] == "\0")
    assert(check_json(cjson.encode({"\xe4\xbd\xa0"})))
    -- print(cjson.encode({"\0"}))
    -- print(cjson.encode({"\xe4\xbd\xa0"}))

    assert(not check_json(""))
    assert(not check_json(" "))
    assert(not check_json("{"))
    assert(not check_json("}"))
    assert(not check_json("{}{}"))
    assert(not check_json("{}\n{}"))


    local function test_with_cjson(s)
        if cjson.decode(s) then
            assert(check_json(s))
        else
            assert(not check_json(s))
        end
    end


    test_with_cjson("1")
    test_with_cjson('"1"')
end


do_test(jsonc.check)
do_test(jsonc.new_checker())


print("OK!")
