module moveLibrary
push!(LOAD_PATH,pwd())
export getPieceAtLocation, getKing, getPrince, getPieceIndexAtLocation, isValidMove, generateMoves, getMoves, isCheck, isSpaceSafe, isCheckmate, makePlay, makeMove, getDropPiece, getKingMoves
using Definition
using userMoveLibrary: move_user_Move, move_user_Drop

function makePlay(table::shogiData, checkValidity)
    table, validity = makeMove(table,  checkValidity, false, true)
    return table, validity
end

function makeMove(table::shogiData, checkValidity::Bool, aiMove::Bool, prom::Bool)
    p = false
    team ='b'

    if table.move.move_number % 2 != 1
        team = 'w'
    end

    if table.move.move_type == "drop"
        p = getDropPiece(table, table.move.option, team)
    else
        p = getPieceAtLocation(table, table.move.sourcex, table.move.sourcey)
    end

    if typeof(p) == Bool
	println("piece not found")
        return table, false
    end

    validity = true

    if checkValidity == true
        tempTable = deepcopy(table)
        validity = isValidMove(tempTable, p, table.move.targetx, table.move.targety)
		
        if aiMove == true
            copyBoard = deepcopy(table)
            if copyBoard.move.move_type == "move" && validity == true
                copyBoard = move_user_Move(copyBoard, prom)
            elseif copyBoard.move.move_type == "drop" && validity == true
                copyBoard = move_user_Drop(copyBoard)
            end

            if isCheck(copyBoard, team) == true
		      validity = false
		    end
        end
    end
	

    if table.move.move_type == "move" && validity == true
        table = move_user_Move(table, prom)
    elseif table.move.move_type == "drop" && validity == true
        table = move_user_Drop(table)
    end

    return table, validity
end

function getDropPiece(shogiBoard, name, team)
    for p in shogiBoard.pieces
        if p.name == name && p.team != team
            return p
        end
    end

    return false
end

function getPieceAtLocation(shogiBoard, sourcex, sourcey)
    for p in shogiBoard.pieces
        if p.sourcex == sourcex && p.sourcey == sourcey
            return p
        end
    end

    return false
end

function GetKing(shogiBoard, team)
    for p in shogiBoard.pieces
        if p.name == 'k' && p.team == team
            return p
        end
    end

    return false
end

function GetPrince(shogiBoard, team)
    for p in shogiBoard.pieces
        if p.name == 'e' && p.promoted == true && p.team == team
            return p
        end
    end

    return false
end

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

function isValidMove(shogiBoard, p, targetx, targety)
    if targetx < 1 || targetx > shogiBoard.boardSize || targety < 1 || targety > shogiBoard.boardSize
        return false
    end

    team = 'b'

    if shogiBoard.move.move_number % 2 == 0
        team = 'w'
    end

    if (p.captured == true && p.team != team) || shogiBoard.move.move_type == "drop"
        if shogiBoard.occupied[targetx, targety] == true || isValidDrop(shogiBoard, p, targetx, targety) == false
            return false
        end
        
        return true
    elseif p.captured == false && p.team != team
        return false
    end

    x, y, x2, y2, x3, y3, s = getMoves(deepcopy(shogiBoard), p, false)
    valid = false
	index = 0

    for i = 1:length(x)
        if x[i] == targetx && y[i] == targety && x2[i] == shogiBoard.move.targetx2 && y2[i] == shogiBoard.move.targety2 && x3[i] == shogiBoard.move.targetx3 && y3[i] == shogiBoard.move.targety3
            valid = true
			index = i
            break
        end
    end

    if valid == false
        return false
    end
	
    return isValidMoveCheck(deepcopy(shogiBoard), p, targetx, targety, s, index)
end

function isValidDrop(shogiBoard, p, targetx, targety)
    team = 'b'

    if shogiBoard.move.move_number % 2 == 0
        team = 'w'
    end

    found = false

    for checkP in shogiBoard.pieces
        if checkP.captured == true && checkP.team != team && checkP.name == shogiBoard.move.option
            found = true
            p = checkP
            break;
        end
    end

    if found == false
        return false
    end

    if p.name == "pawn"
        if (shogiBoard.move.move_number % 2 == 1 && targety <= 1) || (shogiBoard.move.move_number % 2 == 0 && targety >= shogiBoard.boardSize)
            return false
        end

        for checkP in shogiBoard.pieces
            if checkP.team == team && checkP.sourcex == targetx && checkP.name == "pawn" && checkP.promoted == false
                return false
            end
        end
    elseif p.name == "lance"
        if (shogiBoard.move.move_number % 2 == 1 && targety <= 1) || (shogiBoard.move.move_number % 2 == 0 && targety >= shogiBoard.boardSize)
            return false
        end
    elseif p.name == "knight"
        if (shogiBoard.move.move_number % 2 == 1 && targety <= 2) || (shogiBoard.move.move_number % 2 == 0 && targety >= (shogiBoard.boardSize - 1))
            return false
        end
    end

    return true
end

function isValidMoveCheck(shogiBoard, p, targetx, targety, s, index)
    if targetx < 1 || targetx > shogiBoard.boardSize || targety < 1 || targety > shogiBoard.boardSize
        return false
    end

    if shogiBoard.move.targetx2 != -1 && shogiBoard.move.targety2 != -1 && (shogiBoard.move.targetx2 < 1 || shogiBoard.move.targetx2 > shogiBoard.boardSize || shogiBoard.move.targety2 < 1 || shogiBoard.move.targety2 > shogiBoard.boardSize)
        return false
    end

    if shogiBoard.move.targetx3 != -1 && shogiBoard.move.targety3 != -1 && (shogiBoard.move.targetx3 < 1 || shogiBoard.move.targetx3 > shogiBoard.boardSize || shogiBoard.move.targety3 < 1 || shogiBoard.move.targety3 > shogiBoard.boardSize)
        return false
    end

    x = targetx - p.sourcex
    y = targety - p.sourcey

    if isSliding(shogiBoard, p, targetx, targety, s, index) == true
        if isBlocked(shogiBoard, p, x, y) == true
            return false
        end
    end
	
    if shogiBoard.occupied[targetx, targety] == true
        result = getPieceAtLocation(shogiBoard, targetx, targety)
        if typeof(result) != Bool
            if(result.team == p.team || p.captured == true)
               return false
            end
        end
    end

    if shogiBoard.move.targetx2 != -1 && shogiBoard.move.targety2 != -1
        if shogiBoard.occupied[shogiBoard.move.targetx2, shogiBoard.move.targety2] == true
            result = getPieceAtLocation(shogiBoard, shogiBoard.move.targetx2, shogiBoard.move.targety2)
            if typeof(result) != Bool
                if(result.team == p.team) && (result.sourcex != p.sourcex || result.sourcey != p.sourcey)
                    return false
                end
            end
        end
    end

    if shogiBoard.move.targetx3 != -1 && shogiBoard.move.targety3 != -1
        if shogiBoard.occupied[shogiBoard.move.targetx3, shogiBoard.move.targety3] == true
            result = getPieceAtLocation(shogiBoard, shogiBoard.move.targetx3, shogiBoard.move.targety3)
            if typeof(result) != Bool
                if(result.team == p.team) && (result.sourcex != p.sourcex || result.sourcey != p.sourcey)
                    return false
                end
            end
        end
    end

    if isvalidLionMove(shogiBoard, p, targetx, targety, x, y) == false
        return false
    end

    if p.name == 'k'
        if isSpaceSafe(shogiBoard, p.team, targetx, targety) == false
            return false
        end
    end

    return true
end

function isHop(shogiBoard, p, x, y, i)
    index = abs(i)
    if index == 1
        if p.name == "heavenly_tetrarch" || (p.name == "chariot_soldier" && p.promoted == true)
            if (x == -3 && y == 0) || (x == 3 && y == 0) || (x <= 2 && y >= 2) || (x == 0 && y >= 2) || (x >= 2 && y >= 2) || (x <= 2 && y <= 2) || (x == 0 && y <= 2) || (x >= 2 && y <= 2)
                return true
            end
        end
    end

    return false
end

