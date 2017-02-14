push!(LOAD_PATH,pwd())
using HttpServer
using Definition
using setupLibrary
using aiLibraryTwo
using moveLibrary
using board

moves = Vector{moveTable}(0)

stateKeys = Dict{String,Int}()

state = setup()

stateKey = join(state.board)

string(stateKey,'b')

stateKeys[stateKey]=1

winningPlayer = 'n'


moves = Vector{moveTable}(0)

function dispBoard(shogiBoard::shogiData)

  boardSize = size(shogiBoard.board)[1]
  myBoard = Array{String}(boardSize,boardSize)

  for i = 1:boardSize
    for j =1:boardSize
      myBoard[i,j]=" "
    end
  end
  for piece in shogiBoard.pieces
   if piece.captured == false
         pName = string(piece.name,piece.team)
       if piece.promoted == true
         pName = uppercase(pName)
       end
       myBoard[piece.sourcex,piece.sourcey] = pName
    end
  end
 println()
  for i = boardSize:-1:1
    for j =1:boardSize
      print(myBoard[j,i])
    end
     print("\n")
  end

end



function moveHandler(nextMove)
       global state
      println("in moveHandler...")
      dispBoard(state)  
      state.move.sourcex = nextMove[1]
      state.move.sourcey = nextMove[2]
      state.move.targetx = nextMove[3]
      state.move.targety = nextMove[4]
       state.move.move_type = "move"
       validity = false
       
       println("user movenumber ",state.move.move_number)
       state, validity = deepcopy(makeMove(state, true, false, true))
       println("Valdidity: $validity")
       dispBoard(state)
       prepend!(moves,[state.move])
       team = 'b'
       if state.move.move_number % 2 == 0
          team = 'w'
       end
      stateKey = join(state.board)
      stateKey = string(stateKey, team)
      stateKeys[stateKey] = get(stateKeys, stateKey, 0) + 1
      state.move.move_number += 1
      println("AI's making a move...")
     # println("movenumber ",state.move.move_number)
      newMove = get_play(moves, stateKeys, state)
      println("The Move IS: ",newMove)
      valid, state = next_state(state, newMove)
      prepend!(moves, [newMove])
      team = 'b'
    if state.move.move_number % 2 == 0
        team = 'w'
    end
    stateKey = join(state.board)
    stateKey = string(stateKey, team)
    stateKeys[stateKey] = get(stateKeys, stateKey, 0) + 1
     
    println("movenumber ",state.move.move_number)
    println("validity:",validity)
    dispBoard(state)	    
   return newMove
end


# Julia's do syntax lets you more easily pass a function as an argument
http = HttpHandler() do req::Request, res::Response

global state
  
if(ismatch(r"^/hello/",req.resource))    
    # if the requested path starts with `/hello/`, say hello
    # otherwise, return a 404 error
    str = req.resource
    println(req.headers)
    println(req.method)
    userMove = split(str,".")
    for c in userMove
	println(c)
    end

    if userMove[2]=="restart"
	newstate =setup()
	state = deepcopy(newstate)
	moves = Vector{moveTable}(0)
	 Response( ismatch(r"^/hello/",req.resource) ? string("success") : 404)
    elseif length(userMove) == 4
    	x = parse(Int,split(userMove[1],'/')[3])
    	println("x is: ",x)
    	arr = Vector{Int}(0)
    	push!(arr,x)
    	push!(arr,parse(Int,userMove[2]))
    	push!(arr,parse(Int,userMove[3]))
    	push!(arr,parse(Int,userMove[4]))
    	println("userMove: ",arr)
    	newMove = moveHandler(arr)
	Response( ismatch(r"^/hello/",req.resource) ? string(newMove.sourcex,".",newMove.sourcey,".",newMove.targetx,".",newMove.targety) : 404 )
    end
  end
    #Response( ismatch(r"^/hello/",req.resource) ? string(newMove.sourcex,".",newMove.sourcey,".",newMove.targetx,".",newMove.targety) : 404 )
end

# HttpServer supports setting handlers for particular events
http.events["error"]  = ( client, err ) -> println( err )
http.events["listen"] = ( port )        -> println("Listening on $port...")

server = Server( http ) #create a server from your HttpHandler
run( server,5555 ) #never returns
