class Dashing.Image extends Dashing.Widget

  ready: ->
    @index = 0
    @photoElem = $(@node).find('.photo-container')
    @nextPhoto()
    @startCarousel()

  startCarousel: ->
    setInterval(@nextPhoto, 10000)

  nextPhoto: =>
    photos = @get('photos')
    if photos
      @photoElem.fadeOut =>
        @index = Math.floor(Math.random()*photos.length)
        @set 'current_photo', "/assets/"+photos[@index]
        @photoElem.fadeIn()
