module setupLibrary
push!(LOAD_PATH,pwd())
using Definition
using moveLibrary
export setup, setupM, setupC, setupT , updateBoard, Display,dispBoard

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
  
  return myBoard  
end


# setups the Standard Shogi game
function setup()
	local d::shogiData
	d = shogiData()
	d.meta.shogiType = "standard"
	d.meta.cheating = "False"
	d.meta.limit = 0
	d.meta.limit_add = 0
	d.meta.senteTime = 0
	d.meta.goteTime = 0
	d.boardSize = 9
	d.board = Array{String}(9, 9)

	#set up the board
	for i = 1:9
		for j = 1:9
			d.board[i,j] = " "
		end
	end

	#white side pieces
	d.board[1,1] = "lance"
	d.board[9,1] = "lance"
	d.board[8,1] = "knight"
	d.board[2,1] = "knight"
	d.board[3,1] = "silver_general"
	d.board[7,1] = "silver_general"
	d.board[4,1] = "gold_general"
	d.board[6,1] = "gold_general"
	d.board[5,1] = "king"
	d.board[8,2] = "rook"
	d.board[2,2] = "bishop"
	for i = 1:9
		d.board[i,3] = "pawn"
	end

	#black side pieces
	d.board[1,9] = "lance"
	d.board[9,9] = "lance"
	d.board[2,9] = "knight"
	d.board[8,9] = "knight"
	d.board[3,9] = "silver_general"
	d.board[7,9] = "silver_general"
	d.board[4,9] = "gold_general"
	d.board[6,9] = "gold_general"
	d.board[5,9] = "king"
	d.board[2,8] = "rook"
	d.board[8,8] = "bishop"
	for i = 1:9
		d.board[i,7] = "pawn"
	end


	d.pieces = Array{piece}(40)

	for i = 1:9
		#white Pawns
		d.pieces[i] = piece("pawn", 'w', convert(Int16,i), convert(Int16,3), false, false, 1)
	end
	#white King
	d.pieces[10] = piece("king", 'w',  convert(Int16,5), convert(Int16,1), false, false, 1)
	#white Gold General
	d.pieces[11] = piece("gold_general", 'w', convert(Int16,4), convert(Int16,1), false, false, 1)
	d.pieces[12] = piece("gold_general", 'w', convert(Int16,6), convert(Int16,1), false, false, 1)
	#white Silver General
	d.pieces[13] = piece("silver_general", 'w', convert(Int16,3), convert(Int16,1), false, false, 1)
	d.pieces[14] = piece("silver_general", 'w', convert(Int16,7), convert(Int16,1), false, false, 1)
	#white knight
	d.pieces[15] = piece("knight", 'w', convert(Int16,2), convert(Int16,1), false, false, 1)
	d.pieces[16] = piece("knight", 'w', convert(Int16,8), convert(Int16,1), false, false, 1)
	#white lance
	d.pieces[17] = piece("lance", 'w', convert(Int16,1), convert(Int16,1), false, false, 1)
	d.pieces[18] = piece("lance", 'w', convert(Int16,9), convert(Int16,1), false, false, 1)
	#white Rook
	d.pieces[19] = piece("rook", 'w', convert(Int16,8), convert(Int16,2), false, false, 1)
	#white Bishop
	d.pieces[20] = piece("bishop", 'w', convert(Int16,2), convert(Int16,2), false, false, 1)


	for i = 1:9
		#black Pawns
		d.pieces[20+i] = piece("pawn", 'b', convert(Int16,i), convert(Int16,7), false, false, 1)
	end
	#black King
	d.pieces[30] = piece("king", 'b', convert(Int16,5), convert(Int16,9), false, false, 1)
	#black Gold General
	d.pieces[31] = piece("gold_general", 'b', convert(Int16,4), convert(Int16,9), false, false, 1)
	d.pieces[32] = piece("gold_general", 'b', convert(Int16,6), convert(Int16,9), false, false, 1)
	#black Silver General
	d.pieces[33] = piece("silver_general", 'b', convert(Int16,3), convert(Int16,9), false, false, 1)
	d.pieces[34] = piece("silver_general", 'b', convert(Int16,7), convert(Int16,9), false, false, 1)
	#black knight
	d.pieces[35] = piece("knight", 'b', convert(Int16,2), convert(Int16,9), false, false, 1)
	d.pieces[36] = piece("knight", 'b', convert(Int16,8), convert(Int16,9), false, false, 1)
	#black lance
	d.pieces[37] = piece("lance", 'b', convert(Int16,1), convert(Int16,9), false, false, 1)
	d.pieces[38] = piece("lance", 'b', convert(Int16,9), convert(Int16,9), false, false, 1)

	#black Rook
	d.pieces[39] = piece("rook", 'b', convert(Int16,2), convert(Int16,8), false, false, 1)
	#black Bishop
	d.pieces[40] = piece("bishop", 'b', convert(Int16,8), convert(Int16,8), false, false, 1)

	#define occupied coordinates


	for i = 1:9
		for j = 1:9
			d.occupied[i,j]=false
		end
	end


	for i = 1:9

		d.occupied[i,1] = true
		d.occupied[i,3] = true
		d.occupied[i,7] = true
		d.occupied[i,9] = true
	end
	d.occupied[2,2] = true
	d.occupied[2,8] = true
	d.occupied[8,2] = true
	d.occupied[8,8] = true


	return d
