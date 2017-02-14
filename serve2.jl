using Morsel

app = Morsel.app()

route(app, GET,"/") do req, res
	"This is the root"
         println(req)
end

start(app,5555)
