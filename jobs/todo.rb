SCHEDULER.every "1h" do
  send_event('videos', { current: 42 })
  send_event('pocket', { current: 42 })
  send_event('books', { current: 42 })
  send_event('kindle', { current: 42 })
end