function isvalidLionMove(shogiBoard, p, targetx, targety, x, y)
    # 1. Lion cannot capture another non-adjacent lion if it is not safe for it the next turn, unless they also capture another piece that is greater value than pawn or go-between
    if p.name == 'i'
        if shogiBoard.move.targetx2 != -1 && shogiBoard.move.targety2 != -1
            target = getPieceAtLocation(shogiBoard, targetx, targety)
            target2 = getPieceAtLocation(shogiBoard, shogiBoard.move.targetx2, shogiBoard.move.targety2)

            if typeof( target2 ) != Bool
                if target2.name == 'i'
                    if typeof( target ) == Bool
                        if isSpaceSafe(shogiBoard, p.team, targetx, targety) == false
                            return false
                        end
                    elseif (target.name == 'p' || target.name == 'o') && target.promoted == false
                        if isSpaceSafe(shogiBoard, p.team, targetx, targety) == false
                            return false
                        end
                    end
                end
            end
        else # Jump to the outer edge instead of 2 moves
            target = getPieceAtLocation(shogiBoard, targetx, targety)

            if typeof( target ) != Bool
                if target.name == 'i' && (abs(x) > 1 || abs(y) > 1) # Other lion is not non-adjacent
                    if isSpaceSafe(shogiBoard, p.team, targetx, targety) == false
                            return false
                    end
                end
            end
        end
    end

    # 2. Can't retaliate against a lion being captured by capturing a lion
    if shogiBoard.lionCapture == true
        target = getPieceAtLocation(shogiBoard, targetx, targety)

        if typeof(target) != Bool
            if target.name == 'i'
                return false
            end
        end
    end

    return true
end

function isSliding(shogiBoard, p, targetx, targety, s, index)
   return s[index]
end

function generateMoves(shogiBoard)
    data = Array{moveTable}(1)
    data[1] = shogiBoard.move

    team = 'b'

    if shogiBoard.move.move_number % 2 == 0
        team = 'w'
    end

    for p in shogiBoard.pieces
        if p.team == team && p.captured == false # Add Moves to Array of Possible Moves
            x, y, x2, y2, x3, y3, s = getMoves(shogiBoard, p, false)
            
            for i = 1:length(x)
                if x2[i] < -1 || x2[i] > shogiBoard.boardSize || y2[i] < -1 || y2[i] > shogiBoard.boardSize
                    x2[i] = -1
                    y2[i] = -1
                end

                move = moveTable(shogiBoard.boardSize, shogiBoard.move.move_number, "move", p.sourcex, p.sourcey, x[i], y[i], "?", false, x2[i], y2[i], -1, -1, -1, -1, -1, -1)
                prepend!(data, [move])
            end
        elseif p.team != team && p.captured == true && (shogiBoard.meta.shogiType == "standard" || shogiBoard.meta.shogiType == "minishogi") # Add Drops to Array of Possible Moves
            x, y = getAllDropLocations(shogiBoard)

            for i = 1:length(x)
                if isValidDrop(shogiBoard, p, x[i], y[i]) == true
                    move = moveTable(shogiBoard.boardSize, shogiBoard.move.move_number, "drop", p.sourcex, p.sourcey, x[i], y[i], p.name, false, -1, -1, -1, -1, -1, -1)
                    prepend!(data, [move])
                end
            end
        end
    end

    pop!(data)

    return data
end

function getAllDropLocations(shogiBoard)
    x = Array{Int16}(1)
    y = Array{Int16}(1)

    x[1] = 1
    y[1] = 1

    for i = 1:shogiBoard.boardSize
        for j = 1:shogiBoard.boardSize
            if shogiBoard.occupied[i, j] == false
                prepend!(x, [i])
                prepend!(y, [j])
            end
        end
    end

    pop!(x)
    pop!(y)

    return x, y
end

function getMoves(shogiBoard, p, cheating)
    x = Array{Int16}
    y = Array{Int16}
    x2 = Array{Int16}
    y2 = Array{Int16}
    s = Array{Bool}

    if p.name == "reverse_chariot"
        x, y, x2, y2, x3, y3, s = getReverseChariotMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "bishop"
        x, y, x2, y2, x3, y3, s = getBishopMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "copper_general"
        x, y, x2, y2, x3, y3, s = getCopperGeneralMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "dragon_king"
        x, y, x2, y2, x3, y3, s = getDragonKingMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "drunk_elephant"
        x, y, x2, y2, x3, y3, s = getDrunkElephantMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "ferocious_leopard"
        x, y, x2, y2, x3, y3, s = getFerociousLeopardMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "gold_general"
        x, y, x2, y2, x3, y3, s = getGoldGeneralMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "dragon_horse"
        x, y, x2, y2, x3, y3, s = getDragonHorseMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "lion"
        x, y, x2, y2, x3, y3, s = getLionMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "king" || p.name == "jeweled_general" || p.name == "king_general"
        x, y, x2, y2, x3, y3, s = getKingMoves(shogiBoard, p.sourcex, p.sourcey)
    elseif p.name == "lance"
        x, y, x2, y2, x3, y3, s = getLanceMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "side_mover"
        x, y, x2, y2, x3, y3, s = getSideMoverMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "kirin"
        x, y, x2, y2, x3, y3, s = getKirinMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "go_between"
        x, y, x2, y2, x3, y3, s = getGoBetweenMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "pawn"
        x, y, x2, y2, x3, y3, s = getPawnMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "rook"
        x, y, x2, y2, x3, y3, s = getRookMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "silver_general"
        x, y, x2, y2, x3, y3, s = getSilverGeneralMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "blind_tiger"
        x, y, x2, y2, x3, y3, s = getBlindTigerMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "queen"
        x, y, x2, y2, x3, y3, s = getQueenMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "vertical_mover"
        x, y, x2, y2, x3, y3, s = getVerticalMoverMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "phoenix"
        x, y, x2, y2, x3, y3, s = getPhoenixMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "bishop_general"
        x, y, x2, y2, x3, y3, s = getBishopGeneralMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "chariot_soldier"
        x, y, x2, y2, x3, y3, s = getChariotSoliderMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "dog"
        x, y, x2, y2, x3, y3, s = getDogMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "fire_demon"
        x, y, x2, y2, x3, y3, s = getFireDemonMoves(shogiBoard, p.sourcex, p.sourcey)
    elseif p.name == "free_eagle"
        x, y, x2, y2, x3, y3, s = getFreeEagleMoves(shogiBoard, p.sourcex, p.sourcey)
    elseif p.name == "great_general"
        x, y, x2, y2, x3, y3, s = getGreatGeneralMoves(shogiBoard, p.sourcex, p.sourcey)
    elseif p.name == "horned_falcon"
        x, y, x2, y2, x3, y3, s = getHornedFalconMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "iron_general"
        x, y, x2, y2, x3, y3, s = getIronGeneralMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "knight"
        x, y, x2, y2, x3, y3, s = getKnightMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "lion_hawk"
        x, y, x2, y2, x3, y3, s = getLionHawkMoves(shogiBoard, p.sourcex, p.sourcey)
    elseif p.name == "rook_general"
        x, y, x2, y2, x3, y3, s = getRookGeneralMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "side_soldier"
        x, y, x2, y2, x3, y3, s = getSideSoldierMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "soaring_eagle"
        x, y, x2, y2, x3, y3, s = getSoaringEagleMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "vertical_soldier"
        x, y, x2, y2, x3, y3, s = getVerticalSoldierMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    elseif p.name == "vice_general"
        x, y, x2, y2, x3, y3, s = getViceGeneralMoves(shogiBoard, p.sourcex, p.sourcey)
    elseif p.name == "water_buffalo"
        x, y, x2, y2, x3, y3, s = getWaterBuffaloMoves(shogiBoard, p.sourcex, p.sourcey, p.promoted)
    end

    if cheating == false
        x, y, x2, y2, x3, y3 = removeInvalidMoves(deepcopy(shogiBoard), p, x, y, x2, y2, x3, y3, s)
    end

    return x, y, x2, y2, x3, y3, s
end

function noSecondMove(s)
    x2 = Array{Int16}(s)
    y2 = Array{Int16}(s)

    for i = 1:s
        x2[i] = -1
        y2[i] = -1
    end

    return x2, y2
