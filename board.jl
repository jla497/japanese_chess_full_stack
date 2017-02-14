
module board
push!(LOAD_PATH,pwd())
using Definition: metaTable, moveTable, shogiData, piece
using moveLibrary
export arrayToString, generateMove,current_player, next_state, win, evaluateMove, miniMax, initRandomKeys, isPlayerinCheck, getKing, removeRepeatedStates, getAttacks
using userMoveLibrary: move_user_Move, move_user_Drop
using setupLibrary
#using aiLibrary

function arrayToString(arr::Array{String,2})
  str = join(arr)
  return str
end


function initRandomKeys(randomSeed,boardSize)
  pieceKeys = Array{UInt128}(40,  boardSize*boardSize)
  local sideKey::UInt128
  pieceKeys = rand(1:typemax(randomSeed), 40, boardSize*boardSize)
  sideKey = randomSeed
  return pieceKeys, sideKey
end

function isValidMove(shogiBoard,p,x,y)
 if p.name == 'p'
  res = pawnMove(shogiBoard,p,x,y)

  return res
elseif p.name == 'n'
  res = knightMove(shogiBoard,p,x,y)
  return res
elseif p.name == 'g' || p.name == 's' || p.name == 'k'
  res = gskMove(shogiBoard,p,x,y)
  return res
elseif p.name =='r' || p.name == 'b' ||p.name == 'l'
  res = slidingPieceMove(shogiBoard,p,x,y)
  return res
  end
end

function slidingPieceMove(shogiBoard,p,x,y)
  result = isBlocked(shogiBoard,p,x,y)

  if typeof(result)!=Bool || result == false
    return true
  elseif result == true
    return false
  end
end

function gskMove(shogiBoard,p,x,y)
  result = isBlocked(shogiBoard,p,x,y)

  if typeof(result)!=Bool || result == false
    return true
  elseif result == true
    return false
  end
end

function knightMove(shogiBoard,p,x,y)
  boardSize = size(shogiBoard.board)
  if p.promoted==false && (y == boardSize[1] || y == 1)
      return false
  end
  result = isBlocked(shogiBoard,p,x,y)

  if typeof(result)!=Bool || result == false
    return true
  elseif result == true
    return false
  end
end

function pawnMove(shogiBoard,p,x,y)
  team = 'b'
  if shogiBoard.move.move_number%2==0
    team = 'w'
  end
  if pawnInLine(shogiBoard,p,team, x) == true
    return false
  end
  boardSize = size(shogiBoard.board)
  if p.promoted==false && (y == boardSize[1] || y == 1)
      return false
  end
  result = isBlocked(shogiBoard,p,x,y)

  if typeof(result)!=Bool || result == false
    return true
  elseif result == true
    return false
  end
end
#=
	Is Blocked
	Description: Checks wheather the target location is blocked by another piece
	piece: <piece> The piece being checked for blocking
	x: <Int> The distance traveled in the x coordinate
	y: <Int> The distance traveled in the y coordinate
	return: <Boolean> Wheather the path is blocked or not
=#
function isBlocked(shogiBoard::shogiData, p, x, y)

  target = getPieceAtLocation(shogiBoard,x,y)
  if target == false
    return false
  elseif target.team==p.team
    return true
  elseif target.team!=p.team
    return target
  end

end

#=
	Get Piece At Location
	Description: Gets the piece occupying the inputted location on the board
	x: <Int> The x coordinate on the board
	y: <Int> The y coordinate on the board
	return: <piece> The piece occupying the inputted location on the board
=#
function getPieceAtLocation(shogiBoard::shogiData, x, y)

		for p in shogiBoard.pieces
			if p.sourcex == x && p.sourcey == y
				return p
			end
		end

	return false
end

#=
	Get King
	Description: Gets the piece known as the king for that team
	team: <Char> The team the king is on
	return: <Boolean> Wheather the king is in check or not
=#
function getKing(shogiBoard::shogiData, team)
	for p in shogiBoard.pieces
		if p.name == "king" && p.team == team
			return p
		end
	end
end

#=
	Pawn In Line
	Description: Checks if the drop position contains a pawn already from that team
	team: <Char> The team of the current players turn ('b' is Black, 'w' is White)
	targetx: <Int> The index of the x coordinate for the selected destination on the board
	return: <boolean> Wheather there is a pawn in that column
=#
function pawnInLine(shogiBoard::shogiData, piece, team, targetx)
  count = 0
  for p in shogiBoard.pieces
		if p.team == team && p.sourcex == targetx && p.name == 'p' && p.sourcey!=piece.sourcey
			count+=1
		end
	end
  if count < 1
    return false
	elseif count >= 1
    return true
  end
end

#generate all possible valid moves for each piece on the currentboard
function generateMove(b::shogiData)
  originalBoard = deepcopy(b)
  generatedMoves = Vector{moveTable}(0)
  boardSize = size(originalBoard.board)
  bsize = boardSize[1]
  team = 'b'
  if originalBoard.move.move_number%2 == 0
    team = 'w'
  end

  moveDict = Dict('p'=>[1 0],'l'=>[1 0],'s'=>Vector{Int}[[-1, -1], [-1, 1], [1, -1], [1, 0], [1,1]],
                  'n'=>Vector{Int}[[2, -1], [2, 1]], 'g'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
                  'b'=>Vector{Int}[[-1, -1], [-1, 1], [1,-1], [1, 1]], 'r'=>Vector{Int}[[-1, 0], [1, 0], [0, -1], [0, 1]],
                  'k'=>Vector{Int}[[-1,-1],[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1]])

 promotedMoveDict = Dict('r'=>Vector{Int}[[-1, -1], [-1, 1], [-1, 1], [1, 1]],
                         'b'=>Vector{Int}[[-1, 0], [1, 0], [0, -1], [0, 1]],
                         's'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
                         'n'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
                         'l'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
                         'p'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
                         'k'=>Vector{Int}[[-1,-1],[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1]],
                         'g'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
                         )

  for i = 1:length(b.pieces)#iterate through all the pieecs
    piece = b.pieces[i]
    #drop piece
   if (team!= piece.team && piece.captured == true && piece.name != 'k')
        for x = 1:boardSize[1]
          for y = 1:boardSize[2]
            newBoard = deepcopy(originalBoard)
            newmoveTable = moveTable(bsize, originalBoard.move.move_number, "drop", 0, 0, x, y, piece.name, false)
            result = isBlocked(newBoard,piece,x,y) #check if there's another piece at x,y
            #println("p.name: ",piece.name," x,y: ",x,",",y," valid: ",result)

            if result == false && isValidMove(newBoard,piece,x,y)==true
              newBoard = deepcopy(next_state(newBoard,newmoveTable))
							if isPlayerinCheck(newBoard,team)!=true #check if king is still in check
              	push!(generatedMoves, newmoveTable)
							end
            end
          end
        end
      end
    end

    #generate all legal plays for the current player's sliding pieces
  for piece in b.pieces
    if (team != piece.team || piece.captured == true)
      continue
    end
      #println("piece name: ",piece.name, " piece.team: ",piece.team, " piece.sourcex: ",piece.sourcex, " piece.sourcey: ",piece.sourcey)
      pType = piece.name
      orientation = 1 #changes orientation of moves on the board if the pieces are black
      if piece.team == 'b'
        orientation = -1
      end
      validMoves = get(moveDict,pType,0)#get all possible move combination for the piece

        if piece.name == 'r' ||  piece.name == 'b' || (piece.name == 'l' && piece.promoted == false)#if it's not a sliding piece, skip
        #  println("piece: ",piece.name,"\n", "validMoves: ",validMoves)
          z = size(validMoves)
          for i = 1:z[1] #iterate through all possible move combo
            x=0
            y=0
            newBoard = deepcopy(originalBoard)
            x = piece.sourcex
            y = piece.sourcey

            if pType == 'r'|| pType == 'b'
              x += (validMoves[i][2]*orientation)
              y += (validMoves[i][1]*orientation)
            elseif pType == 'l'
              y += (validMoves[1]*orientation)
            end

            while x>=1 && x<=boardSize[2] && y>=1 && y<=boardSize[1] #checking boundary

              newBoard = deepcopy(originalBoard)
              result = isBlocked(newBoard,piece,x,y)
              #println("p.name: ",piece.name," x,y: ",x,",",y," blocked: ",result)
              newmoveTable = moveTable(boardSize[1], originalBoard.move.move_number, "move", piece.sourcex, piece.sourcey, x, y, '?', false)
              if typeof(result)!=Bool #there is enemy piece
                newBoard = deepcopy(next_state(newBoard,newmoveTable))
                if isPlayerinCheck(newBoard,team)!=true #check if king is still in check

                	push!(generatedMoves, newmoveTable)
  							end
                break #no more moves to be generated.
              elseif result == true
                break
              elseif result == false
                newBoard = deepcopy(next_state(newBoard,newmoveTable))
                if isPlayerinCheck(newBoard,team)!=true #check if king is still in check

                  push!(generatedMoves, newmoveTable)
                end
              end

              if pType == 'r'|| pType == 'b'
                x += (validMoves[i][2]*orientation)
                y += (validMoves[i][1]*orientation)
              elseif pType == 'l'
                y += (validMoves[1]*orientation)
              end# enf of pType == 'c'
            end#end of while
          end#end of for
       end
     end
      for piece in originalBoard.pieces
            if (team != piece.team || piece.captured == true||piece.promoted == true)
              continue
            end
            if  piece.name == 'b'||piece.name == 'r'||piece.name=='l'
              continue
            end
              #println("piece name: ",piece.name, " piece.team: ",piece.team, " piece.sourcex: ",piece.sourcex, " piece.sourcey: ",piece.sourcey)
            orientation = 1 #changes orientation of moves on the board if the pieces are black
            if piece.team == 'b'
              orientation = -1
            end

            validMoves = get(moveDict,piece.name,0)

             z = size(validMoves)
            if z[1]>1
              for i = 1:z[1]
                x = 0
                y = 0

                newBoard = deepcopy(originalBoard)
                x = piece.sourcex + (validMoves[i][2]*orientation)
                y = piece.sourcey + (validMoves[i][1]*orientation)

                if x>=1 && x<=boardSize[2] && y>=1 && y<=boardSize[1]#checks the move is not out of the board
                  result = isValidMove(newBoard,piece,x,y)
                  if piece.name == 'k' && piece.team == 'b'
                  #  println("targetx,y: ", x,", ",y)
                  #  println("validMove?: ",result)
                  #  Display(newBoard)
                  end

                  if result == true
                    newmoveTable = moveTable(boardSize[1], originalBoard.move.move_number, "move", piece.sourcex, piece.sourcey, x, y, '?', false)
                    newBoard = deepcopy(next_state(newBoard,newmoveTable))
                  #=  if piece.name == 'k' && piece.team == 'b'
                      println("targetx,y: ", x,", ",y)
                      println("king in check: ",isPlayerinCheck(newBoard,team))
                      println("validMove?: ",result)
                      Display(newBoard)
                    end=#
                    if isPlayerinCheck(newBoard,team)!=true #check if king is still in check

                      push!(generatedMoves, newmoveTable)
                    end
                  end
                end
              end
            end
            if z[1]==1 #pieces with only one set of moves

              newBoard = deepcopy(originalBoard)
              x = piece.sourcex + (validMoves[2]*orientation)
              y = piece.sourcey + (validMoves[1]*orientation)
              if x>=1 && x<=boardSize[2] && y>=1 && y<=boardSize[1]#checks the move is not out of the board
                result = isValidMove(newBoard,piece,x,y)
                  #println("p.name: ",piece.name," x,y: ",x,",",y," valid: ",result)
                if result == true
                  newmoveTable = moveTable(boardSize[1], originalBoard.move.move_number, "move", piece.sourcex, piece.sourcey, x, y, '?', false)
                  newBoard = deepcopy(next_state(newBoard,newmoveTable))
                  if isPlayerinCheck(newBoard,team)!=true #check if king is still in check
                    push!(generatedMoves, newmoveTable)
                  end
                end
              end
            end
      end#end of moves for non-sliding pieces
      #promoted move
  for p in originalBoard.pieces
   if (p.team == team && p.captured == false && p.promoted == true)
     orientation = 1 #changes orientation of moves on the board if the pieces are black
       if p.team == 'b'
           orientation = -1
        end
       if p.name == 'k' || p.name =='g'
         continue
       end
     promotedMoves = get(promotedMoveDict,p.name,0)
    #println("promoted move piece.name: ",p.name)
    z = size(promotedMoves)
    for i = 1:z[1]
      newBoard = deepcopy(originalBoard)
       x = 0
       y = 0
       x = p.sourcex + (promotedMoves[i][2]*orientation)
       y = p.sourcey + (promotedMoves[i][1]*orientation)

       if x>=1 && x<=boardSize[2] && y>=1 && y<=boardSize[1]#checks the move is not out of the board
         result = isValidMove(newBoard,p,x,y)
           #println("p.name: ",piece.name," x,y: ",x,",",y," valid: ",result)
         if result == true
            newmoveTable = moveTable(boardSize[1], originalBoard.move.move_number, "move", p.sourcex, p.sourcey, x, y, '?', false)
              newBoard = deepcopy(next_state(newBoard,newmoveTable))
            if isPlayerinCheck(newBoard,team)!=true #check if king is still in check
             push!(generatedMoves, newmoveTable)
            end
          end
        end
      end #for i=1:z[1]
    end#ifPromotedMove!=-
  end

 return generatedMoves
