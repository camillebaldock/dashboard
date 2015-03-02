class Dashing.Rescuetime extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super
    @observe 'value', (value) ->
      #console.log("CONSTRUCTOR+OBSERVE: max="+ @get("max")) if this.id=="rescuetime_total_productive"
      meter = $(@node).find(".meter")
      #meter.attr("max", @get("max"))
      meter.trigger('configure', {"fgColor": @get("color") })#, "max": @get("max")})
      meter.val(value).trigger('change')

  ready: ->
    meter = $(@node).find(".meter")
    meter.attr("data-bgcolor", meter.css("background-color"))
    meter.attr("data-fgcolor", meter.css("color"))
    meter.knob()