end


# setups the Mini Shogi game
function setupM()
	local d::shogiData
	d = shogiData()
	d.meta.shogiType = "minishogi"
	d.meta.cheating = "False"
	d.meta.limit = 0
	d.meta.limit_add = 0
	d.meta.senteTime = 0
	d.meta.goteTime = 0
	d.boardSize = 5
	d.board = Array{String}(5,5)

	#set up the board
	for i = 1:5
		for j = 1:5
			d.board[i,j] = " "
		end
	end

	#white side pieces
	d.board[1,2] = "pawn"
	d.board[1,1] = "king"
	d.board[2,1] = "gold_general"
	d.board[3,1] = "silver_general"
	d.board[4,1] = "bishop"
	d.board[5,1] = "rook"

	#black side pieces
	d.board[5,4] = "pawn"
	d.board[5,5] = "king"
	d.board[4,5] = "gold_general"
	d.board[3,5] = "silver_general"
	d.board[2,5] = "bishop"
	d.board[1,5] = "rook"

	d.pieces = Array{piece}(12)
	#set up white pieces
	d.pieces[1] = piece("pawn", 'w', convert(Int16,1), convert(Int16,2), false, false, 1) # white pawn
	d.pieces[2] = piece("king", 'w', convert(Int16,1), convert(Int16,1), false, false, 1) # white king
	d.pieces[3] = piece("gold_general", 'w', convert(Int16,2), convert(Int16,1), false, false, 1) # white gold general
	d.pieces[4] = piece("silver_general", 'w', convert(Int16,3), convert(Int16,1), false, false, 1) # white silver general
	d.pieces[5] = piece("bishop", 'w', convert(Int16,4), convert(Int16,1), false, false, 1) # white bishop
	d.pieces[6] = piece("rook", 'w', convert(Int16,5), convert(Int16,1), false, false, 1) # white rook

	#set up black pieces
	d.pieces[7] = piece("pawn", 'b', convert(Int16,5), convert(Int16,4), false, false, 1) # black pawn
	d.pieces[8] = piece("king", 'b', convert(Int16,5), convert(Int16,5), false, false, 1) # black king
	d.pieces[9] = piece("gold_general", 'b', convert(Int16,4), convert(Int16,5), false, false, 1) # black gold general
	d.pieces[10] = piece("silver_general", 'b', convert(Int16,3), convert(Int16,5), false, false, 1) # black silver general
	d.pieces[11] = piece("bishop", 'b', convert(Int16,2), convert(Int16,5), false, false, 1) # black bishop
	d.pieces[12] = piece("rook", 'b', convert(Int16,1), convert(Int16,5), false, false, 1) # black rook


	#define occupied coordinates


	for i = 1:5
		for j = 1:5
			d.occupied[i,j]=false
		end
	end


	for i = 1:5
		d.occupied[i,1] = true
		d.occupied[i,5] = true
	end
	d.occupied[1,2] = true
	d.occupied[5,4] = true


	return d
end