end

function removeInvalidMoves(shogiBoard, p, x, y, x2, y2, x3, y3, s)
    len = length(x)
    i = 1

    while i <= len
        if len == 0
            return x, y
        end

        shogiBoard.move.targetx2 = x2[i]
        shogiBoard.move.targety2 = y2[i]
        shogiBoard.move.targetx3 = x3[i]
        shogiBoard.move.targety3 = y3[i]

        if isValidMoveCheck(shogiBoard, p, x[i], y[i], s, i) == false
            x = deleteat!(x, i)
            y = deleteat!(y, i)
            x2 = deleteat!(x2, i)
            y2 = deleteat!(y2, i)
            x3 = deleteat!(x3, i)
            y3 = deleteat!(y3, i)
            s = deleteat!(s, i)
        else
            i += 1
        end

        len = length(x)
    end

    return x, y, x2, y2, x3, y3
end

function isBlocked(shogiBoard, p, x, y)
    hops = false

    if p.name == "vice_general" || p.name == "bishop_general" || p.name == "great_general" || p.name == "rook_general"
        hops = true
    end

    if x == 0 && y != 0
        increase = Int16(y / abs(y))
        i = 0

        while true
            if p.sourcey + i > shogiBoard.boardSize
                return false
            end

            if shogiBoard.occupied[p.sourcex, p.sourcey + i] == true && i != 0 && i != y
                if hops == false && isHop(shogiBoard, p, x, y, i) == false
                    return true
                elseif hops == true && isHop(shogiBoard, p, x, y, i) == false
                    if shogiBoard.occupied[p.sourcex + x, p.sourcey + y] == false
                        return true
                    end

                    if greaterRank(p, getPieceAtLocation(shogiBoard, p.sourcex, Int16(p.sourcey + i))) == false
                        return true
                    end
                end
            end

            i = i + increase

            if (y < 0 && i < y) || (y > 0 && i > y)
                break
            end
        end
    elseif x != 0 && y == 0
        increase = Int16(x / abs(x))
        i = 0

        while true
            if p.sourcex + i > shogiBoard.boardSize
                return false
            end

            if shogiBoard.occupied[p.sourcex + i, p.sourcey] == true && i != 0 && i != x
                if hops == false && isHop(shogiBoard, p, x, y, i) == false
                    return true
                elseif hops == true && isHop(shogiBoard, p, x, y, i) == false
                    if shogiBoard.occupied[p.sourcex + x, p.sourcey + y] == false
                        return true
                    end

                    if greaterRank(p, getPieceAtLocation(shogiBoard, Int16(p.sourcex + i), p.sourcey)) == false
                        return true
                    end
                end
            end

            i = i + increase

            if (x < 0 && i < x) || (x > 0 && i > x)
                break
            end
        end
    elseif (x > 0 && y > 0) || (x < 0 && y < 0)
        increase = Int16(x / abs(x))
        i = 0

        while true
            if p.sourcex + i > shogiBoard.boardSize || p.sourcey + i > shogiBoard.boardSize
                return false
            end

            if shogiBoard.occupied[p.sourcex + i, p.sourcey + i] == true && i != 0 && i != x
                if hops == false && isHop(shogiBoard, p, x, y, i) == false
                    return true
                elseif hops == true && isHop(shogiBoard, p, x, y, i) == false
                    if shogiBoard.occupied[p.sourcex + x, p.sourcey + y] == false
                        return true
                    end

                    if greaterRank(p, getPieceAtLocation(shogiBoard, Int16(p.sourcex + i), Int16(p.sourcey + i))) == false
                        return true
                    end
                end
            end

            i = i + increase

            if (x < 0 && i < x) || (x > 0 && i > x)
                break
            end
        end
    elseif (x > 0 && y < 0) || (x < 0 && y > 0)
        increase = Int16(x / abs(x))
        i = 0

        while true
            if p.sourcex + i > shogiBoard.boardSize || p.sourcey - i < 1 || p.sourcey - i > shogiBoard.boardSize
                return false
            end

            if shogiBoard.occupied[p.sourcex + i, p.sourcey - i] == true && i != 0 && i != x
                if hops == false && isHop(shogiBoard, p, x, y, i) == false
                    return true
                elseif hops == true && isHop(shogiBoard, p, x, y, i) == false
                    if shogiBoard.occupied[p.sourcex + x, p.sourcey + y] == false
                        return true
                    end

                    if greaterRank(p, getPieceAtLocation(shogiBoard, Int16(p.sourcex + i), Int16(p.sourcey - i))) == false
                        return true
                    end
                end
            end

            i = i + increase

            if (x < 0 && i < x) || (x > 0 && i > x)
                break
            end
        end
    end
  return false
end

function greaterRank(movingPiece, jumpedPiece)
    if jumpedPiece.name != "king" && jumpedPiece.name != "prince" && jumpedPiece.name != "great_general" && jumpedPiece.name != "vice_general" && jumpedPiece.name != "rook_general" && jumpedPiece.name != "bishop_general"
        return true
    end

    rank = Dict("king" => 1, "prince" => 1, "great_general" => 2, "vice_general" => 3, "rook_general" => 4, "bishop_general" => 4)

    if rank[movingPiece.name] < rank[jumpedPiece.name]
        return true
    end

    return false
end

function isCheck(shogiBoard, team)
    king = GetKing(shogiBoard, team)

    for p in shogiBoard.pieces
        if p.team != team && p.captured == false
            x, y, x2, y2, x3, y3, s = getMoves(shogiBoard, p, false)

            for i = 1:length(x)
                if (x[i] == king.sourcex && y[i] == king.sourcey) || (x2[i] == king.sourcex && y2[i] == king.sourcey)
                    return true
                end
            end
        end
    end

    return false
end

function isSpaceSafe(shogiBoard, team, targetx, targety)
    for p in shogiBoard.pieces
        if p.team != team && p.captured == false
            x, y, x2, y2, x3, y3, s = getMoves(shogiBoard, p, false)

            for i = 1:length(x)
                if (x[i] == targetx && y[i] == targety) || (x2[i] == targetx && y2[i] == targety)
                    return false
                end
            end
        end
    end

    return true
end

function isCheckmate(shogiBoard, team)
    if isCheck(shogiBoard, team) == false
        return false
    end

    king = GetKing(shogiBoard, team)

    x, y, x2, y2, x3, y3, s = getMoves(shogiBoard,king, false)

    # 1. Check if king has a safe space to move to
    for i = 1:length(x)
        if isSpaceSafe(shogiBoard, team, x, y) == true
            return false
        end
    end

    checkCount = 0
    local attackingPiece1::piece
    local attackingPiece2::piece

    for p in shogiBoard.pieces
        if p.team != team && p.captured == false
            x, y, x2, y2, x3, y3, s = getMoves(shogiBoard, p, false)

            for i = 1:length(x)
                if (x[i] == king.sourcex && y[i] == king.sourcey) || (x2[i] == king.sourcex && y2[i] == king.sourcey)
                    checkCount += 1

                    if checkCount == 0
                        attackingPiece1 = p
                    else
                        attackingPiece2 = p
                    end
                end
            end
        end
    end

    # 2. Can a piece take out the attacking piece
    if checkCount == 1 # Single Check - any piece can attempt to take out the attacking piece
        for p in shogiBoard.pieces
            if p.team == team && p.captured == false
                x, y, x2, y2, x3, y3, s = getMoves(shogiBoard, p, false)

                for i = 1:length(x)
                    if (x[i] == attackingPiece1.sourcex && y[i] == attackingPiece1.sourcey) || (x2[i] == attackingPiece1.sourcex && y2[i] == attackingPiece1.sourcey)
                        return false
                    end
                end
            end
        end
    else # Double Check - only the king can take one of the 2 pieces
        x, y, x2, y2, x3, y3, s = getMoves(shogiBoard, king, false)

        for i = 1:length(x)
            if (x[i] == attackingPiece1.sourcex && y[i] == attackingPiece1.sourcey) || (x[i] == attackingPiece2.sourcex && y[i] == attackingPiece2.sourcey)
                return false
            end
        end

        return true # can't block a double check so no point in checking the code below
    end

    # 3. Can a piece block the attack (only works with single check)
    vecX, vecY = getAttackingVector(attackingPiece1, king)

    for p in shogiBoard.pieces
        if p.team == team
            x, y, x2, y2, x3, y3, s = getMoves(shogiBoard, p, false)

            for i = 1:length(x)
                for blockY in 0:vecY
                    if x[i] == king.sourcex && y[i] == (king.sourcey + blockY) && vecX == 0 && vecY != 0 && blockY != 0
                        return false
                    end
                end

                for blockY in 0:vecX
                    if x[i] == (king.sourcex + blockX) && y[i] == king.sourcey && vecX != 0 && vecY == 0 && blockX != 0
                        return false
                    end
                end

                for blockX in 0:vecX
                    if x[i] == (king.sourcex + blockX) && y[i] == (king.sourcey + blockX) && ((vecX > 0 && vecY > 0) || (vecX < 0 && vecY < 0)) > 0 && blockX != 0
                        return false
                    end
                end

                for blockX in 0:vecX
                    if x[i] == (king.sourcex + blockX) && y[i] == (king.sourcey - blockX) && ((vecX > 0 && vecY < 0) || (vecX < 0 && vecY > 0)) > 0 && blockX != 0
                        return false
                    end
                end
            end
        end
    end

    return true
