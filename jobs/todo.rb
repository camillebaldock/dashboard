SCHEDULER.every "1h" do
  send_event('films', { current: 42 })
  send_event('tv', { current: 42 })
  send_event('podcasts', { current: 42 })
  send_event('videos', { current: 42 })
  send_event('pocket', { current: 42 })
  send_event('books', { current: 42 })
  send_event('rss', { current: 42 })
  send_event('newsletter', { current: 42 })
  send_event('blog', { current: 42 })
  send_event('kindle', { current: 42 })
  send_event('pulls', { current: 42 })
  send_event('forks', { items: [{"label" => "TODO", "value" => "TODO"}] })
end