# setups the Chu Shogi game
function setupC()
	local d::shogiData
	d = shogiData()
	d.meta.shogiType = "chu"
	d.meta.cheating = "False"
	d.meta.limit = 0
	d.meta.limit_add = 0
	d.meta.senteTime = 0
	d.meta.goteTime = 0
	d.boardSize = 12
	d.board = Array{String}(12, 12)

	# board setup
	for i = 1:12
		for j = 1:12
			d.board[i, j] = " "
		end
	end

	# white side pieces
	d.board[1, 1] = d.board[12, 1] = "lance"
	d.board[2, 1] = d.board[11, 1] = "ferocious_leopard"
	d.board[3, 1] = d.board[10, 1] = "copper_general"
	d.board[4, 1] = d.board[9, 1] = "silver_general"
	d.board[5, 1] = d.board[8, 1] = "gold_general"
	d.board[6, 1] = "king"
	d.board[7, 1] = "drunk_elephant"
	d.board[1, 2] = d.board[12, 2] = "reverse_chariot"
	d.board[3, 2] = d.board[10, 2] = "bishop"
	d.board[5, 2] = d.board[8, 2] = "blind_tiger"
	d.board[6, 2] = "kirin"
	d.board[7, 2] = "phoenix"
	d.board[1, 3] = d.board[12, 3] = "side_mover"
	d.board[2, 3] = d.board[11, 3] = "vertical_mover"
	d.board[3, 3] = d.board[10, 3] = "rook"
	d.board[4, 3] = d.board[9, 3] = "dragon_horse"
	d.board[5, 3] = d.board[8, 3] = "dragon_king"
	d.board[6, 3] = "lion"
	d.board[7, 3] = "queen"
	d.board[4, 5] = d.board[9, 5] = "go_between"
	for i = 1:12
		d.board[i, 4] = "pawn"
	end

	# black side pieces
	d.board[1, 12] = d.board[12, 12] = "lance"
	d.board[2, 12] = d.board[11, 12] = "ferocious_leopard"
	d.board[3, 12] = d.board[10, 12] = "copper_general"
	d.board[4, 12] = d.board[9, 12] = "silver_general"
	d.board[5, 12] = d.board[8, 12] = "gold_general"
	d.board[6, 12] = "drunk_elephant"
	d.board[7, 12] = "king"
	d.board[1, 11] = d.board[12, 11] = "reverse_chariot"
	d.board[3, 11] = d.board[10, 11] = "bishop"
	d.board[5, 11] = d.board[8, 11] = "blind_tiger"
	d.board[6, 11] = "phoenix"
	d.board[7, 11] = "kirin"
	d.board[1, 10] = d.board[12, 10] = "side_mover"
	d.board[2, 10] = d.board[11, 10] = "vertical_mover"
	d.board[3, 10] = d.board[10, 10] = "rook"
	d.board[4, 10] = d.board[9, 10] = "dragon_horse"
	d.board[5, 10] = d.board[8, 10] = "dragon_king"
	d.board[6, 10] = "queen"
	d.board[7, 10] = "lion"
	d.board[4, 8] = d.board[9, 8] = "go_between"
	for i = 1:12
		d.board[i, 9] = "pawn"
	end


	for i = 1:12
		# white Pawns
		d.pieces[i] = piece("pawn", 'w', convert(Int16, i), convert(Int16, 4), false, false, 1)
	end
	# white Reverse Chariot
	d.pieces[13] = piece("reverse_chariot", 'w', convert(Int16, 1), convert(Int16, 2), false, false, 1)
	d.pieces[14] = piece("reverse_chariot", 'w', convert(Int16, 12), convert(Int16, 2), false, false, 1)
	# white Bishop
	d.pieces[15] = piece("bishop", 'w', convert(Int16, 3), convert(Int16, 2), false, false, 1)
	d.pieces[16] = piece("bishop", 'w', convert(Int16, 10), convert(Int16, 2), false, false, 1)
	# white Copper General
	d.pieces[17] = piece("copper_general", 'w', convert(Int16, 3), convert(Int16, 1), false, false, 1)
	d.pieces[18] = piece("copper_general", 'w', convert(Int16, 10), convert(Int16, 1), false, false, 1)
	# white Dragon King
	d.pieces[19] = piece("dragon_king", 'w', convert(Int16, 5), convert(Int16, 3), false, false, 1)
	d.pieces[20] = piece("dragon_king", 'w', convert(Int16, 8), convert(Int16, 3), false, false, 1)
	# white Drunk Elephant
	d.pieces[21] = piece("drunk_elephant", 'w', convert(Int16, 7), convert(Int16, 1), false, false, 1)
	# white Ferocious Leopard
	d.pieces[22] = piece("ferocious_leopard", 'w', convert(Int16, 2), convert(Int16, 1), false, false, 1)
	d.pieces[23] = piece("ferocious_leopard", 'w', convert(Int16, 11), convert(Int16, 1), false, false, 1)
	# white Gold General
	d.pieces[24] = piece("gold_general", 'w', convert(Int16, 5), convert(Int16, 1), false, false, 1)
	d.pieces[25] = piece("gold_general", 'w', convert(Int16, 8), convert(Int16, 1), false, false, 1)
	# white Dragon Horse
	d.pieces[26] = piece("dragon_horse", 'w', convert(Int16, 4), convert(Int16, 3), false, false, 1)
	d.pieces[27] = piece("dragon_horse", 'w', convert(Int16, 9), convert(Int16, 3), false, false, 1)
	# white Lion
	d.pieces[28] = piece("lion", 'w', convert(Int16, 6), convert(Int16, 3), false, false, 2)
	# white King
	d.pieces[29] = piece("king", 'w', convert(Int16, 6), convert(Int16, 1), false, false, 1)
	# white Lance
	d.pieces[30] = piece("lance", 'w', convert(Int16, 1), convert(Int16, 1), false, false, 1)
	d.pieces[31] = piece("lance", 'w', convert(Int16, 12), convert(Int16, 1), false, false, 1)
	# white Side Mover
	d.pieces[32] = piece("side_mover", 'w', convert(Int16, 1), convert(Int16, 3), false, false, 1)
	d.pieces[33] = piece("side_mover", 'w', convert(Int16, 12), convert(Int16, 3), false, false, 1)
	# white Knight or Kirin
	d.pieces[34] = piece("kirin", 'w', convert(Int16, 6), convert(Int16, 2), false, false, 1)
	# white Go-between
	d.pieces[35] = piece("go_between", 'w', convert(Int16, 4), convert(Int16, 5), false, false, 1)
	d.pieces[36] = piece("go_between", 'w', convert(Int16, 9), convert(Int16, 5), false, false, 1)
	# white Rook
	d.pieces[37] = piece("rook", 'w', convert(Int16, 3), convert(Int16, 3), false, false, 1)
	d.pieces[38] = piece("rook", 'w', convert(Int16, 10), convert(Int16, 3), false, false, 1)
	# white Silver General
	d.pieces[39] = piece("silver_general", 'w', convert(Int16, 4), convert(Int16, 1), false, false, 1)
	d.pieces[40] = piece("silver_general", 'w', convert(Int16, 9), convert(Int16, 1), false, false, 1)
	# white Blind Tiger
	d.pieces[41] = piece("blind_tiger", 'w', convert(Int16, 5), convert(Int16, 2), false, false, 1)
	d.pieces[42] = piece("blind_tiger", 'w', convert(Int16, 8), convert(Int16, 2), false, false, 1)
	# white Queen
	d.pieces[43] = piece("queen", 'w', convert(Int16, 7), convert(Int16, 3), false, false, 1)
	# white Vertical Mover
	d.pieces[44] = piece("vertical_mover", 'w', convert(Int16, 2), convert(Int16, 3), false, false, 1)
	d.pieces[45] = piece("vertical_mover", 'w', convert(Int16, 11), convert(Int16, 3), false, false, 1)
	# white Pheonix
	d.pieces[46] = piece("phoenix", 'w', convert(Int16, 7), convert(Int16, 2), false, false, 1)


	for i = 1:12
		# black Pawns
		d.pieces[46+i] = piece("pawn", 'b', convert(Int16, i), convert(Int16, 9), false, false, 1)
	end
	# black Reverse Chariot
	d.pieces[59] = piece("reverse_chariot", 'b', convert(Int16, 1), convert(Int16, 11), false, false, 1)
	d.pieces[60] = piece("reverse_chariot", 'b', convert(Int16, 12), convert(Int16, 11), false, false, 1)
	# black Bishop
	d.pieces[61] = piece("bishop", 'b', convert(Int16, 3), convert(Int16, 11), false, false, 1)
	d.pieces[62] = piece("bishop", 'b', convert(Int16, 10), convert(Int16, 11), false, false, 1)
	# black Copper Genera;
	d.pieces[63] = piece("copper_general", 'b', convert(Int16, 3), convert(Int16, 12), false, false, 1)
	d.pieces[64] = piece("copper_general", 'b', convert(Int16, 10), convert(Int16, 12), false, false, 1)
	# black Dragon King
	d.pieces[65] = piece("dragon_king", 'b', convert(Int16, 5), convert(Int16, 10), false, false, 1)
	d.pieces[66] = piece("dragon_king", 'b', convert(Int16, 8), convert(Int16, 10), false, false, 1)
	# black Drunk Elephant
	d.pieces[67] = piece("drunk_elephant", 'b', convert(Int16, 6), convert(Int16, 12), false, false, 1)
	# black Ferocious Leopard
	d.pieces[68] = piece("ferocious_leopard", 'b', convert(Int16, 2), convert(Int16, 12), false, false, 1)
	d.pieces[69] = piece("ferocious_leopard", 'b', convert(Int16, 11), convert(Int16, 12), false, false, 1)
	# black Gold General
	d.pieces[70] = piece("gold_general", 'b', convert(Int16, 5), convert(Int16, 12), false, false, 1)
	d.pieces[71] = piece("gold_general", 'b', convert(Int16, 8), convert(Int16, 12), false, false, 1)
	# black Dragon Horse
	d.pieces[72] = piece("dragon_horse", 'b', convert(Int16, 4), convert(Int16, 10), false, false, 1)
	d.pieces[73] = piece("dragon_horse", 'b', convert(Int16, 9), convert(Int16, 10), false, false, 1)
	# black Lion
	d.pieces[74] = piece("lion", 'b', convert(Int16, 7), convert(Int16, 10), false, false, 2)
	# black King
	d.pieces[75] = piece("king", 'b', convert(Int16, 7), convert(Int16, 12), false, false, 1)
	# black Lance
	d.pieces[76] = piece("lance", 'b', convert(Int16, 1), convert(Int16, 12), false, false, 1)
	d.pieces[77] = piece("lance", 'b', convert(Int16, 12), convert(Int16, 12), false, false, 1)
	# black Side Mover
	d.pieces[78] = piece("side_mover", 'b', convert(Int16, 1), convert(Int16, 10), false, false, 1)
	d.pieces[79] = piece("side_mover", 'b', convert(Int16, 12), convert(Int16, 10), false, false, 1)
	# black Knight or Kirin
	d.pieces[80] = piece("kirin", 'b', convert(Int16, 7), convert(Int16, 11), false, false, 1)
	# black Go-between
	d.pieces[81] = piece("go_between", 'b', convert(Int16, 4), convert(Int16, 8), false, false, 1)
	d.pieces[82] = piece("go_between", 'b', convert(Int16, 9), convert(Int16, 8), false, false, 1)
	# black Rook
	d.pieces[83] = piece("rook", 'b', convert(Int16, 3), convert(Int16, 10), false, false, 1)
	d.pieces[84] = piece("rook", 'b', convert(Int16, 10), convert(Int16, 10), false, false, 1)
	# black Silver General
	d.pieces[85] = piece("silver_general", 'b', convert(Int16, 4), convert(Int16, 12), false, false, 1)
	d.pieces[86] = piece("silver_general", 'b', convert(Int16, 9), convert(Int16, 12), false, false, 1)
	# black Blind Tiger
	d.pieces[87] = piece("blind_tiger", 'b', convert(Int16, 5), convert(Int16, 11), false, false, 1)
	d.pieces[88] = piece("blind_tiger", 'b', convert(Int16, 8), convert(Int16, 11), false, false, 1)
	# black Queen
	d.pieces[89] = piece("queen", 'b', convert(Int16, 6), convert(Int16, 10), false, false, 1)
	# black Vertical Mover
	d.pieces[90] = piece("vertical_mover", 'b', convert(Int16, 2), convert(Int16, 10), false, false, 1)
	d.pieces[91] = piece("vertical_mover", 'b', convert(Int16, 11), convert(Int16, 10), false, false, 1)
	# black Pheonix
	d.pieces[92] = piece("phoenix", 'b', convert(Int16, 6), convert(Int16, 11), false, false, 1)

	# define occupied coordinates
	for i = 1:12
		for j = 1:12
			d.occupied[i, j] = false
		end
	end
	for i = 1:12
		d.occupied[i, 1] = true
		d.occupied[i, 3] = true
		d.occupied[i, 4] = true
		d.occupied[i, 9] = true
		d.occupied[i, 10] = true
		d.occupied[i, 12] = true
	end
	d.occupied[1, 2] = true
	d.occupied[3, 2] = true
	d.occupied[5, 2] = true
	d.occupied[6, 2] = true
	d.occupied[7, 2] = true
	d.occupied[8, 2] = true
	d.occupied[10, 2] = true
	d.occupied[12, 2] = true
	d.occupied[4, 5] = true
	d.occupied[9, 5] = true
	d.occupied[1, 11] = true
	d.occupied[3, 11] = true
	d.occupied[5, 11] = true
	d.occupied[6, 11] = true
	d.occupied[7, 11] = true
	d.occupied[8, 11] = true
	d.occupied[10,11] = true
	d.occupied[12, 11] = true
	d.occupied[4, 8] = true
	d.occupied[9, 8] = true


	return d