end

function getAttackingVector(attacker, king)
    x = attacker.sourcex - king.sourcex
    y = attacker.sourcey - king.sourcey

    return x, y
end


#= Get Valid Moves ================================================================================================================================================================================================================== =#

function getKingMoves(shogiBoard, sourcex, sourcey)
    x = Array{Int16}(8)
    y = Array{Int16}(8)
    s = falses(8)

    x[1] = sourcex
    y[1] = sourcey + 1
    x[2] = sourcex + 1
    y[2] = sourcey + 1
    x[3] = sourcex + 1
    y[3] = sourcey
    x[4] = sourcex + 1
    y[4] = sourcey - 1
    x[5] = sourcex
    y[5] = sourcey - 1
    x[6] = sourcex - 1
    y[6] = sourcey - 1
    x[7] = sourcex - 1
    y[7] = sourcey
    x[8] = sourcex - 1
    y[8] = sourcey + 1

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getPrinceMoves(shogiBoard, sourcex, sourcey)
    return getKingMoves(shogiBoard, sourcex, sourcey)
end

function getGoldGeneralMoves(shogiBoard, sourcex, sourcey, promoted)
    if (shogiBoard.meta.shogiType == "chu" || shogiBoard.meta.shogiType == "ten") && promoted == true
        return getRookMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(6)
    y = Array{Int16}(6)
    s = falses(6)

    x[1] = sourcex
    y[1] = sourcey + 1
    x[2] = sourcex + 1
    y[2] = sourcey
    x[3] = sourcex
    y[3] = sourcey - 1
    x[4] = sourcex - 1
    y[4] = sourcey

    if shogiBoard.move.move_number % 2 == 1
        x[5] = sourcex + 1
        y[5] = sourcey - 1
        x[6] = sourcex - 1
        y[6] = sourcey - 1
    else
        x[5] = sourcex + 1
        y[5] = sourcey + 1
        x[6] = sourcex - 1
        y[6] = sourcey + 1
    end

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getSilverGeneralMoves(shogiBoard, sourcex, sourcey, promoted)
    if (shogiBoard.meta.shogiType == "chu" || shogiBoard.meta.shogiType == "ten") && promoted == true
        return getVerticalMoverMoves(shogiBoard, sourcex, sourcey, false)
    elseif promoted == true
        return getGoldGeneralMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(5)
    y = Array{Int16}(5)
    s = falses(5)

    if shogiBoard.move.move_number % 2 == 1
        x[1] = sourcex
        y[1] = sourcey - 1
    else
        x[1] = sourcex
        y[1] = sourcey + 1
    end

    x[2] = sourcex + 1
    y[2] = sourcey + 1
    x[3] = sourcex + 1
    y[3] = sourcey - 1
    x[4] = sourcex - 1
    y[4] = sourcey - 1
    x[5] = sourcex - 1
    y[5] = sourcey + 1

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getCopperGeneralMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getSideMoverMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(4)
    y = Array{Int16}(4)
    s = falses(4)

    x[1] = sourcex
    y[1] = sourcey + 1
    x[2] = sourcex
    y[2] = sourcey - 1

    if shogiBoard.move.move_number % 2 == 1
        x[3] = sourcex - 1
        y[3] = sourcey - 1
        x[4] = sourcex + 1
        y[4] = sourcey - 1
    else
        x[3] = sourcex + 1
        y[3] = sourcey + 1
        x[4] = sourcex - 1
        y[4] = sourcey + 1
    end

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getGoBetweenMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getDrunkElephantMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(2)
    y = Array{Int16}(2)
    s = falses(2)

    x[1] = sourcex
    y[1] = sourcey + 1
    x[2] = sourcex
    y[2] = sourcey - 1

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getPawnMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getGoldGeneralMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)

    x[1] = sourcex

    if shogiBoard.move.move_number % 2 == 1
        y[1] = sourcey - 1
    else
        y[1] = sourcey + 1
    end

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getSideMoverMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getFreeBoarMoves(shogiBoard, sourcex, sourcey)
    end

    x = Array{Int16}(2)
    y = Array{Int16}(2)
    s = falses(2)

    x[1] = sourcex
    y[1] = sourcey + 1
    x[2] = sourcex
    y[2] = sourcey - 1

    for i = sourcex-1:-1:1
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
    end

    for i = sourcex+1:shogiBoard.boardSize
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
    end

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getVerticalMoverMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getFlyingOxMoves(shogiBoard, sourcex, sourcey)
    end

    x = Array{Int16}(2)
    y = Array{Int16}(2)
    s = falses(2)

    x[1] = sourcex + 1
    y[1] = sourcey
    x[2] = sourcex - 1
    y[2] = sourcey

    for i = sourcey-1:-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcey+1:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end
    
    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getBishopMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getDragonHorseMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)

    x[1] = sourcex
    y[1] = sourcey
    count = 1

    for i = sourcey-1:-1:1
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey-1:-1:1
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    pop!(x)
    pop!(y)
    pop!(s)
    
    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getDragonHorseMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getHornedFalconMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(4)
    y = Array{Int16}(4)
    s = falses(4)

    x[1] = sourcex
    y[1] = sourcey + 1
    x[2] = sourcex + 1
    y[2] = sourcey
    x[3] = sourcex
    y[3] = sourcey - 1
    x[4] = sourcex - 1
    y[4] = sourcey
    count = 1

    for i = sourcey-1:-1:1
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey-1:-1:1
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getRookMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getDragonKingMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)

    x[1] = sourcex
    y[1] = sourcey

    for i = sourcey-1:-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcey+1:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcex-1:-1:1
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
    end

    for i = sourcex+1:shogiBoard.boardSize
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
    end

    pop!(x)
    pop!(y)
    pop!(s)

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getDragonKingMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getSoaringEagleMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(4)
    y = Array{Int16}(4)
    s = falses(4)

    x[1] = sourcex - 1
    y[1] = sourcey - 1
    x[2] = sourcex + 1
    y[2] = sourcey - 1
    x[3] = sourcex + 1
    y[3] = sourcey + 1
    x[4] = sourcex - 1
    y[4] = sourcey + 1

    for i = sourcey-1:-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcey+1:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcex-1:-1:1
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
    end

    for i = sourcex+1:shogiBoard.boardSize
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
    end

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getBlindTigerMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getFlyingStagMoves(shogiBoard, sourcex, sourcey)
    end

    x = Array{Int16}(7)
    y = Array{Int16}(7)
    s = falses(7)

    x[1] = sourcex + 1
    y[1] = sourcey + 1
    x[2] = sourcex + 1
    y[2] = sourcey
    x[3] = sourcex + 1
    y[3] = sourcey - 1

    if shogiBoard.move.move_number % 2 == 1
        x[4] = sourcex
        y[4] = sourcey + 1
    else
        x[4] = sourcex
        y[4] = sourcey - 1
    end

    x[5] = sourcex - 1
    y[5] = sourcey - 1
    x[6] = sourcex - 1
    y[6] = sourcey
    x[7] = sourcex - 1
    y[7] = sourcey + 1

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getFerociousLeopardMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getBishopMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(6)
    y = Array{Int16}(6)
    s = falses(6)

    x[1] = sourcex
    y[1] = sourcey + 1
    x[2] = sourcex + 1
    y[2] = sourcey + 1
    x[3] = sourcex + 1
    y[3] = sourcey -1
    x[4] = sourcex
    y[4] = sourcey -1
    x[5] = sourcex -1
    y[5] = sourcey -1
    x[6] = sourcex -1
    y[6] = sourcey + 1

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getDrunkElephantMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getPrinceMoves(shogiBoard, sourcex, sourcey)
    end

    x = Array{Int16}(7)
    y = Array{Int16}(7)
    s = falses(7)

    if shogiBoard.move.move_number % 2 == 1
        x[1] = sourcex
        y[1] = sourcey - 1
    else
        x[1] = sourcex
        y[1] = sourcey + 1
    end

    x[2] = sourcex + 1
    y[2] = sourcey + 1
    x[3] = sourcex + 1
    y[3] = sourcey
    x[4] = sourcex + 1
    y[4] = sourcey -1
    x[5] = sourcex -1
    y[5] = sourcey -1
    x[6] = sourcex -1
    y[6] = sourcey
    x[7] = sourcex -1
    y[7] = sourcey + 1

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getLanceMoves(shogiBoard, sourcex, sourcey, promoted)
    if (shogiBoard.meta.shogiType == "chu" || shogiBoard.meta.shogiType == "ten") && promoted == true
        return getWhiteHorseMoves(shogiBoard, sourcex, sourcey)
    elseif promoted == true
        return getGoldGeneralMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)
    x[1] = sourcex
    y[1] = sourcey

    if shogiBoard.move.move_number % 2 == 1 && sourcey > 1
        for i = sourcey-1:-1:1
            prepend!(x, [sourcex])
            prepend!(y, [i])
            prepend!(s, [true])
        end
    elseif sourcey < shogiBoard.boardSize
        for i = sourcey+1:shogiBoard.boardSize
            prepend!(x, [sourcex])
            prepend!(y, [i])
            prepend!(s, [true])
        end
    end
    
    pop!(x)
    pop!(y)
    pop!(s)

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getReverseChariotMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getWhaleMoves(shogiBoard, sourcex, sourcey)
    end

    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)
    x[1] = sourcex
    y[1] = sourcey

    for i = (sourcey-1):-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcey+1:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end
    
    pop!(x)
    pop!(y)
    pop!(s)

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getKirinMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getLionMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(8)
    y = Array{Int16}(8)
    s = falses(8)

    x[1] = sourcex + 1
    y[1] = sourcey + 1
    x[2] = sourcex + 1
    y[2] = sourcey - 1
    x[3] = sourcex - 1
    y[3] = sourcey - 1
    x[4] = sourcex - 1
    y[4] = sourcey + 1
    x[5] = sourcex
    y[5] = sourcey + 2
    x[6] = sourcex + 2
    y[6] = sourcey
    x[7] = sourcex
    y[7] = sourcey - 2
    x[8] = sourcex - 2
    y[8] = sourcey

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getKnightMoves(shogiBoard, sourcex, sourcey, promoted)
    if (shogiBoard.meta.shogiType == "chu" || shogiBoard.meta.shogiType == "ten") && promoted == true
        return getSideSoldierMoves(shogiBoard, sourcex, sourcey, false)
    elseif promoted == true
        return getGoldGeneralMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(2)
    y = Array{Int16}(2)
    s = falses(2)

    if shogiBoard.move.move_number % 2 == 1
        x[1] = sourcex + 1
        y[1] = sourcey - 2
        x[2] = sourcex - 1
        y[2] = sourcey - 2
    else
        x[1] = sourcex + 1
        y[1] = sourcey + 2
        x[2] = sourcex - 1
        y[2] = sourcey + 2
    end

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getPhoenixMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getQueenMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(8)
    y = Array{Int16}(8)
    s = falses(8)
    x[1] = sourcex
    y[1] = sourcey + 1
    x[2] = sourcex + 1
    y[2] = sourcey
    x[3] = sourcex
    y[3] = sourcey - 1
    x[4] = sourcex - 1
    y[4] = sourcey
    x[5] = sourcex - 2
    y[5] = sourcey + 2
    x[6] = sourcex + 2
    y[6] = sourcey + 2
    x[7] = sourcex + 2
    y[7] = sourcey - 2
    x[8] = sourcex - 2
    y[8] = sourcey - 2

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end


