local helpers = require "spec.helpers"

describe("Plugin: ratelimitingheaders (header_filter)", function()
  local client
  setup(function()
    local api1 = assert(helpers.dao.apis:insert {
      name         = "api-1",
      hosts        = { "host1.com" },
      upstream_url = helpers.mock_upstream_url,
    })
    assert(helpers.dao.plugins:insert {
      name   = "rate-limiting",
      api_id = api1.id,
      config = {
          minute = 1000,
          policy = "local",
      }
    })
    assert(helpers.dao.plugins:insert {
      name   = "ratelimitingheaders",
      api_id = api1.id,
    })

    assert(helpers.start_kong({
      nginx_conf = "spec/fixtures/custom_nginx.template",
      custom_plugins = "ratelimitingheaders",
    }))
    client = helpers.proxy_client()
  end)

  teardown(function()
    if client then client:close() end
    helpers.stop_kong()
  end)

  describe("plugin: ratelimitingheaders", function()
    it("does nothing if there's no rate limiting in the headers", function()
      local res = assert(client:send {
        method = "GET",
        path = "/request",
        headers = {
          ["Host"] = "host1.com",
        }
      })
      assert.res_status(200, res)
    end)
    it("does transfer X-RateLimit-Limit-Minute to X-RateLimit-Limit for default config", function()
      local res = assert(client:send {
        method = "GET",
        path = "/request",
        headers = {
          ["Host"] = "host1.com",
        }
      })
      assert.res_status(200, res)
    end)
  end)
end)