end

#setup ten shogi

function setupT()
	local d::shogiData
	d = shogiData()
	d.meta.shogiType = "ten"
	d.meta.cheating = "False"
	d.meta.limit = 0
	d.meta.limit_add = 0
	d.meta.senteTime = 0
	d.meta.goteTime = 0
	d.boardSize = 16
	d.board = Array{String}(16, 16)

	# board setup
	for i = 1:16
		for j = 1:16
			d.board[i, j] = " "
		end
	end

	# white side pieces
	d.board[1, 1] = d.board[16, 1] = "lance"
	d.board[2, 1] = d.board[15, 1] = "knight"
	d.board[3, 1] = d.board[14, 1] = "ferocious_leopard"
	d.board[4, 1] = d.board[13, 1] = "iron_general"
	d.board[5, 1] = d.board[12, 1] = "copper_general"
	d.board[6, 1] = d.board[11, 1] = "silver_general"
	d.board[7, 1] = d.board[10, 1] = "gold_general"
	d.board[8, 1] = "king"
	d.board[9, 1] = "drunk_elephant"
	
	d.board[1, 2] = d.board[16, 2] = "reverse_chariot"
	d.board[3, 2] = d.board[14, 2] = "chariot_soldier"
	d.board[4, 2] = d.board[13, 2] = "chariot_soldier"
	d.board[6, 2] = d.board[11, 2] = "blind_tiger"
	d.board[7, 2] = "kirin"
	d.board[10, 2] = "phoenix"
	d.board[8, 2] = "lion"
	d.board[9, 2] = "queen"

	d.board[1, 3] = d.board[16, 3] = "side_soldier"
	d.board[2, 3] = d.board[15, 3] = "vertical_soldier"
	d.board[3, 3] = d.board[14, 3] = "bishop"
	d.board[4, 3] = d.board[13, 3] = "dragon_horse"
	d.board[5, 3] = d.board[12, 3] = "dragon_king"
	d.board[6, 3] = d.board[11, 3] = "water_buffalo"
	d.board[7, 3] = d.board[10, 3] = "fire_demon"
	d.board[8, 3] = "lion_hawk"
	d.board[9, 3] = "free_eagle"
	
	
	d.board[1, 4] = d.board[16, 4] = "side_mover"
	d.board[2, 4] = d.board[15, 4] = "vertical_mover"
	d.board[3, 4] = d.board[14, 4] = "rook"
	d.board[4, 4] = d.board[13, 4] = "horned_falcon"
	d.board[5, 4] = d.board[12, 4] = "soaring_eagle"
	d.board[6, 4] = d.board[11, 4] = "bishop_general"
	d.board[7, 4] = d.board[10, 4] = "rook_general"
	d.board[8, 4] = "great_general"
	d.board[9, 4] = "vice_general"
	
	for i = 1:16
		d.board[i, 5] = "pawn"
	end
	
	d.board[5, 6] = d.board[12, 6] = "dog"
	

	# black side pieces
	d.board[1, 16] = d.board[16, 16] = "lance"
	d.board[2, 16] = d.board[15, 16] = "knight"
	d.board[3, 16] = d.board[14, 16] = "ferocious_leopard"
	d.board[4, 16] = d.board[13, 16] = "iron_general"
	d.board[5, 16] = d.board[12, 16] = "copper_general"
	d.board[6, 16] = d.board[11, 16] = "silver_general"
	d.board[7, 16] = d.board[10, 16] = "gold_general"
	d.board[9, 16] = "king"
	d.board[8, 16] = "drunk_elephant"
	
	d.board[1, 15] = d.board[16, 15] = "reverse_chariot"
	d.board[3, 15] = d.board[14, 15] = "chariot_soldier"
	d.board[4, 15] = d.board[13, 15] = "chariot_soldier"
	d.board[6, 15] = d.board[11, 15] = "blind_tiger"
	d.board[10, 15] = "kirin"
	d.board[7, 15] = "phoenix"
	d.board[9, 15] = "lion"
	d.board[8, 15] = "queen"

	d.board[1, 14] = d.board[16, 14] = "side_soldier"
	d.board[2, 14] = d.board[15, 14] = "vertical_soldier"
	d.board[3, 14] = d.board[14, 14] = "bishop"
	d.board[4, 14] = d.board[13, 14] = "dragon_horse"
	d.board[5, 14] = d.board[12, 14] = "dragon_king"
	d.board[6, 14] = d.board[11, 14] = "water_buffalo"
	d.board[7, 14] = d.board[10, 14] = "fire_demon"
	d.board[9, 14] = "lion_hawk"
	d.board[8, 14] = "free_eagle"
	
	
	d.board[1, 13] = d.board[16, 13] = "side_mover"
	d.board[2, 13] = d.board[15, 13] = "vertical_mover"
	d.board[3, 13] = d.board[14, 13] = "rook"
	d.board[4, 13] = d.board[13, 13] = "horned_falcon"
	d.board[5, 13] = d.board[12, 13] = "soaring_eagle"
	d.board[6, 13] = d.board[11, 13] = "bishop_general"
	d.board[7, 13] = d.board[10, 13] = "rook_general"
	d.board[9, 13] = "great_general"
	d.board[8, 13] = "vice_general"
	
	for i = 1:16
		d.board[i, 12] = "pawn"
	end
	
	d.board[5, 11] = d.board[12, 11] = "dog"

	
	d.pieces = Array{piece}(156)
	counter = 1
	for i = 1:16
		for j = 1:16
			if d.board[i,j] != " "
				if j <= 6
					d.pieces[counter] = piece(d.board[i,j], 'w', i, j, false, false, 1)
				else
					d.pieces[counter] = piece(d.board[i,j], 'b', i, j, false, false, 1)
				end
				counter = counter + 1
			end
		end
	end
	
	
	
	
	counter = 1
	for i = 1:156
		if d.pieces[i].name == "horned_falcon"
			d.pieces[i].maxCapture = 2
		elseif d.pieces[i].name == "soaring_eagle"
			d.pieces[i].maxCapture = 2
		elseif d.pieces[i].name == "lion"
			d.pieces[i].maxCapture = 2
		elseif d.pieces[i].name == "lion_hawk"
			d.pieces[i].maxCapture = 2
		end
	end
	
	# define occupied coordinates
	d.occupied = Array{Bool}(16,16)
	
	for i = 1:16
		for j = 1:16
			d.occupied[i, j] = false
		end
	end
	for i = 1:16
		d.occupied[i, 1] = true
		d.occupied[i, 2] = true
		d.occupied[i, 3] = true
		d.occupied[i, 4] = true
		d.occupied[i, 5] = true
		
		d.occupied[i, 12] = true
		d.occupied[i, 13] = true
		d.occupied[i, 14] = true
		d.occupied[i, 15] = true
		d.occupied[i, 16] = true
	end
	d.occupied[2, 2] = d.occupied[2, 15] = false
	d.occupied[5, 2] = d.occupied[5, 15] = false
	d.occupied[12,2] = d.occupied[12,15] = false
	d.occupied[15,2] = d.occupied[15,15] = false
	
	d.occupied[5, 6] = d.occupied[12, 6] = true
	d.occupied[5,11] = d.occupied[12,11] = true


	return d