end

function isPlayerinCheck(originalBoard::shogiData,team::Char)


	 king = getKing(originalBoard, team)

	 orientation = 1
	 boardSize = size(originalBoard.board)
   moveDict = Dict('p'=>[1 0],'l'=>[1 0],'s'=>Vector{Int}[[-1, -1], [-1, 1], [1, -1], [1, 0], [1,1]],
                   'n'=>Vector{Int}[[2, -1], [2, 1]], 'g'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
                   'b'=>Vector{Int}[[-1, -1], [-1, 1], [1,-1], [1, 1]], 'r'=>Vector{Int}[[-1, 0], [1, 0], [0, -1], [0, 1]],
                   'k'=>Vector{Int}[[-1,-1],[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1]])

 	promotedMoveDict = Dict('r'=>Vector{Int}[[-1, -1], [-1, 1], [-1, 1], [1, 1]],
 													'b'=>Vector{Int}[[-1, 0], [1, 0], [0, -1], [0, 1]],
 													's'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
 													'n'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
 													'l'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
 													'p'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
                          'k'=>Vector{Int}[[-1,-1],[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1]],
                          'g'=>Vector{Int}[[-1, 0], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
                          )

	for piece in originalBoard.pieces
	 if (king.team != piece.team && piece.captured == false)
		 #println("piece name: ",piece.name, " piece.team: ",piece.team, " piece.sourcex: ",piece.sourcex, " piece.sourcey: ",piece.sourcey)
		 pType = piece.name
		 orientation = 1 #changes orientation of moves on the board if the pieces are black
		 if piece.team == 'b'
			 orientation = -1
		 end
		 validMoves = get(moveDict,pType,0)#get all possible move combination for the piece
			 #println("piece: ",piece.name,"\n", "validMoves: ",validMoves)
			 if pType == 'r'|| pType == 'b' || (piece.name == 'l' && piece.promoted == false)#if it's a sliding piece
				 z = size(validMoves)
				 for i = 1:z[1] #iterate through all possible move combo
					 x=0
					 y=0
					 x = piece.sourcex
					 y = piece.sourcey

					 if pType == 'r'|| pType == 'b'
						 x += (validMoves[i][2]*orientation)
						 y += (validMoves[i][1]*orientation)
					 elseif pType == 'l'
						 y += (validMoves[1]*orientation)
					 end

					 while x>=1 && x<=boardSize[2] && y>=1 && y<=boardSize[1] #checking boundary
						 result = getPieceAtLocation(originalBoard, x, y)
						 pathBlocked = false
						 if typeof(result) != Bool && (result.name!=king.name ||result.sourcex!=king.sourcex || result.sourcey != king.sourcey)
               break
            elseif result == false
              if pType == 'r'|| pType == 'b'
                 x += (validMoves[i][2]*orientation)
                 y += (validMoves[i][1]*orientation)
               elseif pType == 'l'
                 y += (validMoves[1]*orientation)
               end# enf of pType == 'c'
              continue
						elseif result.name == king.name && king.sourcex == result.sourcex && king.sourcey == result.sourcey
              # println("piece.team: ",piece.team," piece.name: ",piece.name," x,y:  ",piece.sourcex, piece.sourcey ," is checking the king")
            	return true
						end
						#the destinat was not blocked but king not found so increase path
						if pType == 'r'|| pType == 'b'
							 x += (validMoves[i][2]*orientation)
							 y += (validMoves[i][1]*orientation)
						 elseif pType == 'l'
							 y += (validMoves[1]*orientation)
						 end# enf of pType == 'c'
					 end#end of while
				 end#end of for

		 else #non-sliding pieces
       if piece.promoted == false
				z = size(validMoves)
			    if z[1]>1
				    for i = 1:z[1]
					    x = 0
					    y = 0
					    x = piece.sourcex + (validMoves[i][2]*orientation)
					    y = piece.sourcey + (validMoves[i][1]*orientation)

					    res = checkUtil(originalBoard,x,y,king)
              if res == true
            #   println("piece.team: ",piece.team," piece.name: ",piece.name," x,y:  ",piece.sourcex, piece.sourcey ," is checking the king")
               return true
              end
				  	end
				  elseif z[1]==1 #pieces with only one set of moves
				 ###println("validMove array dimension equal to 1. Only one set of move")
				    x = piece.sourcex + (validMoves[2]*orientation)
				    y = piece.sourcey + (validMoves[1]*orientation)
            res = checkUtil(originalBoard,x,y,king)
            if res == true
             return true
            end
				  end
        end
      end
				 if piece.promoted == true
					 promotedMoves = get(promotedMoveDict,piece.name,0)
           if size(promotedMoves)[1] == 0
             println("size of promotedMoves for piece: ",piece.name," is empty")
             error()
           end
						 z = size(promotedMoves)
						 for i = 1:z[1]
								x = 0
								y = 0
								x = piece.sourcex + (promotedMoves[i][2]*orientation)
								y = piece.sourcey + (promotedMoves[i][1]*orientation)
                res = checkUtil(originalBoard,x,y,king)

                if res == true
                #   println("piece.team: ",piece.team," piece.name: ",piece.name," x,y:  ",piece.sourcex, piece.sourcey ," is checking the king")
                  return true
                end
							 end
				  end
			end
		end
      #println("team: ",team," piece.name: ",piece.name," x,y:  ",piece.sourcex, piece.sourcey ," is not checking the king")
  	return false
end
#black always starts the game and move.movenumber starts at 0 until black player makes the first move and the movenumber is now 1.
#So white starts at movenumber 1, 3, 5... and black starts at 0,2,4...
function current_player(shogiBoard::shogiData)
   team = 'b'
   if shogiBoard.move.move_number%2==0
     team = 'w'
   end
   return team
end

function next_state(currentState::shogiData, play::moveTable)
  currentState.move = play

  if currentState.move.move_type == "move"
		nextState=deepcopy(move_user_MoveTwo(currentState,true))
    if nextState == -1
      #println("move_user_move returned -1. Invalid move.")
      return false,currentState
    end
    nextState.move.move_number = nextState.move.move_number+1
    nextState.board = updateBoard(nextState)#must update board as well after move's been made
    if nextState.move.targetx2 != -1 && nextState.move.targety2 !=-1
    #  println("move with two steps: ",nextState.move)
    #  Display(nextState)
    end
    return true, nextState
	elseif currentState.move.move_type == "drop"

		nextState=deepcopy(move_user_Drop(currentState))
    nextState.move.move_number = nextState.move.move_number+1
    nextState.board = updateBoard(nextState)#must update board as well after move's been made
    return true,nextState
  end
end

 function win(moves::Vector{moveTable},team::Char,state::shogiData)

sameStates = Dict()
piecesCaptured = Dict()
otherTeam = 'w'
if team == 'w'
  otherTeam = 'b'
end
boardSize = size(state.board)[1]
shogiBoard = deepcopy(setup())
if boardSize == 5
  shogiBoard = deepcopy(setupM())
elseif boardSize == 12
  shogiBoard = deepcopy(setupC())
elseif boardSize == 16
  shogiBoard = deepcopy(setupT())
end

 for p in moves
  flag = true
  flag, shogiBoard = deepcopy(next_state(deepcopy(shogiBoard),p))

  if shogiBoard.move.move_type == "resign"
    if team == 'b'
      println("black resigned")
      return 'w'
    elseif team == 'w'
      println("white resigned")
      return 'b'
    end
  end

  key = join(shogiBoard.board)
  capturedP = get(piecesCaptured, (key,team),0)
  if getCapturedPieces(shogiBoard)==capturedP
    sameStates[key,team]=get(sameStates,(key,team),0)+1 #increment number of same state with same captured pieces
  else
    piecesCaptured[key,team] = getCapturedPieces(shogiBoard)
  end

  count = get(sameStates,(key,team),0)

  if count >= 10 #same board state with same player and same pieces in hand ocurred 4 times.
    println("same state found 10 times. Player: ",team)

    if team == 'b'
      return 'w'
    elseif team == 'w'
      return 'b'
    end
  end
    #check if King is captured and the other player wins
  king = getKing(shogiBoard,team)
  otherKing = getKing(shogiBoard, otherTeam)

  if king.captured == true && king.team == 'b'
    println("W")
    return 'w'
  elseif king.captured == true && king.team == 'w'
    println("B")
    return 'b'
  end
  if otherKing.captured == true && otherKing.team == 'b'
    print("W")
    return 'w'
  elseif otherKing.captured == true && otherKing.team=='w'
    println("B")
    return 'b'
  end
end #of for loope
return 'n'
end



function evaluateMove(shogiBoard::shogiData,team::Char)
  who2Move = 0
  black = -1
  white = 1
  if team == 'b'
   who2Move = black
  elseif team == 'w'
   who2Move = white
  end

  local king::piece
  for p in shogiBoard.pieces
      if p.name == "king" && p.team == team
          king = p
      end
  end
  boardSize = size(shogiBoard.board)[1]
  myBoard = Array{String}(boardSize,boardSize)

  for i = 1:boardSize
    for j =1:boardSize
      myBoard[i,j]=" "
    end
  end


  #count number of remaining pieces on the board
	numOfWhitePieces =  Dict("bishop"=>0,"bishop_general"=>0,"blind_tiger"=>0,"chariot_soldier"=>0,"copper_general"=>0,"dog"=>0,"dragon_horse"=>0,"dragon_king"=>0,"drunk_elephant"=>0,"ferocious_leopard"=>0,"fire_demon"=>0,"free_eagle"=>0,
													"go_between"=>0,"gold_general"=>0,"great_general"=>0,"horned_falcon"=>0,"heavenly_tetrarch"=>0,"iron_general"=>0,"king"=>0,"kirin"=>0,"knight"=>0,"lance"=>0,"lion"=>0,
                          "lion_hawk"=>0, "pawn"=>0, "phoenix"=>0, "queen"=>0, "reverse_chariot"=>0,"rook"=>0, "rook_general"=>0,"side_mover"=>0, "side_soldier"=>0,
                          "silver_general"=>0, "soaring_eagle"=>0, "vertical_mover"=>0,"vertical_soldier"=>0,"vice_general"=>0, "water_buffalo"=>0)

 numOfBlackPieces =  Dict("bishop"=>0,"bishop_general"=>0,"blind_tiger"=>0,"chariot_soldier"=>0,"copper_general"=>0,"dog"=>0,"dragon_horse"=>0,"dragon_king"=>0,"drunk_elephant"=>0,"ferocious_leopard"=>0,"fire_demon"=>0,"free_eagle"=>0,
                         "go_between"=>0,"gold_general"=>0,"great_general"=>0,"horned_falcon"=>0,"heavenly_tetrarch"=>0,"iron_general"=>0,"king"=>0,"kirin"=>0,"knight"=>0,"lance"=>0,"lion"=>0,
                         "lion_hawk"=>0, "pawn"=>0, "phoenix"=>0, "queen"=>0, "reverse_chariot"=>0,"rook"=>0, "rook_general"=>0,"side_mover"=>0, "side_soldier"=>0,
                         "silver_general"=>0, "soaring_eagle"=>0, "vertical_mover"=>0,"vertical_soldier"=>0,"vice_general"=>0, "water_buffalo"=>0)

	numOfPromotedWhitePieces = Dict("bishop"=>0,"bishop_general"=>0,"blind_tiger"=>0,"chariot_soldier"=>0,"copper_general"=>0,"dog"=>0,"dragon_horse"=>0,"dragon_king"=>0,"drunk_elephant"=>0,"ferocious_leopard"=>0,"fire_demon"=>0,"free_eagle"=>0,
													"go_between"=>0,"gold_general"=>0,"great_general"=>0,"horned_falcon"=>0,"heavenly_tetrarch"=>0,"iron_general"=>0,"king"=>0,"kirin"=>0,"knight"=>0,"lance"=>0,"lion"=>0,
                          "lion_hawk"=>0, "pawn"=>0, "phoenix"=>0, "queen"=>0, "reverse_chariot"=>0,"rook"=>0, "rook_general"=>0,"side_mover"=>0, "side_soldier"=>0,
                          "silver_general"=>0, "soaring_eagle"=>0, "vertical_mover"=>0,"vertical_soldier"=>0,"vice_general"=>0, "water_buffalo"=>0)

	numOfPromotedBlackPieces =Dict("bishop"=>0,"bishop_general"=>0,"blind_tiger"=>0,"chariot_soldier"=>0,"copper_general"=>0,"dog"=>0,"dragon_horse"=>0,"dragon_king"=>0,"drunk_elephant"=>0,"ferocious_leopard"=>0,"fire_demon"=>0,"free_eagle"=>0,
													"go_between"=>0,"gold_general"=>0,"great_general"=>0,"horned_falcon"=>0,"heavenly_tetrarch"=>0,"iron_general"=>0,"king"=>0,"kirin"=>0,"knight"=>0,"lance"=>0,"lion"=>0,
                          "lion_hawk"=>0, "pawn"=>0, "phoenix"=>0, "queen"=>0, "reverse_chariot"=>0,"rook"=>0, "rook_general"=>0,"side_mover"=>0, "side_soldier"=>0,
                          "silver_general"=>0, "soaring_eagle"=>0, "vertical_mover"=>0,"vertical_soldier"=>0,"vice_general"=>0, "water_buffalo"=>0)

  DBlackKing =Dict("bishop"=>0,"bishop_general"=>0,"blind_tiger"=>0,"chariot_soldier"=>0,"copper_general"=>0,"dog"=>0,"dragon_horse"=>0,"dragon_king"=>0,"drunk_elephant"=>0,"ferocious_leopard"=>0,"fire_demon"=>0,"free_eagle"=>0,
                        				"go_between"=>0,"gold_general"=>0,"great_general"=>0,"heavenly_tetrarch"=>0,"horned_falcon"=>0,"iron_general"=>0,"king"=>0,"kirin"=>0,"knight"=>0,"lance"=>0,"lion"=>0,
                                "lion_hawk"=>0, "phoenix"=>0, "queen"=>0, "reverse_chariot"=>0,"rook"=>0, "rook_general"=>0,"side_mover"=>0, "side_soldier"=>0,
                                "silver_general"=>0, "soaring_eagle"=>0, "vertical_mover"=>0,"vertical_soldier"=>0,"vice_general"=>0, "water_buffalo"=>0)

  DWhiteKing =Dict("bishop"=>0,"bishop_general"=>0,"blind_tiger"=>0,"chariot_soldier"=>0,"copper_general"=>0,"dog"=>0,"dragon_horse"=>0,"dragon_king"=>0,"drunk_elephant"=>0,"ferocious_leopard"=>0,"fire_demon"=>0,"free_eagle"=>0,
                  "go_between"=>0,"gold_general"=>0,"great_general"=>0,"horned_falcon"=>0,"heavenly_tetrarch"=>0,"iron_general"=>0,"king"=>0,"kirin"=>0,"knight"=>0,"lance"=>0,"lion"=>0,
                  "lion_hawk"=>0, "phoenix"=>0, "queen"=>0, "reverse_chariot"=>0,"rook"=>0, "rook_general"=>0,"side_mover"=>0, "side_soldier"=>0,
                  "silver_general"=>0, "soaring_eagle"=>0, "vertical_mover"=>0,"vertical_soldier"=>0,"vice_general"=>0, "water_buffalo"=>0)

  pieceWts = Dict("bishop"=>10,"bishop_general"=>21,"blind_tiger"=>3,"chariot_soldier"=>18,"copper_general"=>2,"dog"=>1,"dragon_horse"=>12,"dragon_king"=>14,"drunk_elephant"=>3,"ferocious_leopard"=>3,"fire_demon"=>83,"free_eagle"=>22,
													"go_between"=>0,"gold_general"=>3,"great_general"=>45,"horned_falcon"=>19,"heavenly_tetrarch"=>12,"iron_general"=>2,"king"=>500,"kirin"=>3,"knight"=>1,"lance"=>6,"lion"=>18,
                          "lion_hawk"=>25, "pawn"=>1, "phoenix"=>3, "queen"=>22, "reverse_chariot"=>6,"rook"=>12, "rook_general"=>23,"side_mover"=>7, "side_soldier"=>7,
                          "silver_general"=>2, "soaring_eagle"=>18, "vertical_mover"=>7,"vertical_soldier"=>8,"vice_general"=>39, "water_buffalo"=>17)



  promotedPieceWts = Dict("bishop"=>12,"bishop_general"=>39,"blind_tiger"=>9,"chariot_soldier"=>12,"copper_general"=>7,"dog"=>5,"dragon_horse"=>19,"dragon_king"=>18,"drunk_elephant"=>4,"ferocious_leopard"=>10,"fire_demon"=>83,"free_eagle"=>22,
													"go_between"=>0,"gold_general"=>10,"great_general"=>45,"heavenly_tetrarch"=>12,"horned_falcon"=>21,"iron_general"=>8,"king"=>500,"kirin"=>18,"knight"=>7,"lance"=>14,"lion"=>25,
                          "lion_hawk"=>25, "pawn"=>3, "phoenix"=>22, "queen"=>22, "reverse_chariot"=>10,"rook"=>17, "rook_general"=>45,"side_mover"=>16, "side_soldier"=>17,
                          "silver_general"=>7, "soaring_eagle"=>23, "vertical_mover"=>16,"vertical_soldier"=>18,"vice_general"=>39, "water_buffalo"=>83)


	pieceNames = ["bishop","bishop_general","blind_tiger","chariot_soldier","copper_general","dog","dragon_horse","dragon_king","drunk_elephant","ferocious_leopard","fire_demon","free_eagle",
												"go_between",	"gold_general","great_general","heavenly_tetrarch","horned_falcon","iron_general","king","kirin","knight","lance","lion",
                          "lion_hawk", "pawn", "phoenix", "queen", "reverse_chariot","rook", "rook_general","side_mover", "side_soldier",
                          "silver_general", "soaring_eagle", "vertical_mover","vertical_soldier","vice_general", "water_buffalo"]

  for piece in shogiBoard.pieces
    if piece.team == 'w' && piece.captured == false
      if piece.promoted == true
        numOfPromotedWhitePieces[piece.name]=numOfPromotedWhitePieces[piece.name]+1
			elseif piece.promoted == false
				numOfWhitePieces[piece.name]=numOfWhitePieces[piece.name]+1
      end

    elseif piece.team == 'b' && piece.captured == false
			if piece.promoted == true
        numOfPromotedBlackPieces[piece.name]=numOfPromotedBlackPieces[piece.name]+1
			elseif piece.promoted == false
			numOfBlackPieces[piece.name]=numOfBlackPieces[piece.name]+1
      end
	  end
    if piece.captured == false
        pName = string(piece.name,piece.team)
      if piece.promoted == true
        pName = uppercase(pName)
      end
      myBoard[piece.sourcex,piece.sourcey] = pName
    end
  end


  score = 0

	for i in pieceNames
			score += (pieceWts[i]*(numOfWhitePieces[i]-numOfBlackPieces[i]))
			score += (promotedPieceWts[i]*(numOfPromotedWhitePieces[i]-numOfPromotedBlackPieces[i]))
	end

  score=score*who2Move
  x = inDanger(shogiBoard,myBoard,team)
  y = futureAttack(shogiBoard,myBoard,team)
  score += (y/4)
  score += x

 return score
end


   function removeRepeatedStates(states::Dict{String,Int}, move_states::Vector{Tuple{moveTable,Float64,String}},player::Char)
     i = 1
     x = length(move_states)

    while i <= x
      key = string(move_states[i][3],player)
      visits = get(states,key,-1)
      if visits > 1
      #  println("move deleted: ",move_states[i][1])
        filter!(e->e!=move_states[i],move_states)
        deleted = true
        x = length(move_states)
     else
      states[key] = get(states,key,0)+1
      i += 1
     end

   end

  end

    function stringToArray(str::String,shogiBoard::shogiData)
      boardSize = size(shogiBoard.board)
      arr = Array{Char}(boardSize[1],boardSize[2])
      for i=1:boardSize[1]
        for j=1:boardSize[2]
          arr[j,i]=str[(i-1)*boardSize[1]+j]
        end
      end
      return arr
    end

    function getCapturedPieces(shogiBoard::shogiData)
      team = 'b'
      if shogiBoard.move.move_number % 2 == 1 # this is to take into account next_state incrementing move_number
        team = 'w'
      end
      count = String("")
      for piece in shogiBoard.pieces
        if piece.captured == true && piece.team != team
          string(count,piece.name)
        end
      end
      return count
    end

    function futureAttack(state::shogiData,myBoard::Array{String},team::Char)
      state.move.move_number = state.move.move_number - 1
      plays = generateMoves(state)
      state.move.move_number = state.move.move_number + 1
      boardSize = state.move.boardSize
      piecesUnderAttack = Vector{String}(0)
      attackers = Vector{Tuple{String,Int,Int}}(0)
      for p in plays

        #println("enPlay: ",p)
        x1 = p.targetx
        y1 = p.targety
        if x1 < 1 || x1 > boardSize || y1 < 1 || y1 > boardSize
          continue
        end

        attacker = myBoard[p.sourcex,p.sourcey]
        target = myBoard[x1,y1]
        targetTeam = lowercase(target[length(target)])

        if targetTeam == team
          continue
        end

        if attacker != target && target!=" "

            #=println("1064: ")
            println("attacker: ",attacker)
            println("target: ",target)=#

          push!(attackers,(attacker,x1,y1))
        end

        x2 = p.targetx2
        y2 = p.targety2
        if x2 < 1 || x2 > boardSize || y2 < 1 || y2 > boardSize
          continue
        end
        target = myBoard[x2,y2]
        targetTeam = lowercase(target[length(target)])
        if targetTeam == team
          continue
        end
        if attacker != target && target!=" "
          push!(attackers,(attacker,x2,y2))
        end

        x3 = p.targetx3
        y3 = p.targety3
        if x3 < 1 || x3 > boardSize || y3 < 1 || y3 > boardSize
          continue
        end
        target = myBoard[x3,y3]
        targetTeam = lowercase(target[length(target)])
        if targetTeam == team
          continue
        end

        if attacker != target && target!=" "
          push!(attackers,(attacker,x3,y3))
        end

        x4 = p.targetx4
        y4 = p.targety4
        if x4 < 1 || x4 > boardSize || y4 < 1 || y4 > boardSize
          continue
        end
        target = myBoard[x4,y4]
        targetTeam = lowercase(target[length(target)])
        if targetTeam == team
          continue
        end
        if attacker != target && target!=" "
          push!(attackers,(attacker,x4,y4))
        end
      end

      Victims = Vector{Tuple{String,Int,Int,String}}(0)
      for i = 1:length(attackers)
        victim = myBoard[attackers[i][2],attackers[i][3]]
        if victim == " "
          continue
        end
        victimTeam = lowercase(victim[length(victim)])
        attackPiece = attackers[i][1]
        attackTeam = lowercase(attackPiece[length(attackPiece)])
        #=println("1114 attackPiece: ",attackPiece)
        println("1115 victim: ",victim)
        println("victimTeam: ",victimTeam)
        println("attackTeam: ",attackTeam)=#
        if attackTeam == victimTeam
          continue
        end
        push!(Victims,(attackPiece,attackers[i][2],attackers[i][3],victim))
      end
      score = 0
      if length(Victims) > 0
        for v in Victims
        #  println("currentl_player attacking: ",v)
        end
        score = isProtectedTwo(myBoard,state,Victims)
        #  println("attackScore: ",score)
      end

      return score * -1
    end

    function isProtectedTwo(myBoard::Array{String},shogiBoard::shogiData,Victims::Vector{Tuple{String,Int,Int,String}})

      pieceWts = Dict("bishop"=>10,"bishop_general"=>21,"blind_tiger"=>3,"chariot_soldier"=>18,"copper_general"=>2,"dog"=>1,"dragon_horse"=>12,"dragon_king"=>14,"drunk_elephant"=>3,"ferocious_leopard"=>3,"fire_demon"=>83,"free_eagle"=>22,
                              "go_between"=>2,"gold_general"=>3,"great_general"=>45,"horned_falcon"=>19,"heavenly_tetrarch"=>12,"iron_general"=>2,"king"=>500,"kirin"=>3,"knight"=>1,"lance"=>6,"lion"=>18,
                              "lion_hawk"=>25, "pawn"=>1, "phoenix"=>3, "queen"=>22, "reverse_chariot"=>6,"rook"=>12, "rook_general"=>23,"side_mover"=>7, "side_soldier"=>7,
                              "silver_general"=>2, "soaring_eagle"=>18, "vertical_mover"=>7,"vertical_soldier"=>8,"vice_general"=>39, "water_buffalo"=>17)



      promotedPieceWts = Dict("bishop"=>12,"bishop_general"=>39,"blind_tiger"=>9,"chariot_soldier"=>12,"copper_general"=>7,"dog"=>5,"dragon_horse"=>19,"dragon_king"=>18,"drunk_elephant"=>4,"ferocious_leopard"=>10,"fire_demon"=>83,"free_eagle"=>22,
                              "go_between"=>2,"gold_general"=>10,"great_general"=>45,"heavenly_tetrarch"=>12,"horned_falcon"=>21,"iron_general"=>8,"king"=>500,"kirin"=>18,"knight"=>7,"lance"=>14,"lion"=>25,
                              "lion_hawk"=>25, "pawn"=>3, "phoenix"=>22, "queen"=>22, "reverse_chariot"=>10,"rook"=>17, "rook_general"=>45,"side_mover"=>16, "side_soldier"=>17,
                              "silver_general"=>7, "soaring_eagle"=>23, "vertical_mover"=>16,"vertical_soldier"=>18,"vice_general"=>39, "water_buffalo"=>83)

      piecesUnderAttack = Vector{Tuple{String,Int,Int,Char}}(0)
      score = 0
      vicIndex = Dict{Tuple{String,Int,Int,Char},Int}()
      attackers = Vector{Vector{String}}(length(Victims))
      i = 0
      for (attacker,x,y,victim) in Victims

        if victim == " "
          continue
        end

        boardSize = shogiBoard.move.boardSize
        victimWt = 0
        attackWt = 0
        team = lowercase(victim[length(victim)])
        attackTeam = lowercase(attacker[length(attacker)])
        victim = chop(victim)
        attacker = chop(attacker)

        if attackTeam == team
          continue
        end

        if isuppercase(victim) == true
          victimWt = promotedPieceWts[lowercase(victim)]
        else
          victimWt = pieceWts[lowercase(victim)]
        end

        if isuppercase(attacker) == true
          attackWt = promotedPieceWts[lowercase(attacker)]
        else
          attackWt = pieceWts[lowercase(attacker)]
        end

        if victimWt > attackWt #if weight of victim > attacker weight, victim under attack is true
          score += victimWt
          #println("1175 attacker: ",attacker)
          #println("victim: ",victim)
          continue

        else
          idx = get(vicIndex,(victim,x,y,team),-1)
          if idx > 0
            push!(attackers[idx],attacker)
          elseif idx == -1
           #if victim not in vicIndex, make a new entry in dict and array
            i += 1
            vicIndex[(victim,x,y,team)] = i
            attackers[i] = Vector{String}(0)
            push!(attackers[i],attacker)
          end
        end
      end

      for key in collect(keys(vicIndex))
        team = key[4]
        x = key[2]
        y = key[3]
        vic = key[1]
        #println("line 1202 victimTeam: ",team)
        #println("line 1202 victim: ",vic)

        protectorsOne = isProtectedUtil(myBoard,team,x,y)

        protectorsTwo = isProtectedUtilTwo(myBoard,team,x,y)

        aggressors = attackers[vicIndex[key]]
        #println("966 aggressors: ",aggressors)
      #  println("967 p2: ",protectorsTwo)
      #  println("968 p1: ",protectorsOne)
        append!(protectorsOne,protectorsTwo)

        numProtectors = length(protectorsOne)
        numAggrs = length(aggressors)

        if numAggrs <= 1 && numProtectors >= 1
          continue
        else
        aggrWts = Array{Int}(0)
        prtrWts = Array{Int}(0)

        for i = 1:numAggrs
            #println(" 1223 aggressors: ",aggressors[i])
          if isuppercase(aggressors[i]) == true
             wt = promotedPieceWts[lowercase(aggressors[i])]
          else
            wt = pieceWts[lowercase(aggressors[i])]
          end

          push!(aggrWts,wt)
        end

        for i = 1:numProtectors
            #println(" 1233 protect: ",protectorsOne[i])
          wt = 0
          if isuppercase(protectorsOne[i]) == true
            wt = promotedPieceWts[lowercase(protectorsOne[i])]
          else
            wt = pieceWts[lowercase(protectorsOne[i])]
          end
            push!(prtrWts,wt)
          end

          sort!(aggrWts)
          sort!(prtrWts)
          len = min(numProtectors,numAggrs)

          for i = 1:len
            score -= aggrWts[i]
            score += prtrWts[i]
          end
          score += pieceWts[lowercase(vic)]
          end
        end
       #println("1259 score: ",score)
      return score
    end

    function inDanger(state::shogiData,myBoard::Array{String},team::Char)

      plays = generateMoves(state)

      boardSize = state.move.boardSize
      piecesUnderAttack = Vector{String}(0)
      attackers = Vector{Tuple{String,Int,Int}}(0)
      for p in plays

        #println("enPlay: ",p)
        x1 = p.targetx
        y1 = p.targety
        if x1 < 1 || x1 > boardSize || y1 < 1 || y1 > boardSize
          continue
        end

        attacker = myBoard[p.sourcex,p.sourcey]
        target = myBoard[x1,y1]
        targetTeam = lowercase(target[length(target)])

        if targetTeam != team
          continue
        end

        if attacker != target && target!=" "

            #=println("1064: ")
            println("attacker: ",attacker)
            println("target: ",target)=#

          push!(attackers,(attacker,x1,y1))
        end

        x2 = p.targetx2
        y2 = p.targety2
        if x2 < 1 || x2 > boardSize || y2 < 1 || y2 > boardSize
          continue
        end
        target = myBoard[x2,y2]
        targetTeam = lowercase(target[length(target)])
        if targetTeam != team
          continue
        end
        if attacker != target && target!=" "
          push!(attackers,(attacker,x2,y2))
        end

        x3 = p.targetx3
        y3 = p.targety3
        if x3 < 1 || x3 > boardSize || y3 < 1 || y3 > boardSize
          continue
        end
        target = myBoard[x3,y3]
        targetTeam = lowercase(target[length(target)])
        if targetTeam != team
          continue
        end

        if attacker != target && target!=" "
          push!(attackers,(attacker,x3,y3))
        end

        x4 = p.targetx4
        y4 = p.targety4
        if x4 < 1 || x4 > boardSize || y4 < 1 || y4 > boardSize
          continue
        end
        target = myBoard[x4,y4]
        targetTeam = lowercase(target[length(target)])
        if targetTeam != team
          continue
        end
        if attacker != target && target!=" "&& (x4 > 0 && y4 > 0)
          push!(attackers,(attacker,x4,y4))
        end
      end

      Victims = Vector{Tuple{String,Int,Int,String}}(0)
      for i = 1:length(attackers)
        victim = myBoard[attackers[i][2],attackers[i][3]]
        if victim == " "
          continue
        end
        victimTeam = lowercase(victim[length(victim)])
        attackPiece = attackers[i][1]
        attackTeam = lowercase(attackPiece[length(attackPiece)])
        #=println("1114 attackPiece: ",attackPiece)
        println("1115 victim: ",victim)
        println("victimTeam: ",victimTeam)
        println("attackTeam: ",attackTeam)=#
        if attackTeam == victimTeam
          continue
        end
        push!(Victims,(attackPiece,attackers[i][2],attackers[i][3],victim))

      end
      score = 0
      if length(Victims) > 0
        for v in Victims
          #println("currentl_player being attacked: ",v)
        end
        score = isProtected(myBoard,state,Victims)
        #println("inDangerScore: ",score)
      end

      return score
    end

    function isProtected(myBoard::Array{String},shogiBoard::shogiData,Victims::Vector{Tuple{String,Int,Int,String}})

      pieceWts = Dict("bishop"=>10,"bishop_general"=>21,"blind_tiger"=>3,"chariot_soldier"=>18,"copper_general"=>2,"dog"=>1,"dragon_horse"=>12,"dragon_king"=>14,"drunk_elephant"=>3,"ferocious_leopard"=>3,"fire_demon"=>83,"free_eagle"=>22,
                              "go_between"=>2,"gold_general"=>3,"great_general"=>45,"horned_falcon"=>19,"heavenly_tetrarch"=>12,"iron_general"=>2,"king"=>500,"kirin"=>3,"knight"=>1,"lance"=>6,"lion"=>18,
                              "lion_hawk"=>25, "pawn"=>1, "phoenix"=>3, "queen"=>22, "reverse_chariot"=>6,"rook"=>12, "rook_general"=>23,"side_mover"=>7, "side_soldier"=>7,
                              "silver_general"=>2, "soaring_eagle"=>18, "vertical_mover"=>7,"vertical_soldier"=>8,"vice_general"=>39, "water_buffalo"=>17)



      promotedPieceWts = Dict("bishop"=>12,"bishop_general"=>39,"blind_tiger"=>9,"chariot_soldier"=>12,"copper_general"=>7,"dog"=>5,"dragon_horse"=>19,"dragon_king"=>18,"drunk_elephant"=>4,"ferocious_leopard"=>10,"fire_demon"=>83,"free_eagle"=>22,
                              "go_between"=>2,"gold_general"=>10,"great_general"=>45,"heavenly_tetrarch"=>12,"horned_falcon"=>21,"iron_general"=>8,"king"=>500,"kirin"=>18,"knight"=>7,"lance"=>14,"lion"=>25,
                              "lion_hawk"=>25, "pawn"=>3, "phoenix"=>22, "queen"=>22, "reverse_chariot"=>10,"rook"=>17, "rook_general"=>45,"side_mover"=>16, "side_soldier"=>17,
                              "silver_general"=>7, "soaring_eagle"=>23, "vertical_mover"=>16,"vertical_soldier"=>18,"vice_general"=>39, "water_buffalo"=>83)

      piecesUnderAttack = Vector{Tuple{String,Int,Int,Char}}(0)
      score = 0
      vicIndex = Dict{Tuple{String,Int,Int,Char},Int}()
      attackers = Vector{Vector{String}}(length(Victims))
      i = 0
      for (attacker,x,y,victim) in Victims

        if victim == " "
          continue
        end

        boardSize = shogiBoard.move.boardSize
        victimWt = 0
        attackWt = 0
        team = lowercase(victim[length(victim)])
        attackTeam = lowercase(attacker[length(attacker)])
        victim = chop(victim)
        attacker = chop(attacker)

        if attackTeam == team
          continue
        end

        if isuppercase(victim) == true
          victimWt = promotedPieceWts[lowercase(victim)]
        else
          victimWt = pieceWts[lowercase(victim)]
        end

        if isuppercase(attacker) == true
          attackWt = promotedPieceWts[lowercase(attacker)]
        else
          attackWt = pieceWts[lowercase(attacker)]
        end

        if victimWt > attackWt #if weight of victim > attacker weight, victim under attack is true
          score -= victimWt
          #println("1175 attacker: ",attacker)
          #println("victim: ",victim)
          continue

        else
          idx = get(vicIndex,(victim,x,y,team),-1)
          if idx > 0
            push!(attackers[idx],attacker)
          elseif idx == -1
           #if victim not in vicIndex, make a new entry in dict and array
            i += 1
            vicIndex[(victim,x,y,team)] = i
            attackers[i] = Vector{String}(0)
            push!(attackers[i],attacker)
          end
        end
      end

      for key in collect(keys(vicIndex))
        team = key[4]
        x = key[2]
        y = key[3]
        vic = key[1]
        #println("line 1202 victimTeam: ",team)
        #println("line 1202 victim: ",vic)
        protectorsOne = isProtectedUtil(myBoard,team,x,y)

        protectorsTwo = isProtectedUtilTwo(myBoard,team,x,y)

        aggressors = attackers[vicIndex[key]]
      #  println("1209 aggressors: ",aggressors)
    #  println("1210 p2: ",protectorsTwo)
      #  println("1211 p1: ",protectorsOne)
        append!(protectorsOne,protectorsTwo)

        numProtectors = length(protectorsOne)
        numAggrs = length(aggressors)

        if numAggrs <= 1 && numProtectors >= 1
          continue
        else
          aggrWts = Array{Int}(0)
          prtrWts = Array{Int}(0)

          for i = 1:numAggrs
            #println(" 1223 aggressors: ",aggressors[i])
            if isuppercase(aggressors[i]) == true
               wt = promotedPieceWts[lowercase(aggressors[i])]
            else
              wt = pieceWts[lowercase(aggressors[i])]
            end
            push!(aggrWts,wt)
          end

          for i = 1:numProtectors
            #println(" 1233 protect: ",protectorsOne[i])
            wt = 0
            if isuppercase(protectorsOne[i]) == true
               wt = promotedPieceWts[lowercase(protectorsOne[i])]
            else
              wt = pieceWts[lowercase(protectorsOne[i])]
            end
            push!(prtrWts,wt)

          end

          sort!(aggrWts)
          sort!(prtrWts)
          len = min(numProtectors,numAggrs)

          for i = 1:len
            score -= prtrWts[i]
            score += prtrWts[i]
          end
          score -= pieceWts[lowercase(vic)]
          end
        end
      #  println("1259 score: ",score)
      return score
    end

    function isProtectedUtil(myBoard::Array{String},team::Char,targetx::Int,targety::Int)

      moveDict = Dict("pawn"=>((0,0),(1,0)),
                      "silver_general"=>((-1, -1), (-1, 1), (1, -1), (1, 0), (1,1)),
                      "knight"=>((2, -1), (2, 1)),
                      "gold_general"=>((-1, 0), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)),
                      "king"=>((-1,-1),(-1,0),(-1,1),(0,1),(1,1),(1,0),(1,-1),(0,-1)),
                      "prince"=>((-1,-1),(-1,0),(-1,1),(0,1),(1,1),(1,0),(1,-1),(0,-1)),
                      "side_mover"=>((1,0),(-1,0)),
                      "vertical_mover"=>((0,1),(0,-1)),
                      "horned_falcon"=>((1,0),(2,0)),
                      "go_between"=>((1,0),(-1,0)),
                      "soaring_eagle"=>((1,-1),(1,1),(2,-2),(2,2)),
                      "blind_tiger"=>((-1,-1),(-1,0),(-1,1),(0,1),(1,1),(1,-1),(0,-1)),
                      "ferocious_leopard"=>((-1,-1),(-1,0),(-1,1),(1,1),(1,0),(1,-1)),
                      "copper_general"=>((-1,0),(1,1),(1,0),(1,-1)),
                      "kirin"=>((-1,-1),(-1,1),(1,-1),(1,1),(2,0),(-2,0),(0,2),(0,-2)),
                      "phoenix"=>((1,0),(-1,0),(0,1),(0,-1),(-2,-2),(-2,2),(2,-2),(2,2)),
                      "heavenly_tetrarch"=>((0,1),(0,2),(0,-1),(0,-2))
                      )

     promotedMoveDict = Dict("rook"=>((-1, -1), (-1, 1), (-1, 1), (1, 1)),
                             "bishop"=>((-1, 0), (1, 0), (0, -1), (0, 1)),
                             "silver_general"=>((-1, 0), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)),
                             "knight"=>((-1, 0), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)),
                             "lance"=>((-1, 0), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)),
                             "pawn"=>((-1, 0), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)),
                             "king"=>((-1,-1),(-1,0),(-1,1),(0,1),(1,1),(1,0),(1,-1),(0,-1)),
                             "gold_general"=>((-1, 0), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)),
                            "prince"=>((-1,-1),(-1,0),(-1,1),(0,1),(1,1),(1,0),(1,-1),(0,-1)),
                            "dragon_horse"=>((1,0),(2,0)),
                            "dragon_king"=>((1,-1),(1,1),(2,-2),(2,2)),
                            "go_between"=>((-1,-1),(-1,1),(0,1),(1,1),(1,0),(1,-1),(0,-1)),
                            "flying_stag"=>((-1,-1),(-1,1),(0,1),(1,1),(1,-1),(0,-1)),
                            "blind_tiger"=>((-1,-1),(-1,1),(0,1),(1,1),(1,-1),(0,-1)),
                            "copper_general"=>((1,0),(-1,0)),
                            "side_mover"=>((1,0),(-1,0)),
                            "heavenly_tetrarch"=>((0,1),(0,2),(0,-1),(0,-2))
                             )
     protectors = Vector{Tuple{String,Int,Int}}(0)
     finalProtectors = Vector{String}(0)
     boardSize = size(myBoard)[1]
     for j = -3:3
       for i = -3:3
         x = targetx
         y = targety

         if i == 0 && j == 0
           continue
         end
         if (x+i < 1 || x+i > boardSize) || (y+j <1 || y+j > boardSize)
           continue
         end
         protector = myBoard[x+i,y+j]
         if protector == " "
           continue
         end
         protectorTeam = lowercase(protector[length(protector)])
         protector = chop(myBoard[x+i,y+j])
         #  println("protector: ",protector)

         if protectorTeam != team
           continue
         else
             push!(protectors,(protector,x+i,y+j))
         end
       end
     end

     for (protector,sourcex,sourcey) in protectors
      promoted = false
      orientation = 1
      if team == 'b'
        orientation = -1
      end

      if isuppercase(protector) == true
        protector = lowercase(protector)
        promoted = true
      end
      moves = get(moveDict,protector,-1)
      if promoted == true
        moves =get(promotedMoveDict,protector,-1)
      end
      if moves == -1
        continue
      end

        for i = 1:length(moves)
          dy = (moves[i][1] * orientation) + sourcey
          dx = (moves[i][2] * orientation) + sourcex

          if dx == targetx && dy == targety
            #println("1327 protector: ",protector)
            push!(finalProtectors,protector)
          end
        end
    end

      return finalProtectors
    end

    function isProtectedUtilTwo(myBoard::Array{String},team::Char,targetx::Int,targety::Int)
      boardSize = size(myBoard)[1]
      rearVerticalProtectors = Dict("PHOENIX"=>1,"white_horse"=>1,"WHITE_HORSE"=>1,"horned_falcon"=>1,"HORNED_FALCON"=>1,"DRAGON_HORSE"=>1,"VERTICAL_MOVER"=>1,"WHALE"=>1,"whale"=>1,"REVERSE_CHARIOT"=>1,"LANCE"=>1,"rook"=>1,"ROOK"=>1,"SOARING_EAGLE"=>1,"soaring_eagle"=>1,"DRAGON_KING"=>1,"reverse_chariot"=>1,"flying_stag"=>1,"BLIND_TIGER"=>1,"queen"=>1,"great_general"=>1)
      frontVerticalProtectors = Dict("PHOENIX"=>1,"white_horse"=>1,"WHITE_HORSE"=>1,"VERTICAL_MOVER"=>1,"WHALE"=>1,"whale"=>1,"REVERSE_CHARIOT"=>1,"LANCE"=>1,"ROOK"=>1,"rook"=>1,"soaring_eagle"=>1,"SOARING_EAGLE"=>1,"DRAGON_KING"=>1,"reverse_chariot"=>1,"flying_stag"=>1,"BLIND_TIGER"=>1,"queen"=>1,"great_general"=>1)
      sideProtectors = Dict("PHOENIX"=>1,"COPPER_GENERAL"=>1,"side_mover"=>1,"horned_falcon"=>1,"HORNED_FALCON"=>1,"DRAGON_HORSE"=>1,"rook"=>1,"ROOK"=>1,"soaring_eagle"=>1,"SOARING_EAGLE"=>1,"DRAGON_KING"=>1,"queen"=>1,"great_general"=>1,"fire_demon"=>1,"FIRE_DEMON"=>1)
      rearDiagonalProtectors = Dict("VERTICAL_MOVER"=>1,"heavenly_tetrarch"=>1,"HEAVENLY_TETRARCH"=>1,"PHOENIX"=>1,"FEROCIOUS_LEOPARD"=>1,"BISHOP"=>1,"WHALE"=>1,"whale"=>1,"REVERSE_CHARIOT"=>1,"bishop"=>1,"VERTICAL_MOVER"=>1,"SIDE_MOVER"=>1,"horned_falcon"=>1,"DRAGON_HORSE"=>1,"flying_ox"=>1,"free_boar"=>1,"soaring_eagle"=>1,"SOARING_EAGLE"=>1,"DRAGON_KING"=>1,"queen"=>1,"vice_general"=>1,"great_general"=>1,"fire_demon"=>1,"FIRE_DEMON"=>1)
      frontDiagonalProtectors = Dict("VERTICAL_MOVER"=>1,"heavenly_tetrarch"=>1,"HEAVENLY_TETRARCH"=>1,"PHOENIX"=>1,"FEROCIOUS_LEOPARD"=>1,"BISHOP"=>1,"white_horse"=>1,"WHITE_HORSE"=>1,"LANCE"=>1,"bishop"=>1,"VERTICAL_MOVER"=>1,"SIDE_MOVER"=>1,"horned_falcon"=>1,"HORNED_FALCON"=>1,"DRAGON_HORSE"=>1,"flying_ox"=>1,"free_boar"=>1,"queen"=>1,"vice_general"=>1,"great_general"=>1,"fire_demon"=>1,"FIRE_DEMON"=>1)
      protectors = Vector{String}(0)
      noBlockDiagonalProtectors = Dict("bishop_general"=>1,"BISHOP_GENERAL"=>1,"vice_general"=>1,"VICE_GENERAL"=>1,"great_general"=>1,"GREAT_GENERAL"=>1)
      noBlockOrthogonalProtectors = Dict("rook_general"=>1,"ROOK_GENERAL"=>1,"great_general"=>1,"GREAT_GENERAL"=>1)

      orientation = 1
      if team == 'b'
        orientation = -1
      end

        #check up
      x = targetx
      y = targety
      y += (1 * orientation)
      blocked = false
      while x > 0 && x <= boardSize && y > 0 && y <= boardSize
        protector = myBoard[x,y]

        if protector == " "
          y += (1 * orientation)
          continue
        end
        pTeam = lowercase(protector[length(protector)])
        protector = chop(protector)

        if abs(y-targety) < 3 && blocked == false && pTeam == team && (protector == "lion" ||protector == "LION"|| protector == "KIRIN"||protector == "fire_demon" || protector == "FIRE_DEMON" )
          push!(protectors,protector)
          blocked = true
        end

        if abs(y-targety) < 2 && blocked == false && pTeam == team && ( protector == "heavenly_tetrarch" || protector == "HEAVENLY_TETRARCH")
           push!(protectors,protector)
          blocked = true
       end
       if pTeam == team && get(noBlockOrthogonalProtectors,protector,-1) == 1
          push!(protectors,protector)
         blocked = true
       end
       if pTeam == team && blocked == false && get(frontVerticalProtectors,protector,-1) == 1
          push!(protectors,protector)
          blocked = true
        elseif  protector != " "
          blocked = true
        end
        y += (1 * orientation)
      end

      #check down
      x = targetx
      y = targety
        y -= (1 * orientation)
        blocked = false
      while x > 0 && x <= boardSize && y > 0 && y <= boardSize

        protector = myBoard[x,y]
        if protector == " "
            y -= (1 * orientation)
          continue
        end

        pTeam = lowercase(protector[length(protector)])
        protector = chop(protector)
        if abs(y-targety) < 3 && blocked == false && pTeam == team && (protector == "lion" ||protector == "LION"|| protector == "KIRIN"||protector == "fire_demon" || protector == "FIRE_DEMON" )
          push!(protectors,protector)
          blocked = true
        end

        if abs(y-targety) < 2 && blocked == false && pTeam == team && ( protector == "heavenly_tetrarch" || protector == "HEAVENLY_TETRARCH")
           push!(protectors,protector)
          blocked = true
       end
       if pTeam == team && get(noBlockOrthogonalProtectors,protector,-1) == 1
          push!(protectors,protector)
         blocked = true
       end
        if blocked == false && get(rearVerticalProtectors,protector,0) == 1 && pTeam == team
          push!(protectors,protector)
          blocked = true
        elseif protector != " "
          blocked = true
        end
        y -= (1 * orientation)
      end
      #check right
      x = targetx
      y = targety
      x += (1 * orientation)
      blocked = false
      while x > 0 && x <= boardSize && y > 0 && y <= boardSize

        protector = myBoard[x,y]
        if protector == " "
            x += (1 * orientation)
          continue

        end

        pTeam = lowercase(protector[length(protector)])
        protector = chop(protector)
        if abs(x-targetx) < 3 && blocked == false && pTeam == team && (protector == "lion" ||protector == "LION"|| protector == "KIRIN"||protector == "fire_demon" || protector == "FIRE_DEMON" )
          push!(protectors,protector)
          blocked = true
        end

        if abs(x-targetx) < 2 && blocked == false && pTeam == team && ( protector == "heavenly_tetrarch" || protector == "HEAVENLY_TETRARCH")
           push!(protectors,protector)
          blocked = true
       end
       if pTeam == team && get(noBlockOrthogonalProtectors,protector,-1) == 1
          push!(protectors,protector)
         blocked = true
       end
        if blocked == false && get(sideProtectors,protector,0) == 1 && pTeam == team
          push!(protectors,protector)
          blocked = true
        elseif protector != " "
          blocked = true
        end
        x +=(1 * orientation)
      end
      #check left
      x = targetx
      y = targety
      x -= (1 * orientation)
      blocked = false
      while x > 0 && x <= boardSize && y > 0 && y <= boardSize

        protector = myBoard[x,y]
        if protector == " "
            x -= (1 * orientation)
          continue
        end

        pTeam = lowercase(protector[length(protector)])
        protector = chop(protector)
        if abs(x-targetx) < 3 && blocked == false && pTeam == team && (protector == "lion" ||protector == "LION"|| protector == "KIRIN"||protector == "fire_demon" || protector == "FIRE_DEMON" )
          push!(protectors,protector)
          blocked = true
        end

        if abs(x-targetx) < 2 && blocked == false && pTeam == team && ( protector == "heavenly_tetrarch" || protector == "HEAVENLY_TETRARCH")
           push!(protectors,protector)
          blocked = true
       end
       if pTeam == team && get(noBlockOrthogonalProtectors,protector,-1) == 1
          push!(protectors,protector)
         blocked = true
       end
        if blocked == false && get(sideProtectors,protector,0) == 1 && pTeam == team
          push!(protectors,protector)
          blocked = true
        elseif protector != " "
          blocked = true
        end
        x -= (1 * orientation)
      end

      #check bottomleft diagonalProtectors
      x = targetx
      y = targety
      x -= (1 * orientation)
      y -= (1 * orientation)
      blocked = false
      while x > 0 && x <= boardSize && y > 0 && y <= boardSize

        protector = myBoard[x,y]
        if protector == " "
          x -= (1 * orientation)
          y -= (1 * orientation)
          continue
        end

        pTeam = lowercase(protector[length(protector)])
        protector = chop(protector)
        if abs(y-targety) < 3 && abs(x-targetx) < 3 && blocked == false && pTeam == team && (protector == "lion" ||protector == "LION"|| protector == "KIRIN"||protector == "fire_demon" || protector == "FIRE_DEMON" )
          push!(protectors,protector)
          blocked = true
        end

        if abs(y-targety) < 2 && abs(x-targetx) < 2 && blocked == false && pTeam == team && ( protector == "heavenly_tetrarch" || protector == "HEAVENLY_TETRARCH")
           push!(protectors,protector)
          blocked = true
       end
       if pTeam == team && get(noBlockDiagonalProtectors,protector,-1) == 1
          push!(protectors,protector)
         blocked = true
       end
        if blocked == false && get(rearDiagonalProtectors,protector,0) == 1 && pTeam == team
          push!(protectors,protector)
          blocked == true
        elseif protector != " "
          blocked = true
        end
        x -= (1 * orientation)
        y -= (1 * orientation)
      end

      #check bottomright diagonalProtectors
      x = targetx
      y = targety
      x += (1 * orientation)
      y -= (1 * orientation)
      blocked = false
      while x > 0 && x <= boardSize && y > 0 && y <= boardSize

        protector = myBoard[x,y]
        if protector == " "
          x += (1 * orientation)
          y -= (1 * orientation)
          continue
        end

        pTeam = lowercase(protector[length(protector)])
        protector = chop(protector)
        if abs(y-targety) < 3 && abs(x-targetx) < 3 && blocked == false && pTeam == team && (protector == "lion" ||protector == "LION"|| protector == "KIRIN"||protector == "fire_demon" || protector == "FIRE_DEMON" )
          push!(protectors,protector)
          blocked = true
        end

        if abs(y-targety) < 2 && abs(x-targetx) < 2 && blocked == false && pTeam == team && ( protector == "heavenly_tetrarch" || protector == "HEAVENLY_TETRARCH")
           push!(protectors,protector)
          blocked = true
       end
       if pTeam == team && get(noBlockDiagonalProtectors,protector,-1) == 1
          push!(protectors,protector)
         blocked = true
       end
        if blocked == false && get(rearDiagonalProtectors,protector,0) == 1 && pTeam == team
          push!(protectors,protector)
          blocked = true
        elseif protector != " "
          blocked = true
        end
        x += (1 * orientation)
        y -= (1 * orientation)
      end

      #check upperleft  diagonalProtectors
      x = targetx
      y = targety
      x -= (1 * orientation)
      y += (1 * orientation)
      blocked = false
      while x > 0 && x <= boardSize && y > 0 && y <= boardSize

        protector = myBoard[x,y]
        if protector == " "
          x -= (1 * orientation)
          y += (1 * orientation)
          continue
        end

        pTeam = lowercase(protector[length(protector)])
        protector = chop(protector)
        if abs(y-targety) < 3 && abs(x-targetx) < 3 && blocked == false && pTeam == team && (protector == "lion" ||protector == "LION"|| protector == "KIRIN"||protector == "fire_demon" || protector == "FIRE_DEMON" )
          push!(protectors,protector)
          blocked = true
        end

        if abs(y-targety) < 2 && abs(x-targetx) < 2 && blocked == false && pTeam == team && ( protector == "heavenly_tetrarch" || protector == "HEAVENLY_TETRARCH")
           push!(protectors,protector)
          blocked = true
       end
       if pTeam == team && get(noBlockDiagonalProtectors,protector,-1) == 1
          push!(protectors,protector)
         blocked = true
       end
        if blocked == false && get(frontDiagonalProtectors,protector,0) == 1 && pTeam == team
          push!(protectors,protector)
          blocked = true
        elseif protector != " "
          blocked = true
        end
        x -= (1 * orientation)
        y += (1 * orientation)
      end

      #check upperright diagonalProtectors
      x = targetx
      y = targety
      x += (1 * orientation)
      y += (1 * orientation)
      blocked = false
      while x > 0 && x <= boardSize && y > 0 && y <= boardSize

        protector = myBoard[x,y]
        if protector == " "
          x += (1 * orientation)
          y += (1 * orientation)
          continue
        end

        pTeam = lowercase(protector[length(protector)])
        protector = chop(protector)
        if abs(y-targety) < 3 && abs(x-targetx) < 3 && blocked == false && pTeam == team && (protector == "lion" ||protector == "LION"|| protector == "KIRIN"||protector == "fire_demon" || protector == "FIRE_DEMON" )
          push!(protectors,protector)
          blocked = true
        end

        if abs(y-targety) < 2 && abs(x-targetx) < 2 && blocked == false && pTeam == team && ( protector == "heavenly_tetrarch" || protector == "HEAVENLY_TETRARCH")
           push!(protectors,protector)
          blocked = true
       end
       if pTeam == team && get(noBlockDiagonalProtectors,protector,-1) == 1
          push!(protectors,protector)
         blocked = true
       end
        if blocked == false && get(frontDiagonalProtectors,protector,0) == 1 && pTeam == team
          push!(protectors,protector)
        elseif protector != " "
          blocked = true
        end
        x += (1 * orientation)
        y += (1 * orientation)
      end

      return protectors
    end

    function move_user_MoveTwo(shogiBoard::shogiData, prom)
        shogiBoard.move.move_type = "move"
        shogiBoard.lionCapture = false
        location = 0
      index = getPieceIndexAtLocation(shogiBoard, shogiBoard.move.sourcex, shogiBoard.move.sourcey)
      if index == -1
        return -1
      end
        # Capture the piece at the target location if it exists - then move it to (0,0) so its off the board
        if shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] == true
           attackIndex = getPieceIndexAtLocation(shogiBoard, shogiBoard.move.targetx, shogiBoard.move.targety)
           shogiBoard.occupied[shogiBoard.pieces[attackIndex].sourcex, shogiBoard.pieces[attackIndex].sourcey] = false
           shogiBoard.pieces[attackIndex].sourcex = 0
           shogiBoard.pieces[attackIndex].sourcey = 0
           shogiBoard.pieces[attackIndex].promoted = false
           shogiBoard.pieces[attackIndex].captured = true
           location = 1

          if shogiBoard.pieces[attackIndex].name == "horned_falcon"
                shogiBoard.pieces[attackIndex].maxCapture = 2
            elseif shogiBoard.pieces[attackIndex].name == "soaring_eagle"
                shogiBoard.pieces[attackIndex].maxCapture = 2
            elseif shogiBoard.pieces[attackIndex].name == "lion"
                shogiBoard.pieces[attackIndex].maxCapture = 2
            elseif shogiBoard.pieces[attackIndex].name == "lion_hawk"
                shogiBoard.pieces[attackIndex].maxCapture = 2
            elseif shogiBoard.pieces[attackIndex].name == "chariot_soldier"
                shogiBoard.pieces[attackIndex].maxCapture = 1
            elseif shogiBoard.pieces[attackIndex].name == "dragon_horse"
                shogiBoard.pieces[attackIndex].maxCapture = 1
            elseif shogiBoard.pieces[attackIndex].name == "dragon_king"
                shogiBoard.pieces[attackIndex].maxCapture = 1
            elseif shogiBoard.pieces[attackIndex].name == "kirin"
                shogiBoard.pieces[attackIndex].maxCapture = 1
            end

        if shogiBoard.pieces[attackIndex].name == "lion"
          shogiBoard.lionCapture = true
        end
        end

      if(shogiBoard.move.targetx2 != -1 && shogiBoard.move.targety2 != -1) && shogiBoard.move.targetx2 != shogiBoard.move.sourcex && shogiBoard.move.targety2 != shogiBoard.move.sourcey && shogiBoard.pieces[index].maxCapture >= 2
        if shogiBoard.occupied[shogiBoard.move.targetx2, shogiBoard.move.targety2] == true
          attackIndex = getPieceIndexAtLocation(shogiBoard, shogiBoard.move.targetx2, shogiBoard.move.targety2)
                shogiBoard.occupied[shogiBoard.pieces[attackIndex].sourcex, shogiBoard.pieces[attackIndex].sourcey] = false
          shogiBoard.pieces[attackIndex].sourcex = 0
          shogiBoard.pieces[attackIndex].sourcey = 0
          shogiBoard.pieces[attackIndex].promoted = false
          shogiBoard.pieces[attackIndex].captured = true
                location = 2

          if shogiBoard.pieces[attackIndex].name == "horned_falcon"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "soaring_eagle"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "lion"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "lion_hawk"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "chariot_soldier"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "dragon_horse"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "dragon_king"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "kirin"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                end

          if shogiBoard.pieces[attackIndex].name == "lion"
            shogiBoard.lionCapture = true
          end
        end
      end

      if(shogiBoard.move.targetx3 != -1 && shogiBoard.move.targety3 != -1) && shogiBoard.move.targetx3 != shogiBoard.move.sourcex && shogiBoard.move.targety3 != shogiBoard.move.sourcey && shogiBoard.pieces[index].maxCapture >= 3
        if shogiBoard.occupied[shogiBoard.move.targetx3, shogiBoard.move.targety3] == true
          attackIndex = getPieceIndexAtLocation(shogiBoard, shogiBoard.move.targetx3, shogiBoard.move.targety3)
                shogiBoard.occupied[shogiBoard.pieces[attackIndex].sourcex, shogiBoard.pieces[attackIndex].sourcey] = false
          shogiBoard.pieces[attackIndex].sourcex = 0
          shogiBoard.pieces[attackIndex].sourcey = 0
          shogiBoard.pieces[attackIndex].promoted = false
          shogiBoard.pieces[attackIndex].captured = true
                location = 3

          if shogiBoard.pieces[attackIndex].name == "horned_falcon"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "soaring_eagle"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "lion"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "lion_hawk"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "chariot_soldier"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "dragon_horse"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "dragon_king"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "kirin"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                end

          if shogiBoard.pieces[attackIndex].name == "lion"
            shogiBoard.lionCapture = true
          end
        end
      end

      if(shogiBoard.move.targetx4 != -1 && shogiBoard.move.targety4 != -1) && shogiBoard.move.targetx4 != shogiBoard.move.sourcex && shogiBoard.move.targety4 != shogiBoard.move.sourcey && shogiBoard.pieces[index].maxCapture >= 4
        if shogiBoard.occupied[shogiBoard.move.targetx4, shogiBoard.move.targety4] == true
          attackIndex = getPieceIndexAtLocation(shogiBoard, shogiBoard.move.targetx4, shogiBoard.move.targety4)
                shogiBoard.occupied[shogiBoard.pieces[attackIndex].sourcex, shogiBoard.pieces[attackIndex].sourcey] = false
          shogiBoard.pieces[attackIndex].sourcex = 0
          shogiBoard.pieces[attackIndex].sourcey = 0
          shogiBoard.pieces[attackIndex].promoted = false
          shogiBoard.pieces[attackIndex].captured = true
                location = 4

          if shogiBoard.pieces[attackIndex].name == "horned_falcon"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "soaring_eagle"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "lion"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "lion_hawk"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "chariot_soldier"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "dragon_horse"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "dragon_king"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "kirin"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                end

          if shogiBoard.pieces[attackIndex].name == "lion"
            shogiBoard.lionCapture = true
          end
        end
      end

      if(shogiBoard.move.targetx5 != -1 && shogiBoard.move.targety5 != -1) && shogiBoard.move.targetx5 != shogiBoard.move.sourcex && shogiBoard.move.targety5 != shogiBoard.move.sourcey && shogiBoard.pieces[index].maxCapture >= 5
        if shogiBoard.occupied[shogiBoard.move.targetx5, shogiBoard.move.targety5] == true
          attackIndex = getPieceIndexAtLocation(shogiBoard, shogiBoard.move.targetx5, shogiBoard.move.targety5)
                shogiBoard.occupied[shogiBoard.pieces[attackIndex].sourcex, shogiBoard.pieces[attackIndex].sourcey] = false
          shogiBoard.pieces[attackIndex].sourcex = 0
          shogiBoard.pieces[attackIndex].sourcey = 0
          shogiBoard.pieces[attackIndex].promoted = false
          shogiBoard.pieces[attackIndex].captured = true
                location = 5

          if shogiBoard.pieces[attackIndex].name == "horned_falcon"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "soaring_eagle"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "lion"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "lion_hawk"
                    shogiBoard.pieces[attackIndex].maxCapture = 2
                elseif shogiBoard.pieces[attackIndex].name == "chariot_soldier"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "dragon_horse"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "dragon_king"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                elseif shogiBoard.pieces[attackIndex].name == "kirin"
                    shogiBoard.pieces[attackIndex].maxCapture = 1
                end

          if shogiBoard.pieces[attackIndex].name == "lion"
            shogiBoard.lionCapture = true
          end
        end
      end

      attackIndex = 0


        # Move the piece to the new location
      if(shogiBoard.move.targetx2 == -1 || shogiBoard.move.targety2 == -1)
        shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
        shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true #set occupied[targetx,y] = true
        shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
        shogiBoard.pieces[index].sourcey = shogiBoard.move.targety

      else
        if (shogiBoard.move.targetx3 == -1 || shogiBoard.move.targety3 == -1)
                if shogiBoard.pieces[index].maxCapture == 1 && location < 2
                    shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                    shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true #set occupied[targetx,y] = true
                    shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
                    shogiBoard.pieces[index].sourcey = shogiBoard.move.targety
                else
              shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
              shogiBoard.occupied[shogiBoard.move.targetx2, shogiBoard.move.targety2] = true #set occupied[targetx,y] = true
              shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx2
              shogiBoard.pieces[index].sourcey = shogiBoard.move.targety2
                end

        else
          if (shogiBoard.move.targetx4 == -1 || shogiBoard.move.targety4 == -1)
                    if shogiBoard.pieces[index].maxCapture == 1 && location < 2
                        shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                        shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true #set occupied[targetx,y] = true
                        shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
                        shogiBoard.pieces[index].sourcey = shogiBoard.move.targety
                    elseif shogiBoard.pieces[index].maxCapture == 1 && location < 3
                        shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                        shogiBoard.occupied[shogiBoard.move.targetx2, shogiBoard.move.targety2] = true #set occupied[targetx,y] = true
                        shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx2
                        shogiBoard.pieces[index].sourcey = shogiBoard.move.targety2
                    else
                shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                shogiBoard.occupied[shogiBoard.move.targetx3, shogiBoard.move.targety3] = true #set occupied[targetx,y] = true
                shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx3
                shogiBoard.pieces[index].sourcey = shogiBoard.move.targety3
                    end

          else
            if (shogiBoard.move.targetx5 == -1 || shogiBoard.move.targety5 == -1)
                        if shogiBoard.pieces[index].maxCapture == 1 && location < 2
                            shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                            shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true #set occupied[targetx,y] = true
                            shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
                            shogiBoard.pieces[index].sourcey = shogiBoard.move.targety
                        elseif shogiBoard.pieces[index].maxCapture == 1 && location < 3
                            shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                            shogiBoard.occupied[shogiBoard.move.targetx2, shogiBoard.move.targety2] = true #set occupied[targetx,y] = true
                            shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx2
                            shogiBoard.pieces[index].sourcey = shogiBoard.move.targety2
                        elseif shogiBoard.pieces[index].maxCapture == 1 && location < 4
                            shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                            shogiBoard.occupied[shogiBoard.move.targetx3, shogiBoard.move.targety3] = true #set occupied[targetx,y] = true
                            shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx3
                            shogiBoard.pieces[index].sourcey = shogiBoard.move.targety3
                        else
                  shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                  shogiBoard.occupied[shogiBoard.move.targetx4, shogiBoard.move.targety4] = true #set occupied[targetx,y] = true
                  shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx4
                  shogiBoard.pieces[index].sourcey = shogiBoard.move.targety4
                        end
            else
                        if shogiBoard.pieces[index].maxCapture == 1 && location < 2
                            shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                            shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true #set occupied[targetx,y] = true
                            shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
                            shogiBoard.pieces[index].sourcey = shogiBoard.move.targety
                        elseif shogiBoard.pieces[index].maxCapture == 1 && location < 3
                            shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                            shogiBoard.occupied[shogiBoard.move.targetx2, shogiBoard.move.targety2] = true #set occupied[targetx,y] = true
                            shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx2
                            shogiBoard.pieces[index].sourcey = shogiBoard.move.targety2
                        elseif shogiBoard.pieces[index].maxCapture == 1 && location < 4
                            shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                            shogiBoard.occupied[shogiBoard.move.targetx3, shogiBoard.move.targety3] = true #set occupied[targetx,y] = true
                            shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx3
                            shogiBoard.pieces[index].sourcey = shogiBoard.move.targety3
                        elseif shogiBoard.pieces[index].maxCapture == 1 && location < 5
                            shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                            shogiBoard.occupied[shogiBoard.move.targetx4, shogiBoard.move.targety4] = true #set occupied[targetx,y] = true
                            shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx4
                            shogiBoard.pieces[index].sourcey = shogiBoard.move.targety4
                        else
                  shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false #set occupied[sourcex,y] = false
                  shogiBoard.occupied[shogiBoard.move.targetx5, shogiBoard.move.targety5] = true #set occupied[targetx,y] = true
                  shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx5
                  shogiBoard.pieces[index].sourcey = shogiBoard.move.targety5
                        end
            end
          end
        end
      end

      #=for i = shogiBoard.pieces[index].sourcex-1:shogiBoard.pieces[index].sourcex+1
        for j = shogiBoard.pieces[index].sourcey-1:shogiBoard.pieces[index].sourcey+1
          if i != shogiBoard.pieces[index].sourcex && j != shogiBoard.pieces[index].sourcey
            l = getPieceIndexAtLocation(shogiBoard, i, j)
            if l != -1
              if shogiBoard.pieces[l].name == "fire_demon" && shogiBoard.pieces[l].team != shogiBoard.pieces[index].team && shogiBoard.pieces[l].captured == false
                            shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false
                shogiBoard.pieces[index].sourcex = 0
                shogiBoard.pieces[index].sourcey = 0
                shogiBoard.pieces[index].promoted = false
                shogiBoard.pieces[index].captured = true

                if shogiBoard.pieces[index].name == "horned_falcon"
                  shogiBoard.pieces[index].maxCapture = 2
                elseif shogiBoard.pieces[index].name == "soaring_eagle"
                  shogiBoard.pieces[index].maxCapture = 2
                elseif shogiBoard.pieces[index].name == "lion"
                  shogiBoard.pieces[index].maxCapture = 2
                elseif shogiBoard.pieces[index].name == "lion_hawk"
                  shogiBoard.pieces[index].maxCapture = 2
                end
              end
            end
          end
        end
      end=#

      if shogiBoard.pieces[index].name =="fire_demon" && shogiBoard.pieces[index].captured == false
        for u = shogiBoard.pieces[index].sourcex-1:shogiBoard.pieces[index].sourcex+1
          for v = shogiBoard.pieces[index].sourcey-1:shogiBoard.pieces[index].sourcey+1
            if (u > 0 && v > 0 && u <= shogiBoard.boardSize && v <= shogiBoard.boardSize)
              attackIndex = getPieceIndexAtLocation(shogiBoard, u, v)
              if attackIndex != -1
                if shogiBoard.pieces[attackIndex].team != shogiBoard.pieces[index].team
                                shogiBoard.occupied[shogiBoard.pieces[attackIndex].sourcex, shogiBoard.pieces[attackIndex].sourcey] = false
                  shogiBoard.pieces[attackIndex].sourcex = 0
                  shogiBoard.pieces[attackIndex].sourcey = 0
                  shogiBoard.pieces[attackIndex].promoted = false
                  shogiBoard.pieces[attackIndex].captured = true

                  if shogiBoard.pieces[attackIndex].name == "horned_falcon"
                                    shogiBoard.pieces[attackIndex].maxCapture = 2
                                elseif shogiBoard.pieces[attackIndex].name == "soaring_eagle"
                                    shogiBoard.pieces[attackIndex].maxCapture = 2
                                elseif shogiBoard.pieces[attackIndex].name == "lion"
                                    shogiBoard.pieces[attackIndex].maxCapture = 2
                                elseif shogiBoard.pieces[attackIndex].name == "lion_hawk"
                                    shogiBoard.pieces[attackIndex].maxCapture = 2
                                elseif shogiBoard.pieces[attackIndex].name == "chariot_soldier"
                                    shogiBoard.pieces[attackIndex].maxCapture = 1
                                elseif shogiBoard.pieces[attackIndex].name == "dragon_horse"
                                    shogiBoard.pieces[attackIndex].maxCapture = 1
                                elseif shogiBoard.pieces[attackIndex].name == "dragon_king"
                                    shogiBoard.pieces[attackIndex].maxCapture = 1
                                elseif shogiBoard.pieces[attackIndex].name == "kirin"
                                    shogiBoard.pieces[attackIndex].maxCapture = 1
                                end

                  if shogiBoard.pieces[attackIndex].name == "lion"
                    shogiBoard.lionCapture = true
                  end
                end
              end
            end
          end
        end
      end

      for demon in shogiBoard.pieces
            if demon.name == "fire_demon" && demon.captured == false && demon.team != shogiBoard.pieces[index].team
                x, y, x2, y2, x3, y3, s = getKingMoves(shogiBoard, demon.sourcex, demon.sourcey)

                for z = 1:length(x)
                    if x[z] == shogiBoard.pieces[index].sourcex && y[z] == shogiBoard.pieces[index].sourcey
                        shogiBoard.occupied[shogiBoard.pieces[index].sourcex, shogiBoard.pieces[index].sourcey] = false

                        shogiBoard.pieces[index].sourcex = 0
                        shogiBoard.pieces[index].sourcey = 0
                        shogiBoard.pieces[index].promoted = false
                        shogiBoard.pieces[index].captured = true

                        if shogiBoard.pieces[index].name == "horned_falcon"
                            shogiBoard.pieces[index].maxCapture = 2
                        elseif shogiBoard.pieces[index].name == "soaring_eagle"
                            shogiBoard.pieces[index].maxCapture = 2
                        elseif shogiBoard.pieces[index].name == "lion"
                            shogiBoard.pieces[index].maxCapture = 2
                        elseif shogiBoard.pieces[index].name == "lion_hawk"
                            shogiBoard.pieces[index].maxCapture = 2
                        elseif shogiBoard.pieces[index].name == "chariot_soldier"
                            shogiBoard.pieces[index].maxCapture = 1
                        elseif shogiBoard.pieces[index].name == "dragon_horse"
                            shogiBoard.pieces[index].maxCapture = 1
                        elseif shogiBoard.pieces[index].name == "dragon_king"
                            shogiBoard.pieces[index].maxCapture = 1
                        elseif shogiBoard.pieces[index].name == "kirin"
                            shogiBoard.pieces[index].maxCapture = 1
                        end

                        if shogiBoard.pieces[index].name == "lion"
                            shogiBoard.lionCapture = true
                        end

                        break
                    end
                end
            end
        end


        # Check if the piece should be promoted
        local team::Char

        if shogiBoard.move.move_number % 2 == 1
          team = 'b'
        else
          team = 'w'
        end

        zoneW = 7
        zoneB = 3

        if shogiBoard.boardSize == 5
          zoneW = 5
          zoneB = 1
      elseif shogiBoard.boardSize == 12
        zoneW = 9
        zoneB = 4
      elseif shogiBoard.boardSize == 16
        zoneW = 12
        zoneB = 5
      end

        if ((team == 'w' && (shogiBoard.move.targety >= zoneW || shogiBoard.move.sourcey >= zoneW)) || (team == 'b' && (shogiBoard.move.targety <= zoneB || shogiBoard.move.sourcey <= zoneB))) && prom == true
          shogiBoard.pieces[index].promoted = true
          shogiBoard.move.option = "!"

            if shogiBoard.pieces[index].name == "chariot_soldier"
                shogiBoard.pieces[index].maxCapture = 2
            elseif shogiBoard.pieces[index].name == "dragon_horse"
                shogiBoard.pieces[index].maxCapture = 2
            elseif shogiBoard.pieces[index].name == "dragon_king"
                shogiBoard.pieces[index].maxCapture = 2
            elseif shogiBoard.pieces[index].name == "kirin"
                shogiBoard.pieces[index].maxCapture = 2
            elseif shogiBoard.pieces[index].name == "horned_falcon"
                shogiBoard.pieces[index].maxCapture = 1
            elseif shogiBoard.pieces[index].name == "soaring_eagle"
                shogiBoard.pieces[index].maxCapture = 1
            end
        else
          shogiBoard.move.option = "?"
        end

        return shogiBoard
    end

    function isuppercase(str::String)
      for c in str
        if isupper(c) == true
          return true
        end
      end
      return false
    end

    function getAttacks(state::shogiData,team::Char)

      plays = generateMoves(state)
      boardSize = size(state.board)[1]
      myBoard = Array{String}(boardSize,boardSize)

      for i = 1:boardSize
        for j =1:boardSize
          myBoard[i,j]=" "
        end
      end
      for piece in state.pieces
      if piece.captured == false
          pName = string(piece.name,piece.team)
        if piece.promoted == true
          pName = uppercase(pName)
        end
        myBoard[piece.sourcex,piece.sourcey] = pName
      end
    end
      piecesUnderAttack = Vector{String}(0)
      attackers = Vector{Tuple{Int,Int,Int,Int}}(0)
      for p in plays
        x0 = p.sourcex
        y0 = p.sourcey
        #println("enPlay: ",p)
        x1 = p.targetx
        y1 = p.targety
        if x1 < 1 || x1 > boardSize || y1 < 1 || y1 > boardSize
          continue
        end

        attacker = myBoard[p.sourcex,p.sourcey]
        target = myBoard[x1,y1]
        targetTeam = lowercase(target[length(target)])

        if targetTeam == team
          continue
        end

        if attacker != target && target!=" "

            #=println("1064: ")
            println("attacker: ",attacker)
            println("target: ",target)=#

          push!(attackers,(x0,y0,x1,y1))
        end

        x2 = p.targetx2
        y2 = p.targety2
        if x2 < 1 || x2 > boardSize || y2 < 1 || y2 > boardSize
          continue
        end
        target = myBoard[x2,y2]
        targetTeam = lowercase(target[length(target)])
        if targetTeam == team
          continue
        end
        if attacker != target && target!=" "
          push!(attackers,(x0,y0,x2,y2))
        end

        x3 = p.targetx3
        y3 = p.targety3
        if x3 < 1 || x3 > boardSize || y3 < 1 || y3 > boardSize
          continue
        end
        target = myBoard[x3,y3]
        targetTeam = lowercase(target[length(target)])
        if targetTeam == team
          continue
        end

        if attacker != target && target!=" "
          push!(attackers,(x0,y0,x3,y3))
        end

        x4 = p.targetx4
        y4 = p.targety4
        if x4 < 1 || x4 > boardSize || y4 < 1 || y4 > boardSize
          continue
        end
        target = myBoard[x4,y4]
        targetTeam = lowercase(target[length(target)])
        if targetTeam == team
          continue
        end
        if attacker != target && target!=" "
          push!(attackers,(x0,y0,x4,y4))
        end
      end
      return attackers
    end


end
