SCHEDULER.every "1h" do
  send_event('pocket', { current: 42 })
end