end

function updateBoard(b::shogiData)
	#clear board
	bs = size(b.board)
	boardSize = bs[1]
	for i = 1:boardSize
		for j = 1:boardSize
			b.board[i,j] = " "
		end
	end

	#update board
	local numPieces = 92
	#println("boardSize: ",boardSize)
	if boardSize == 5
		numPieces = 12
	elseif boardSize == 9
		numPieces = 40
	elseif boardSize == 16
		numPieces = 156
	end
	
	for i = 1:numPieces
		if b.pieces[i].captured == false
			if b.pieces[i].sourcex > boardSize || b.pieces[i].sourcex <= 0 || b.pieces[i].sourcey > boardSize || b.pieces[i].sourcey <= 0 
				# out of bounds
			else
				b.board[b.pieces[i].sourcex, b.pieces[i].sourcey] = b.pieces[i].name
			end
		end
	end

	return b.board

end

function displayParse(s::String)
	k=s[1]
	v=s[2]
	flag = 0
	for i = 1:length(s)
		if s[i] == '_'
			v=s[i+1]
			flag = 1
			break;
		end
	end
	if s == "kirin"
		return "kr"
	elseif s == "phoenix"
		return "ph"
	elseif s == "lion"
		return "ln"
	elseif s == "gold_general"
		return "g "
	elseif s == "silver_general"
		return "s "
	elseif s == "copper_general"
		return "c "
	elseif s == "iron_general"
		return "i "
	elseif s == "dog"
		return "d "
	end
	
	if flag == 0
		return string(k," ")
	end
	return string(k,v)
