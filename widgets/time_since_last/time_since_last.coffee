class Dashing.TimeSinceLast extends Dashing.Widget

  onData: (data) ->
    if data['background-color']
      $(@get('node')).css 'background-color', data['background-color']
