return {
  no_consumer = false, -- this plugin is available on APIs as well as on Consumers,
  fields = {
    -- second, minute, hour, day, month, year
    rate_limit_time_unit = {type = "string", default = "minute"},
  }
}