function getQueenMoves(shogiBoard, sourcex, sourcey, promoted)
    if shogiBoard.meta.shogiType == "ten" && promoted == true
        return getFreeEagleMoves(shogiBoard, sourcex, sourcey)
    end

    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)

    x[1] = sourcex
    y[1] = sourcey
    count = 1

    for i = sourcey-1:-1:1
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey-1:-1:1
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    for i = sourcey-1:-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcey+1:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcex-1:-1:1
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
    end

    for i = sourcex+1:shogiBoard.boardSize
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
    end

    pop!(x)
    pop!(y)
    pop!(s)

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getFlyingStagMoves(shogiBoard, sourcex, sourcey)
    x = Array{Int16}(6)
    y = Array{Int16}(6)
    s = falses(6)

    x[1] = sourcex + 1
    y[1] = sourcey + 1
    x[2] = sourcex + 1
    y[2] = sourcey
    x[3] = sourcex + 1
    y[3] = sourcey - 1
    x[4] = sourcex - 1
    y[4] = sourcey + 1
    x[5] = sourcex - 1
    y[5] = sourcey
    x[6] = sourcex - 1
    y[6] = sourcey - 1

    for i = sourcey-1:-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcey+1:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getFlyingOxMoves(shogiBoard, sourcex, sourcey)
    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)

    x[1] = sourcex
    y[1] = sourcey
    count = 1

    for i = sourcey-1:-1:1
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey-1:-1:1
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    for i = sourcey-1:-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcey+1:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    pop!(x)
    pop!(y)
    pop!(s)

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getFreeBoarMoves(shogiBoard, sourcex, sourcey)
    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)

    x[1] = sourcex
    y[1] = sourcey
    count = 1

    for i = sourcey-1:-1:1
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey-1:-1:1
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])

        count += 1
    end

    for i = sourcex-1:-1:1
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
    end

    for i = sourcex+1:shogiBoard.boardSize
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
    end

    pop!(x)
    pop!(y)
    pop!(s)

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getWhaleMoves(shogiBoard, sourcex, sourcey)
    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)

    x[1] = sourcex
    y[1] = sourcey
    count = 1

    if shogiBoard.move.move_number % 2 == 1
        count = 1

        for i = sourcey+1:shogiBoard.boardSize
            if (sourcex + count) >= (shogiBoard.boardSize + 1)
                break
            end

            prepend!(x, [sourcex + count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end

        count = 1

        for i = sourcey+1:shogiBoard.boardSize
            if (sourcex - count) <= 0
                break
            end

            prepend!(x, [sourcex - count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end
    else
        for i = sourcey-1:-1:1
            if (sourcex - count) <= 0
                break
            end

            prepend!(x, [sourcex - count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end

        count = 1

        for i = sourcey-1:-1:1
            if (sourcex + count) >= (shogiBoard.boardSize + 1)
                break
            end

            prepend!(x, [sourcex + count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end
    end

    for i = sourcey-1:-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcey+1:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    pop!(x)
    pop!(y)
    pop!(s)

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getWhiteHorseMoves(shogiBoard, sourcex, sourcey)
    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)

    x[1] = sourcex
    y[1] = sourcey
    count = 1

    if shogiBoard.move.move_number % 2 == 1
        for i = sourcey-1:-1:1
            if (sourcex - count) <= 0
                break
            end

            prepend!(x, [sourcex - count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end

        count = 1

        for i = sourcey-1:-1:1
            if (sourcex + count) >= (shogiBoard.boardSize + 1)
                break
            end

            prepend!(x, [sourcex + count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end
    else
        count = 1

        for i = sourcey+1:shogiBoard.boardSize
            if (sourcex + count) >= (shogiBoard.boardSize + 1)
                break
            end

            prepend!(x, [sourcex + count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end

        count = 1

        for i = sourcey+1:shogiBoard.boardSize
            if (sourcex - count) <= 0
                break
            end

            prepend!(x, [sourcex - count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end
    end

    for i = sourcey-1:-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    for i = sourcey+1:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
    end

    pop!(x)
    pop!(y)
    pop!(s)

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getHornedFalconMoves(shogiBoard, sourcex, sourcey, promoted)
    if shogiBoard.meta.shogiType == "ten" && promoted == true
        return getBishopGeneralMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(4)
    y = Array{Int16}(4)
    x2 = Array{Int16}(4)
    y2 = Array{Int16}(4)
    s = falses(4)
    count = 1

    if shogiBoard.move.move_number % 2 == 1
        x[1] = sourcex
        y[1] = sourcey - 1
        x2[1] = -1
        y2[1] = -1
        x[2] = sourcex
        y[2] = sourcey - 1
        x2[2] = sourcex
        y2[2] = sourcey - 2
        x[3] = sourcex
        y[3] = sourcey - 1
        x2[3] = sourcex
        y2[3] = sourcey
        x[4] = sourcex
        y[4] = sourcey - 2
        x2[4] = -1
        y2[4] = -1

        for i = sourcey+1:shogiBoard.boardSize
            prepend!(x, [sourcex])
            prepend!(y, [i])
            prepend!(s, [true])
            prepend!(x2, [-1])
            prepend!(y2, [-1])
        end
    else
        x[1] = sourcex
        y[1] = sourcey + 1
        x2[1] = -1
        y2[1] = -1
        x[2] = sourcex
        y[2] = sourcey + 1
        x2[2] = sourcex
        y2[2] = sourcey + 2
        x[3] = sourcex
        y[3] = sourcey + 1
        x2[3] = sourcex
        y2[3] = sourcey
        x[4] = sourcex
        y[4] = sourcey + 2
        x2[4] = -1
        y2[4] = -1

        for i = sourcey-1:-1:1
            prepend!(x, [sourcex])
            prepend!(y, [i])
            prepend!(s, [true])
            prepend!(x2, [-1])
            prepend!(y2, [-1])
        end
    end

    count = 1

    for i = sourcey-1:-1:1
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])

        count += 1
    end

    count = 1

    for i = sourcey-1:-1:1
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])

        count += 1
    end

    count = 1

    for i = sourcey+1:shogiBoard.boardSize
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])

        count += 1
    end

    for i = sourcex-1:-1:1
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
    end

    for i = sourcex+1:shogiBoard.boardSize
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
    end

    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getSoaringEagleMoves(shogiBoard, sourcex, sourcey, promoted)
    if shogiBoard.meta.shogiType == "ten" && promoted == true
        return getRookGeneralMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(8)
    y = Array{Int16}(8)
    x2 = Array{Int16}(8)
    y2 = Array{Int16}(8)
    s = falses(8)
    count = 1

    if shogiBoard.move.move_number % 2 == 1
        x[1] = sourcex - 1
        y[1] = sourcey - 1
        x2[1] = -1
        y2[1] = -1
        x[2] = sourcex + 1
        y[2] = sourcey - 1
        x2[2] = -1
        y2[2] = -1

        x[3] = sourcex - 1
        y[3] = sourcey - 1
        x2[3] = sourcex - 2
        y2[3] = sourcey - 2
        x[4] = sourcex + 1
        y[4] = sourcey - 1
        x2[4] = sourcex + 2
        y2[4] = sourcey - 2

        x[5] = sourcex - 1
        y[5] = sourcey - 1
        x2[5] = sourcex
        y2[5] = sourcey
        x[6] = sourcex + 1
        y[6] = sourcey - 1
        x2[6] = sourcex
        y2[6] = sourcey

        x[7] = sourcex - 2
        y[7] = sourcey - 2
        x2[7] = -1
        y2[7] = -1
        x[8] = sourcex + 2
        y[8] = sourcey - 2
        x2[8] = -1
        y2[8] = -1

        count = 1

        for i = sourcey+1:shogiBoard.boardSize
            if (sourcex - count) <= 0
                break
            end

            prepend!(x, [sourcex - count])
            prepend!(y, [i])
            prepend!(s, [true])
            prepend!(x2, [-1])
            prepend!(y2, [-1])

            count += 1
        end

        count = 1

        for i = sourcey+1:shogiBoard.boardSize
            if (sourcex + count) >= (shogiBoard.boardSize + 1)
                break
            end

            prepend!(x, [sourcex + count])
            prepend!(y, [i])
            prepend!(s, [true])
            prepend!(x2, [-1])
            prepend!(y2, [-1])

            count += 1
        end
    else
        x[1] = sourcex + 1
        y[1] = sourcey + 1
        x2[1] = -1
        y2[1] = -1
        x[2] = sourcex - 1
        y[2] = sourcey + 1
        x2[2] = -1
        y2[2] = -1

        x[3] = sourcex + 1
        y[3] = sourcey + 1
        x2[3] = sourcex + 2
        y2[3] = sourcey + 2
        x[4] = sourcex - 1
        y[4] = sourcey + 1
        x2[4] = sourcex - 2
        y2[4] = sourcey + 2

        x[5] = sourcex + 1
        y[5] = sourcey + 1
        x2[5] = sourcex
        y2[5] = sourcey
        x[6] = sourcex - 1
        y[6] = sourcey + 1
        x2[6] = sourcex
        y2[6] = sourcey

        x[7] = sourcex + 2
        y[7] = sourcey + 2
        x2[7] = -1
        y2[7] = -1
        x[8] = sourcex - 2
        y[8] = sourcey + 2
        x2[8] = -1
        y2[8] = -1

        count = 1

        for i = sourcey-1:-1:1
            if (sourcex - count) <= 0
                break
            end

            prepend!(x, [sourcex - count])
            prepend!(y, [i])
            prepend!(s, [true])
            prepend!(x2, [-1])
            prepend!(y2, [-1])

            count += 1
        end

        count = 1

        for i = sourcey-1:-1:1
            if (sourcex + count) >= (shogiBoard.boardSize + 1)
                break
            end

            prepend!(x, [sourcex + count])
            prepend!(y, [i])
            prepend!(s, [true])
            prepend!(x2, [-1])
            prepend!(y2, [-1])

            count += 1
        end
    end

    for i = sourcey-1:-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
    end

    for i = sourcey+1:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
    end

    for i = sourcex-1:-1:1
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
    end

    for i = sourcex+1:shogiBoard.boardSize
        prepend!(x, [i])
        prepend!(y, [sourcey])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
    end

    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getLionMoves(shogiBoard, sourcex, sourcey, promoted)
    if shogiBoard.meta.shogiType == "ten" && promoted == true
        return getLionHawkMoves(shogiBoard, sourcex, sourcey)
    end

    x, y, x2, y2, x3, y3, s = getKingMoves(shogiBoard, sourcex, sourcey)
    i = 1
    len = length(x)
    tempX = deepcopy(x)
    tempY = deepcopy(y)

    while i <= len
        newX, newY, newX2, newY2, newX3, newY3, newS = getKingMoves(shogiBoard, tempX[i], tempY[i])

        for j = 1:length(newX)
            prepend!(x, [tempX[i]])
            prepend!(y, [tempY[i]])
            prepend!(x2, [newX[j]])
            prepend!(y2, [newY[j]])
            prepend!(x3, [-1])
            prepend!(y3, [-1])
            prepend!(s, [false])
        end

        i += 1
    end

    prepend!(x, [sourcex])
    prepend!(y, [sourcey + 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex + 1])
    prepend!(y, [sourcey + 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex + 2])
    prepend!(y, [sourcey + 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex + 2])
    prepend!(y, [sourcey + 1])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex + 2])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex  + 2])
    prepend!(y, [sourcey - 1])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex + 2])
    prepend!(y, [sourcey - 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex + 1])
    prepend!(y, [sourcey - 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex])
    prepend!(y, [sourcey - 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex - 1])
    prepend!(y, [sourcey - 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex - 2])
    prepend!(y, [sourcey - 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex - 2])
    prepend!(y, [sourcey - 1])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex - 2])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex - 2])
    prepend!(y, [sourcey + 1])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex - 2])
    prepend!(y, [sourcey + 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex - 1])
    prepend!(y, [sourcey + 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getViceGeneralMoves(shogiBoard, sourcex, sourcey)
    x, y, x2, y2, x3, y3, s = getKingMoves(shogiBoard, sourcex, sourcey)
    i = 1
    len = length(x)
    tempX = deepcopy(x)
    tempY = deepcopy(y)

    while i <= len
        newX, newY, newX2, newY2, newX3, newY3, newS = getKingMoves(shogiBoard, tempX[i], tempY[i])

        for j = 1:length(newX)
            newerX, newerY, newerX2, newerY2, newerX3, newerY3, newerS = getKingMoves(shogiBoard, newX[j], newY[j])

            prepend!(x, [tempX[i]])
            prepend!(y, [tempY[i]])
            prepend!(x2, [newX[j]])
            prepend!(y2, [newY[j]])
            prepend!(x3, [-1])
            prepend!(y3, [-1])
            prepend!(s, [false])

            for k = 1:length(newerX)
                prepend!(x, [tempX[i]])
                prepend!(y, [tempY[i]])
                prepend!(x2, [newX[j]])
                prepend!(y2, [newY[j]])
                prepend!(x3, [newerX[k]])
                prepend!(y3, [newerY[k]])
                prepend!(s, [false])
            end
        end

        i += 1
    end

    newestX, newestY, newestX2, newestY2, newestX3, newestY3, newestS = getBishopMoves(shogiBoard, sourcex, sourcey, false)
    prepend!(x, newestX)
    prepend!(y, newestY)
    prepend!(x2, newestX2)
    prepend!(y2, newestY2)
    prepend!(x3, newestX3)
    prepend!(y3, newestY3)
    prepend!(s, newestS)

    return x, y, x2, y2, x3, y3, s
end

function getGreatGeneralMoves(shogiBoard, sourcex, sourcey)
    return getQueenMoves(shogiBoard, sourcex, sourcey, false)
end

function getBishopGeneralMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getViceGeneralMoves(shogiBoard, sourcex, sourcey)
    end

    return getBishopMoves(shogiBoard, sourcex, sourcey, false)
end

function getRookGeneralMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getGreatGeneralMoves(shogiBoard, sourcex, sourcey)
    end

    return getRookMoves(shogiBoard, sourcex, sourcey, false)
end

function getFireDemonMoves(shogiBoard, sourcex, sourcey)
    x, y, x2, y2, x3, y3, s = getKingMoves(shogiBoard, sourcex, sourcey)
    i = 1
    len = length(x)
    tempX = deepcopy(x)
    tempY = deepcopy(y)

    while i <= len
        newX, newY, newX2, newY2, newX3, newY3, newS = getKingMoves(shogiBoard, tempX[i], tempY[i])

        for j = 1:length(newX)
            newerX, newerY, newerX2, newerY2, newerX3, newerY3, newerS = getKingMoves(shogiBoard, newX[j], newY[j])

            prepend!(x, [tempX[i]])
            prepend!(y, [tempY[i]])
            prepend!(x2, [newX[j]])
            prepend!(y2, [newY[j]])
            prepend!(x3, [-1])
            prepend!(y3, [-1])
            prepend!(s, [false])

            for k = 1:length(newerX)
                prepend!(x, [tempX[i]])
                prepend!(y, [tempY[i]])
                prepend!(x2, [newX[j]])
                prepend!(y2, [newY[j]])
                prepend!(x3, [newerX[k]])
                prepend!(y3, [newerY[k]])
                prepend!(s, [false])
            end
        end

        i += 1
    end

    newestX, newestY, newestX2, newestY2, newestX3, newestY3, newestS = getFreeBoarMoves(shogiBoard, sourcex, sourcey)
    prepend!(x, newestX)
    prepend!(y, newestY)
    prepend!(x2, newestX2)
    prepend!(y2, newestY2)
    prepend!(x3, newestX3)
    prepend!(y3, newestY3)
    prepend!(s, newestS)

    return x, y, x2, y2, x3, y3, s
end

function getHeavenlyTetrachMoves(shogiBoard, sourcex, sourcey)
    x = Array{Int16}(12)
    y = Array{Int16}(12)
    x2 = Array{Int16}(12)
    y2 = Array{Int16}(12)
    s = Array{Bool}(12)

    x[1] = sourcex
    y[1] = sourcey + 1
    x2[1] = sourcex
    y2[1] = sourcey
    s[1] = false
    x[2] = sourcex + 1
    y[2] = sourcey + 1
    x2[2] = sourcex
    y2[2] = sourcey
    s[2] = false
    x[3] = sourcex + 1
    y[3] = sourcey
    x2[3] = sourcex
    y2[3] = sourcey
    s[3] = false
    x[4] = sourcex + 1
    y[4] = sourcey - 1
    x2[4] = sourcex
    y2[4] = sourcey
    x[5] = sourcex
    s[4] = false
    y[5] = sourcey - 1
    x2[5] = sourcex
    y2[5] = sourcey
    s[5] = false
    x[6] = sourcex - 1
    y[6] = sourcey - 1
    x2[6] = sourcex
    y2[6] = sourcey
    s[6] = false
    x[7] = sourcex - 1
    y[7] = sourcey
    x2[7] = sourcex
    y2[7] = sourcey
    s[7] = false
    x[8] = sourcex - 1
    y[8] = sourcey + 1
    x2[8] = sourcex
    y2[8] = sourcey
    s[8] = false
    x[9] = sourcex + 2
    y[9] = sourcey
    x2[9] = -1
    y2[9] = -1
    s[9] = false
    x[10] = sourcex - 2
    y[10] = sourcey
    x2[10] = -1
    y2[10] = -1
    s[10] = false
    x[11] = sourcex + 3
    y[11] = sourcey
    x2[11] = -1
    y2[11] = -1
    s[11] = true
    x[12] = sourcex - 3
    y[12] = sourcey
    x2[12] = -1
    y2[12] = -1
    s[12] = true

    count = 2

    for i = sourcey-2:-1:1
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(x2, [-1])
        prepend!(y2, [-1])

        if count == 2
            prepend!(s, [false])
        else
            prepend!(s, [true])
        end

        count += 1
    end

    count = 2

    for i = sourcey-2:-1:1
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
        
        if count == 2
            prepend!(s, [false])
        else
            prepend!(s, [true])
        end

        count += 1
    end

    count = 2

    for i = sourcey+2:shogiBoard.boardSize
        if (sourcex + count) >= (shogiBoard.boardSize + 1)
            break
        end

        prepend!(x, [sourcex + count])
        prepend!(y, [i])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
        
        if count == 2
            prepend!(s, [false])
        else
            prepend!(s, [true])
        end

        count += 1
    end

    count = 2

    for i = sourcey+2:shogiBoard.boardSize
        if (sourcex - count) <= 0
            break
        end

        prepend!(x, [sourcex - count])
        prepend!(y, [i])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
        
        if count == 2
            prepend!(s, [false])
        else
            prepend!(s, [true])
        end

        count += 1
    end

    for i = sourcey-2:-1:1
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
    end

    for i = sourcey+2:shogiBoard.boardSize
        prepend!(x, [sourcex])
        prepend!(y, [i])
        prepend!(s, [true])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
    end

    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getWaterBuffaloMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getFireDemonMoves(shogiBoard, sourcex, sourcey)
    end

    x, y, x2, y2, s = getFreeBoarMoves(shogiBoard, sourcex, sourcey)

    prepend!(x, [sourcex])
    prepend!(y, [sourcey + 1])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex])
    prepend!(y, [sourcey + 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [true])
    prepend!(x, [sourcex])
    prepend!(y, [sourcey - 1])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex])
    prepend!(y, [sourcey - 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [true])

    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getChariotSoliderMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getHeavenlyTetrachMoves(shogiBoard, sourcex, sourcey)
    end

    x, y, x2, y2, x3, y3, s = getBishopMoves(shogiBoard, sourcex, sourcey, false)
    newX, newY, newX2, newY2, newX3, newY3, newS = getReverseChariotMoves(shogiBoard, sourcex, sourcey, false)

    prepend!(x, newX)
    prepend!(y, newY)
    prepend!(x2, newX2)
    prepend!(y2, newY2)
    prepend!(x3, newX3)
    prepend!(y3, newY3)
    prepend!(s, newS)

    prepend!(x, [sourcex - 1])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex - 2])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [true])
    prepend!(x, [sourcex + 1])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex + 2])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [true])

    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getSideSoldierMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getWaterBuffaloMoves(shogiBoard, sourcex, sourcey, false)
    end

    x, y, x2, y2, x3, y3, s = getSideMoverMoves(shogiBoard, sourcex, sourcey, false)

    if shogiBoard.move.move_number % 2 == 1
        prepend!(x, [sourcex])
        prepend!(y, [sourcey - 2])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
        prepend!(s, [true])
    else
        prepend!(x, [sourcex])
        prepend!(y, [sourcey + 2])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
        prepend!(s, [true])
    end

    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getVerticalSoldierMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getChariotSoliderMoves(shogiBoard, sourcex, sourcey, false)
    end

    x, y, x2, y2, x3, y3, s = getLanceMoves(shogiBoard, sourcex, sourcey, false)

    prepend!(x, [sourcex + 1])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex + 2])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex - 1])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex - 2])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    if shogiBoard.move.move_number % 2 == 1
        prepend!(x, [sourcex])
        prepend!(y, [sourcey + 1])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
        prepend!(s, [false])
    else
        prepend!(x, [sourcex])
        prepend!(y, [sourcey - 1])
        prepend!(x2, [-1])
        prepend!(y2, [-1])
        prepend!(s, [false])
    end

    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getIronGeneralMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getVerticalSoldierMoves(shogiBoard, sourcex, sourcey, false)
    end

    x = Array{Int16}(3)
    y = Array{Int16}(3)
    s = falses(3)

    if shogiBoard.move.move_number % 2 == 1
        x[1] = sourcex
        y[1] = sourcey - 1
        x[2] = sourcex + 1
        y[2] = sourcey - 1
        x[3] = sourcex - 1
        y[3] = sourcey - 1
    else
        x[1] = sourcex
        y[1] = sourcey + 1
        x[2] = sourcex + 1
        y[2] = sourcey + 1
        x[3] = sourcex - 1
        y[3] = sourcey + 1
    end

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getDogMoves(shogiBoard, sourcex, sourcey, promoted)
    if promoted == true
        return getMultiGeneralMoves(shogiBoard, sourcex, sourcey)
    end

    x = Array{Int16}(3)
    y = Array{Int16}(3)
    s = falses(3)

    if shogiBoard.move.move_number % 2 == 1
        x[1] = sourcex
        y[1] = sourcey - 1
        x[2] = sourcex + 1
        y[2] = sourcey + 1
        x[3] = sourcex - 1
        y[3] = sourcey + 1
    else
        x[1] = sourcex
        y[1] = sourcey + 1
        x[2] = sourcex + 1
        y[2] = sourcey - 1
        x[3] = sourcex - 1
        y[3] = sourcey - 1
    end

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getMultiGeneralMoves(shogiBoard, sourcex, sourcey)
    x = Array{Int16}(1)
    y = Array{Int16}(1)
    s = falses(1)
    x[1] = sourcex
    y[1] = sourcey

    if shogiBoard.move.move_number % 2 == 1 && sourcey > 1
        for i = sourcey-1:-1:1
            prepend!(x, [sourcex])
            prepend!(y, [i])
            prepend!(s, [true])
        end

        count = 1

        for i = sourcey+1:shogiBoard.boardSize
            if (sourcex + count) >= (shogiBoard.boardSize + 1)
                break
            end

            prepend!(x, [sourcex + count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end

        count = 1

        for i = sourcey+1:shogiBoard.boardSize
            if (sourcex - count) <= 0
                break
            end

            prepend!(x, [sourcex - count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end
    elseif sourcey < shogiBoard.boardSize
        for i = sourcey+1:shogiBoard.boardSize
            prepend!(x, [sourcex])
            prepend!(y, [i])
            prepend!(s, [true])
        end

        count = 1

        for i = sourcey-1:-1:1
            if (sourcex - count) <= 0
                break
            end

            prepend!(x, [sourcex - count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end

        count = 1

        for i = sourcey-1:-1:1
            if (sourcex + count) >= (shogiBoard.boardSize + 1)
                break
            end

            prepend!(x, [sourcex + count])
            prepend!(y, [i])
            prepend!(s, [true])

            count += 1
        end
    end
    
    pop!(x)
    pop!(y)
    pop!(s)

    x2, y2 = noSecondMove(length(x))
    x3, y3 = noSecondMove(length(x))
    
    return x, y, x2, y2, x3, y3, s
end

function getFreeEagleMoves(shogiBoard, sourcex, sourcey)
    x, y, x2, y2, x3, y3, s = getQueenMoves(shogiBoard, sourcex, sourcey, false)

    prepend!(x, [sourcex])
    prepend!(y, [sourcey + 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex + 2])
    prepend!(y, [sourcey + 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex + 2])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex + 2])
    prepend!(y, [sourcey - 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex])
    prepend!(y, [sourcey - 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex - 2])
    prepend!(y, [sourcey - 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex - 2])
    prepend!(y, [sourcey])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])
    prepend!(x, [sourcex - 2])
    prepend!(y, [sourcey + 2])
    prepend!(x2, [-1])
    prepend!(y2, [-1])
    prepend!(s, [false])

    prepend!(x, [sourcex + 1])
    prepend!(y, [sourcey + 1])
    prepend!(x2, [sourcex])
    prepend!(y2, [sourcey])
    prepend!(s, [false])
    prepend!(x, [sourcex + 1])
    prepend!(y, [sourcey - 1])
    prepend!(x2, [sourcex])
    prepend!(y2, [sourcey])
    prepend!(s, [false])
    prepend!(x, [sourcex - 1])
    prepend!(y, [sourcey - 1])
    prepend!(x2, [sourcex])
    prepend!(y2, [sourcey])
    prepend!(s, [false])
    prepend!(x, [sourcex - 1])
    prepend!(y, [sourcey + 1])
    prepend!(x2, [sourcex])
    prepend!(y2, [sourcey])
    prepend!(s, [false])

    prepend!(x, [sourcex + 1])
    prepend!(y, [sourcey + 1])
    prepend!(x2, [sourcex + 2])
    prepend!(y2, [sourcey + 2])
    prepend!(s, [false])
    prepend!(x, [sourcex + 1])
    prepend!(y, [sourcey - 1])
    prepend!(x2, [sourcex + 2])
    prepend!(y2, [sourcey - 2])
    prepend!(s, [false])
    prepend!(x, [sourcex - 1])
    prepend!(y, [sourcey - 1])
    prepend!(x2, [sourcex - 2])
    prepend!(y2, [sourcey - 2])
    prepend!(s, [false])
    prepend!(x, [sourcex - 1])
    prepend!(y, [sourcey + 1])
    prepend!(x2, [sourcex - 2])
    prepend!(y2, [sourcey + 2])
    prepend!(s, [false])

    x3, y3 = noSecondMove(length(x))

    return x, y, x2, y2, x3, y3, s
end

function getLionHawkMoves(shogiBoard, sourcex, sourcey)
    x, y, x2, y2, x3, y3, s = getLionMoves(shogiBoard, sourcex, sourcey, false)

    newX, newY, newX2, newY2, newX3, newY3, newS = getBishopMoves(shogiBoard, sourcex, sourcey, false)

    prepend!(x, newX)
    prepend!(y, newY)
    prepend!(x2, newX2)
    prepend!(y2, newY2)
    prepend!(x3, newX3)
    prepend!(y3, newY3)
    prepend!(s, newS)

    return x, y, x2, y2, x3, y3, s
end
end
