SCHEDULER.every "30s" do
  #Entertainment
  send_event('films', { current: 0 })
  send_event('tv', { current: 0 })
  send_event('podcasts', { current: 0 })
  send_event('videos', { current: 0 })
  send_event('pocket', { current: 0 })
  send_event('books', { current: 0 })
  #Tasks
  send_event('newsletter', { current: 1000 })
  #Tech
  send_event('pulls', { current: 0 })
  send_event('forks', { items: [{"label" => "TODO", "value" => "TODO"}] })
end
