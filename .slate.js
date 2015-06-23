// -----------------------------------------------------------------------------
// Operations

var halfToTheRight = slate.operation('push',{
  'direction': 'right',
  'style': 'bar-resize:screenSizeX/2'
})

var halfToTheLeft = slate.operation('push', {
  'direction': 'left',
  'style': 'bar-resize:screenSizeX/2'
})

var goFullScreen = slate.operation('move', {
  'x': 'screenOriginX',
  'y': 'screenOriginY',
  'width': 'screenSizeX',
  'height': 'screenSizeY'
})

// -----------------------------------------------------------------------------
// Key bindinds

slate.bind('left:cmd;alt', function(window) {
  window.doOperation(halfToTheLeft)
})

slate.bind('right:cmd;alt', function(window) {
  window.doOperation(halfToTheRight)
})

slate.bind('f:alt;cmd', function(window) {
  window.doOperation(goFullScreen)
})
