class Dashing.Statuscake extends Dashing.Widget

  ready: ->
    super

  onData: (data) ->
  	node = $(@node)
  	status = data.overall_status
  	node.addClass "status-#{status}"