end

function Display(b::shogiData)
	local colours = Dict{String,String}("normal" =>"\x1B[0m",
									"yellow" =>"\x1B[33m",
									"green"  =>"\x1B[32m",
									"red"    =>"\x1B[31m",
									"blue"   =>"\x1B[34m",
									"magenta"=>"\x1B[35m",
									"cyan"   =>"\x1B[36m",
									"white"  =>"\x1B[37m")

	#clear color board
	boardSize = b.boardSize

	local colorBoard = Array{Char}(boardSize,boardSize)
	for i in 1:boardSize
		for j in 1:boardSize
			colorBoard[i,j] = ' '
		end
	end


	local numPieces = 92
	if boardSize == 5
		numPieces = 12
	elseif boardSize == 9
		numPieces = 40
	elseif boardSize == 16
		numPieces = 156
	end


	for i in 1:numPieces
		if b.pieces[i].captured == false
			# println([b.pieces[i].sourcex, b.pieces[i].sourcey])
			colorBoard[b.pieces[i].sourcex,b.pieces[i].sourcey] = b.pieces[i].team
			# println(b.pieces[i].name, " ", b.pieces[i].sourcex,)
		end
	end




	# Get Captured Counts
	local team = 'w'
	local pawnCount = 0
	local lanceCount = 0
	local knightCount = 0
	local gGeneralCount = 0
	local sGeneralCount = 0
	local bishopCount = 0
	local rookCount = 0
	local rChariotCount = 0
	local cGeneralCount = 0
	local dKingCount = 0
	local dElephantCount = 0
	local fLeopardCount = 0
	local dHorseCount = 0
	local lionCount = 0
	local sMoverCount = 0
	local gBetweenCount = 0
	local bTigerCount = 0
	local queenCount = 0
	local vMoverCount = 0
	local phoenixCount = 0

	if b.move.move_number % 2 == 0
		team = 'b'
	end

	for p in b.pieces
		if p.captured == true && p.team == team
			if p.name == "pawn"
				pawnCount += 1
			elseif p.name == "lance"
				lanceCount += 1
			elseif p.name == "knight"
				knightCount += 1
			elseif p.name == "gold_general"
				gGeneralCount += 1
			elseif p.name == "silver_general"
				sGeneralCount += 1
			elseif p.name == "bishop"
				bishopCount += 1
			elseif p.name == "rook"
				rookCount += 1
			elseif p.name == "reverse_chariot"
				rChariotCount += 1
			elseif p.name == "copper_general"
				cGeneralCount += 1
			elseif p.name == "dragon_king"
				dKingCount += 1
			elseif p.name == "drunk_elephant"
				dElephantCount += 1
			elseif p.name == "ferocious_leopard"
				fLeopardCount += 1
			elseif p.name == "dragon_horse"
				dHorseCount += 1
			elseif p.name == "lion"
				lionCount += 1
			elseif p.name == "side_mover"
				sMoverCount += 1
			elseif p.name == "go_between"
				gBetweenCount += 1
			elseif p.name == "blind_tiger"
				bTigerCount += 1
			elseif p.name == "queen"
				queenCount += 1
			elseif p.name == "vertical_mover"
				vMoverCount += 1
			elseif p.name == "phoenix"
				phoenixCount += 1
			end
		end
	end


	for j = boardSize:-1:1
		print(colours["normal"], "|")
		for i = 1:boardSize
			if(b.board[i,j] == "king")
				print(colours["yellow"],b.board[i,j][1], " ")
				print(colours["normal"])
				print("|")
			else
				if b.board[i,j] == " "
					print("  ","|")
				else
					if colorBoard[i,j] == ' '
						println()
						println("error, unmatch color Board and Board")
						exit()
					end
					if colorBoard[i,j] == 'b'
						p = getPieceAtLocation(b, i, j)
						if p.promoted == true
							print(colours["cyan"],uppercase(displayParse(b.board[i,j])))
						else
							print(colours["cyan"],displayParse(b.board[i,j]))
						end

						print(colours["normal"])
						print("|")
					else
						p = getPieceAtLocation(b, i, j)
						if p.promoted == true
							print(colours["normal"],uppercase(displayParse(b.board[i,j])))
						else
							print(colours["normal"],displayParse(b.board[i,j]))
						end

						print("|")
					end
				end
			end
		end

		if boardSize == 9
			if j == 9
				print("\t \t Captures")
			elseif j == 8
				print("\t \t Pawns: ", pawnCount)
			elseif j == 7
				print("\t \t Lances: ", lanceCount)
			elseif j == 6
				print("\t \t Knights: ", knightCount)
			elseif j == 5
				print("\t \t Silver Generals: ", sGeneralCount)
			elseif j == 4
				print("\t \t Gold Generals: ", gGeneralCount)
			elseif j == 3
				print("\t \t Bishops: ", bishopCount)
			elseif j == 2
				print("\t \t Rooks: ", rookCount)
			end
		elseif boardSize == 5
			if j == 5
				print("\t \t Pawns: ", pawnCount)
			elseif j == 4
				print("\t \t Silver Generals: ", sGeneralCount)
			elseif j == 3
				print("\t \t Gold Generals: ", gGeneralCount)
			elseif j == 2
				print("\t \t Bishops: ", bishopCount)
			elseif j == 1
				print("\t \t Rooks: ", rookCount)
			end
		elseif boardSize == 12
			if j == 12
				print("\t Captures")
			elseif j == 11
				print("\t Reverse Chariots: ", rChariotCount)
				print("\t Side Movers: ", sMoverCount)
			elseif j == 10
				print("\t Bishops: ", bishopCount)
				print("\t \t Kirins: ", knightCount)
			elseif j == 9
				print("\t Go-betweens ", gBetweenCount)
				print("\t \t C_Generals: ", cGeneralCount)
			elseif j == 8
				print("\t Dragon Kings: ", dKingCount)
				print("\t Pawns: ", pawnCount)
			elseif j == 7
				print("\t Drunk Elephants: ", dElephantCount)
				print("\t Rooks: ", rookCount)
			elseif j == 6
				print("\t Ferocious Leopards: ", fLeopardCount)
				print("\t S_Generals: ", sGeneralCount)
			elseif j == 5
				print("\t Blind Tigers: ", bTigerCount)
				print("\t G_Generals: ", gGeneralCount)
			elseif j == 4
				print("\t Dragon Horses: ", dHorseCount)
				print("\t Queens: ", queenCount)
			elseif j == 3
				print("\t Vertical Movers: ", vMoverCount)
				print("\t Lions: ", lionCount)
			elseif j == 2
				print("\t Lances: ", lanceCount)
				print("\t \t Phoenixes: ", phoenixCount)
			end
		end

		print("\n")
	end
end

function displayOccupied(d::shogiData)
	for j = d.boardSize:-1:1
		print("|")
		for i = 1:d.boardSize
			if d.occupied[i,j] == true
				print("* ","|")
			else
				print("  ","|")
			end
		end
		println()
	end
end

#testBoard = setup()
#testBoardM = setupM()
#testBoardC = setupC()
#testBoardT = setupT()

#updateBoard(testBoard)
#updateBoard(testBoardM)
#updateBoard(testBoardC)
#updateBoard(testBoardT)

#Display(testBoard)
#Display(testBoardM)
#Display(testBoardC)
#Display(testBoardT)

#displayOccupied(testBoard)
#println()
#displayOccupied(testBoardM)
#println()
#displayOccupied(testBoardC)
#println()
#displayOccupied(testBoardT)

end
