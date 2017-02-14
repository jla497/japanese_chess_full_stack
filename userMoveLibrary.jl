module userMoveLibrary
push!(LOAD_PATH,pwd())
using Definition
using moveLibrary

export move_user_Move
export move_user_Drop

function getPieceIndexAtLocation(shogiBoard, sourcex, sourcey )
    team = 'b'

    if shogiBoard.move.move_number % 2 == 0
        team = 'w'
    end

    if shogiBoard.move.move_type == "drop"
        for index = 1:length(shogiBoard.pieces)
            if shogiBoard.pieces[index].captured == true && shogiBoard.pieces[index].name == shogiBoard.move.option && shogiBoard.pieces[index].team != team
                return index
            end
        end
    else
        for index = 1:length(shogiBoard.pieces)
            if shogiBoard.pieces[index].sourcex == sourcex && shogiBoard.pieces[index].sourcey == sourcey && shogiBoard.pieces[index].captured == false
                return index
            end
        end
    end 
    
    return -1
end

function move_user_Move(shogiBoard::shogiData, prom)
    shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false
    shogiBoard.move.move_type = "move"
    shogiBoard.lionCapture = false
    location = 0
	index = getPieceIndexAtLocation(shogiBoard, shogiBoard.move.sourcex, shogiBoard.move.sourcey)
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
		shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
		shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true #set occupied[targetx,y] = true
		shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
		shogiBoard.pieces[index].sourcey = shogiBoard.move.targety

	else
		if (shogiBoard.move.targetx3 == -1 || shogiBoard.move.targety3 == -1)
            if shogiBoard.pieces[index].maxCapture == 1 && location < 2
                shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
                shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true #set occupied[targetx,y] = true
                shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
                shogiBoard.pieces[index].sourcey = shogiBoard.move.targety
            else
    			shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
    			shogiBoard.occupied[shogiBoard.move.targetx2, shogiBoard.move.targety2] = true #set occupied[targetx,y] = true
    			shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx2
    			shogiBoard.pieces[index].sourcey = shogiBoard.move.targety2
            end

		else
			if (shogiBoard.move.targetx4 == -1 || shogiBoard.move.targety4 == -1)
                if shogiBoard.pieces[index].maxCapture == 1 && location < 2
                    shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
                    shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true #set occupied[targetx,y] = true
                    shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
                    shogiBoard.pieces[index].sourcey = shogiBoard.move.targety
                elseif shogiBoard.pieces[index].maxCapture == 1 && location < 3
                    shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
                    shogiBoard.occupied[shogiBoard.move.targetx2, shogiBoard.move.targety2] = true #set occupied[targetx,y] = true
                    shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx2
                    shogiBoard.pieces[index].sourcey = shogiBoard.move.targety2
                else
    				shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
    				shogiBoard.occupied[shogiBoard.move.targetx3, shogiBoard.move.targety3] = true #set occupied[targetx,y] = true
    				shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx3
    				shogiBoard.pieces[index].sourcey = shogiBoard.move.targety3
                end

			else
				if (shogiBoard.move.targetx5 == -1 || shogiBoard.move.targety5 == -1)
                    if shogiBoard.pieces[index].maxCapture == 1 && location < 2
                        shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
                        shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true #set occupied[targetx,y] = true
                        shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
                        shogiBoard.pieces[index].sourcey = shogiBoard.move.targety
                    elseif shogiBoard.pieces[index].maxCapture == 1 && location < 3
                        shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
                        shogiBoard.occupied[shogiBoard.move.targetx2, shogiBoard.move.targety2] = true #set occupied[targetx,y] = true
                        shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx2
                        shogiBoard.pieces[index].sourcey = shogiBoard.move.targety2
                    elseif shogiBoard.pieces[index].maxCapture == 1 && location < 4
                        shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
                        shogiBoard.occupied[shogiBoard.move.targetx3, shogiBoard.move.targety3] = true #set occupied[targetx,y] = true
                        shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx3
                        shogiBoard.pieces[index].sourcey = shogiBoard.move.targety3
                    else
    					shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
    					shogiBoard.occupied[shogiBoard.move.targetx4, shogiBoard.move.targety4] = true #set occupied[targetx,y] = true
    					shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx4
    					shogiBoard.pieces[index].sourcey = shogiBoard.move.targety4
                    end
				else
                    if shogiBoard.pieces[index].maxCapture == 1 && location < 2
                        shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
                        shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true #set occupied[targetx,y] = true
                        shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
                        shogiBoard.pieces[index].sourcey = shogiBoard.move.targety
                    elseif shogiBoard.pieces[index].maxCapture == 1 && location < 3
                        shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
                        shogiBoard.occupied[shogiBoard.move.targetx2, shogiBoard.move.targety2] = true #set occupied[targetx,y] = true
                        shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx2
                        shogiBoard.pieces[index].sourcey = shogiBoard.move.targety2
                    elseif shogiBoard.pieces[index].maxCapture == 1 && location < 4
                        shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
                        shogiBoard.occupied[shogiBoard.move.targetx3, shogiBoard.move.targety3] = true #set occupied[targetx,y] = true
                        shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx3
                        shogiBoard.pieces[index].sourcey = shogiBoard.move.targety3
                    elseif shogiBoard.pieces[index].maxCapture == 1 && location < 5
                        shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
                        shogiBoard.occupied[shogiBoard.move.targetx4, shogiBoard.move.targety4] = true #set occupied[targetx,y] = true
                        shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx4
                        shogiBoard.pieces[index].sourcey = shogiBoard.move.targety4
                    else
    					shogiBoard.occupied[shogiBoard.move.sourcex, shogiBoard.move.sourcey] = false #set occupied[sourcex,y] = false
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

function move_user_Drop(shogiBoard::shogiData)
    team = 'b'

    if shogiBoard.move.move_number % 2 == 0
        team = 'w'
    end

    found = false
    for p in shogiBoard.pieces
      if p.captured == true && p.name == shogiBoard.move.option && p.team != team
        found = true
      end
    end

    if found == false
      newPiece = piece(shogiBoard.move.option, team,  shogiBoard.move.targetx, shogiBoard.move.targety, false, false)
      prepend!(shogiBoard.pieces, [newPiece])
    else
      index = getPieceIndexAtLocation(shogiBoard, shogiBoard.move.sourcex, shogiBoard.move.sourcey)
      shogiBoard.pieces[index].sourcex = shogiBoard.move.targetx
      shogiBoard.pieces[index].sourcey = shogiBoard.move.targety
      shogiBoard.pieces[index].captured = false
      shogiBoard.pieces[index].promoted = false
      shogiBoard.pieces[index].team = team
      shogiBoard.occupied[shogiBoard.move.targetx, shogiBoard.move.targety] = true
    end

    return shogiBoard
end

end
