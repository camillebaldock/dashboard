class Dashing.TimeSinceLast extends Dashing.Widget

  ready: ->
    @last_event = moment(new Date(localStorage.getItem(@get('id')+'_last_event')))
    @last_event = moment().format() unless @last_event
    setInterval(@startTime, 500)

  onData: (data) ->
    if(@get('since_date'))
      localStorage.setItem(@get('id')+'_last_event', moment(new Date(@get('since_date'))).format())

    @last_event = moment(new Date(localStorage.getItem(@get('id')+'_last_event')))
    $(@node).fadeOut().css('background-color', @backgroundColor).fadeIn()

  startTime: =>
    delta = moment().unix() - moment(@last_event).unix()
    t = Math.abs(delta)

    hour = 60 * 60
    m = Math.floor(t / 60)
    s = Math.floor(t % 60)

    if t > hour
      @set('time_past', moment(@last_event).fromNow())
    else if delta > 0
      @set('time_past', "+ " + @formatTime(m) + ":" + @formatTime(s))
    else
      @set('time_past', "- " + @formatTime(m) + ":" + @formatTime(s))

    @set('moreinfo', moment(@last_event).format('MMMM Do YYYY HH:mm a'))

  formatTime: (i) ->
    if i < 10 then "0" + i else i

  backgroundColor: =>
    if (@get('red_after'))
      redAfter = parseInt(@get('red_after'))
    else
      redAfter = 100

    diff = moment().unix() - moment(@last_event).unix()
    if (diff > redAfter)
      "red"
    else
      "green"
