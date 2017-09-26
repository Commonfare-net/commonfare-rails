Rails.application.configure do
  config.lograge.enabled = true

  # add time to lograge
  config.lograge.custom_options = lambda do |event|
    exceptions = %w(controller action format id)
    {
      time:   event.time,
      params: event.payload[:params].except(*exceptions)
    }
  end

  config.lograge.formatter = Lograge::Formatters::LTSV.new
end
