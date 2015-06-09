class Dashing.List extends Dashing.Widget
  ready: ->
    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()

  @accessor 'updatedAtMessage', ->
    if updatedAt = @get('updatedAt')
      timestamp = new Date(updatedAt * 1000)
      now = new Date();
      oneDay = 24*60*60*1000;
      days = Math.round(Math.abs((timestamp.getTime() - now.getTime())/(oneDay)));
      if days > 0
        "Last updated more than one day ago"
      else
        hours = timestamp.getHours()
        minutes = ("0" + timestamp.getMinutes()).slice(-2)
        "Last updated at #{hours}:#{minutes}"

  onData: (data) ->
    if data['background-color']
      $(@get('node')).css 'background-color', data['background-color']
