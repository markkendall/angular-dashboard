# Define custom server-side HTTP routes for lineman's development server
# These might be as simple as stubbing a little JSON to
# facilitate development of code that interacts with an HTTP service
# (presumably, mirroring one that will be reachable in a live environment).
#
# It's important to remember that any custom endpoints defined here
# will only be available in development, as lineman only builds
# static assets, it can't run server-side code.
#
# This file can be very useful for rapid prototyping or even organically
# defining a spec based on the needs of the client code that emerge.


cpu = []

generateCpuValue = (now) ->
  time = new Date(now)
  time.setSeconds(0)
  time.setMilliseconds(0)
  console.log "\nCompare"
  console.log time
  console.log cpu[cpu.length - 1]?.time
  unless cpu[cpu.length - 1]?.time.toString() == time.toString()
    console.log "   adding"
    cpu.push { time: time, usage: Math.floor(Math.random() * 101) }
  cpu.shift() if cpu.length > 10

for i in [10..1]
  now = new Date()
  now.setMinutes(now.getMinutes() - i)
  generateCpuValue(now)

module.exports = {
  drawRoutes: (app) ->
    app.get '/cpu.json', (req, res) ->
      generateCpuValue(new Date())
      res.json cpu
}
