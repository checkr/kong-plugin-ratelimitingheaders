local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")
local plugin = require("kong.plugins.base_plugin"):extend()

local function get_reset_at_timestamp(time_unit)
  local time_unit_to_seconds = {
      second = 1,
      minute = 60,
      hour   = 3600,
      day    = 86400,
      month  = 2592000,
      year   = 31536000,
  }
  local time_interval = time_unit_to_seconds[time_unit]
  local start_time = ngx.req.start_time()
  local reset_time = start_time - (start_time % time_interval) + time_interval
  return os.date("%Y-%m-%dT%XZ", reset_time)
end

function plugin:new()
  plugin.super.new(self, plugin_name)
end

function plugin:header_filter(conf)
  plugin.super.header_filter(self)
  local source_limit_header = "X-RateLimit-Limit" .. "-" .. conf.rate_limit_time_unit
  local source_remaining_header = "X-RateLimit-Remaining" .. "-" .. conf.rate_limit_time_unit

  local target_limit_header = "X-RateLimit-Limit"
  local target_remaining_header = "X-RateLimit-Remaining"
  local target_reset_at_header = "X-RateLimit-Reset"

  local limit, remaining, reset_at
  limit = ngx.header[source_limit_header]
  remaining = ngx.header[source_remaining_header]

  if limit and remaining then
      ngx.header[target_limit_header] = limit
      ngx.header[target_remaining_header] = remaining
      ngx.header[target_reset_at_header] = get_reset_at_timestamp(conf.rate_limit_time_unit)

      ngx.header[source_limit_header] = nil
      ngx.header[source_remaining_header] = nil
  end
end

plugin.PRIORITY = 799
plugin.VERSION = "0.1.0"

return plugin
