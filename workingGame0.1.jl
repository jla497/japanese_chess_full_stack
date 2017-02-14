push!(LOAD_PATH,pwd())
using Definition
using setupLibrary
using moveLibrary
using aiLibraryTwo

state=setup()
stateKeys = Dict{String,Int}()
moves = Vector{moveTable}(0)

function newBoard()
 global state
  #state = setup()
  arr = dispBoard(state) 
  return arr
end

function moveHandler(nextMove)
	global state
	state.move.sourcex = nextMove[1][1]
    state.move.sourcey = nextMove[1][2]
    state.move.targetx = nextMove[2][1]
    state.move.targety = nextMove[2][2]
	state.move.move_type = "move"
	validity = false
	prepend!(moves,[state.move])
	state, validity = deepcopy(makeMove(state, true, false, true))
	team = 'b'
	if state.move.move_number % 2 == 0
       team = 'w'
    end
	stateKey = join(state.board)
    stateKey = string(stateKey, team)
    stateKeys[stateKey] = get(stateKeys, stateKey, 0) + 1
	state.move.move_number += 1
	  println("AI's making a move...")
	  newMove = get_play(moves, stateKeys, state)
      println("The Move IS: ",newMove)
      valid, state = deepcopy(next_state(state, newMove))
	  prepend!(moves, [newMove])
    
    team = 'b'
    if state.move.move_number % 2 == 0
        team = 'w'
    end
	stateKey = join(state.board)
    stateKey = string(stateKey, team)
    stateKeys[stateKey] = get(stateKeys, stateKey, 0) + 1
	state.move.move_number += 1
	println("validity:",validity)
	arr = dispBoard(state)
	return arr
end


function update(board,move)
i, j = move
newMove = (i,j)
if length(nextMove) < 2
 push!(nextMove,newMove)
elseif length(nextMove) > 2
	for i = 1:length(nextMove)
	 pop!(nextMove)
	end
	push!(nextMove,newMove)
end

if length(nextMove) == 2
println("line 45")
 board = deepcopy(moveHandler(nextMove))
 #sx,sy = nextMove[1]
 #dx,dy = nextMove[2]
 #piece = board[sx,sy]
 #board[sx,sy] = " "
 #board[dx,dy] = piece
 for i = 1:length(nextMove)
	 pop!(nextMove)
 end
 
 for i = 9:-1:1
    for j =1:9
      print(board[j,i])
    end
	println()
  end
end

return board

end

nextMove = Vector{Tuple{Int,Int}}(0)
move_signal = Signal((0,0))
initial_board_signal = Signal(Array{String,2},newBoard())
board_signal = flatten(
	map(initial_board_signal) do b
	 foldp(update, b, move_signal; typ=Array{String,2})
	end
	)

function makePiece(board::Array{String},i::Int,j::Int)
 piece = board[i,j]
 team = piece[length(piece)]
 name = chop(piece)
 color = "white"
 if team == 'b'
  color = "grey"
 elseif team == 'w'
  color = "white"
 end
 t = fillcolor(color,Escher.pad(1em,name))|>height(3em)|>width(5em)|>borderwidth(0.1em)|>bordercolor("black")|>borderstyle(solid)
 b = intent(constant((i,j)),clickable(t))>>>move_signal
 
return b
end

function showBoard(gameBoard::Array{String})
   
   m, n = size(gameBoard)
   b = vbox([hbox([makePiece(gameBoard,i,j) for i in 1:m])for j in m:-1:1])
    return b
end




	
function main(window)
	state = setup()
	push!(window.assets,"widgets")

    # Load HTML dependencies related to the slider
	b  = newBoard()
	vbox(
		map(showBoard,board_signal,typ=Tile)
		
	)
	
end
