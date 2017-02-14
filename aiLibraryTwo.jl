#FINALVERSION



module aiLibraryTwo

push!(LOAD_PATH,pwd())

using Definition 
using board
using setupLibrary

 importall userMoveLibrary

 importall moveLibrary

 importall setupLibrary

export get_play, randomIndex, setDifficulty, checkDict

time = Array{Int}(1)

time[1]=0

maxDepth = 0

timedout = Array{Bool}(1)

timedout[1]=true

C = 1.4

e = 10

a = 1/263

states = Vector{shogiData}(0)

winsCount = Dict{Tuple{Char,String},Int}()

playsCount = Dict{Tuple{Char,String},Int}()

max_moves = 5

testPlayer = 'b'

testKey = Array{Char}(9,9)

state_wins = Dict()

state_plays = Dict()

#get aiPlaysWins database object

filename = "aiPlaysWins4"




####FUNCTIONS###############################

function checkDict()

  for key in collect(keys(playsCount))

    println("key: ",key)

    println("val: ",playsCount[key])

  end

end



function update(state::shogiData)

  push!(states,state)

end

#= 1. suicidal

   2. normal

   3. Hard

   4. Protracted Death

   5. RandomAI

=#

function setDifficulty(difficulty::Int,state::shogiData)



  global max_moves





  boardSize = size(state.board)[1]

  if difficulty == 1



    max_moves = 10

  elseif difficulty == 2



    max_moves = 50

  elseif difficulty == 3



    max_moves = 50

  elseif difficulty >= 4

    max_moves = -28

  end



  if boardSize == 16

    max_moves = Int(floor(max_moves/4))

  elseif boardSize == 12

    max_moves = Int(floor(max_moves/2))

  end



  println("time: ",time)

  println("max_moves: ",max_moves)

  return

end

function get_play(moves::Vector{moveTable},states::Dict{String,Int},state::shogiData)

  global time

  global max_moves

  global winsCount

  global playsCount

  global timedout

  finish_time = now() + Dates.Second(14)

  move = moveTable()

  player = current_player(state)

  max_material_score = -999

  min_material_score = 999

  move_states = Vector{Tuple{moveTable,Float64,String}}(0)

  move_states_scores = Dict{Tuple{String,moveTable},Float64}()

  percent_wins = -999

  println("now: ",now())

  println("finish_time: ",finish_time)

  #RandomAI or suicidal

  if max_moves <= 0

    legal = generateMoves(copy(state))

    p = randomIndex(legal)

    return p

  end



  if timedout[1]==true && time[1]>0

    time[1]=time[1]-1

  elseif timedout[1]==false && time[1] < 13

    time[1]=time[1]+1

  end

  calculation_time = Dates.Second(time[1])

  println("time for simulation: ",time[1])

  move_states = run_simulation(moves,deepcopy(state),calculation_time)

  removeRepeatedStates(states,move_states,player)



  if length(move_states) < 1

    legal = generateMoves(deepcopy(state))

    if now()<=finish_time

      timedout[1] = false

    elseif now()>finish_time

      timedout[1] = true

    end

    if length(legal) <1

      move = moveTable()

      move.move_type = "resign"

      return move

    else

      max_material_score = -999

      min_material_score = 999

      move = moveTable()

      for l in legal

       flag, s = deepcopy(next_state(deepcopy(state),l))

       score = 0

       if flag == true

         score = Float64(evaluateMove(s,player))

       end

       if score > max_material_score

          max_material_score = score

          move = l

        elseif score < min_material_score

          min_material_score = score

        end

      end

      return move

    end

  elseif length(move_states)==1

    println("length of legal is 1")

    return move_states[1][1]

  end



  for (p,score,key) in move_states

    if score > max_material_score

      max_material_score = score

      move = p

    elseif score < min_material_score

      min_material_score = score

    end

  end



  if max_material_score == min_material_score

   p = randomIndex(move_states)

   timedout[1]=false

   println("not timedout")

   return p[1]

  end



  timedout[1]=false

  println("not timedout")

  return move



end



function run_simulation(moves::Vector{moveTable},state::shogiData, calculation_time::Dates.Second)

#  global states

  global maxDepth

  global e

  visited_states = Vector{Any}(0)

  toBeReturned = Vector{Tuple{moveTable,Float64,String}}(0)

  originState = deepcopy(state)

  player = current_player(state)

  originPlayer = player

  expand = true

  winningPlayer = 'n'



  finish_time = now()+calculation_time

  #println("run_simulation for Player: ",originPlayer)

  for i = 1:max_moves

    flag = true

    if now() >= finish_time

      println("simulation timed out")

      println("finish_time: ",finish_time)

      println("now(): ",now())

      break

    end



    legal = generateMoves(deepcopy(state))

    max_material_score = -999

    min_material_score = 999



    max_material_score = -999

    min_material_score = 999

    totalVisits = 0

    log_total = 0



    #=@time move_states = @parallel vcat for i = 1:length(legal)

    S  = deepcopy(next_state(deepcopy(state),legal[i]))

    (evaluateMove(S,player),arrayToString(S.board),legal[i])

  end=#

    if length(legal)<1

      println("no legal plays generated")

      return

    end



    move_states = Vector{Tuple{moveTable,Float64,String}}()



   for p in legal

      flag, s = deepcopy(next_state(deepcopy(state),p))

      if flag == false

        continue

      end



      score = Float64(evaluateMove(s,player))

      push!(move_states,(p,score,arrayToString(s.board)))

      if score > max_material_score

        max_material_score = score

      elseif score < min_material_score

        min_material_score = score

      end

    end



    if i == 1

      toBeReturned = deepcopy(move_states)

    end

    #count how many times a state in

    for (p,score,key) in move_states



      visit = get(playsCount,(player,key),-1)

      if visit != -1

        totalVisits+=visit

      end

    end

    if totalVisits!=0

      log_total = log(totalVisits)

    end



    println("max_material_score: ",max_material_score)

  #  println("min_material_score: ",min_material_score)

    #println("log_total: ",log_total)

    #println("current_player: ",player)



    state_wins = Dict{Tuple{String,Char},Int}()

    state_plays = Dict{Tuple{String,Char},Int}()

    for (p,score,key) in move_states



      state_wins[key,player] = get(winsCount,(player,key),0)

      state_plays[key,player] =get(playsCount,(player,key),-1)

    end

    maxValue = move_states[1][2]

    maxMove = move_states[1][1]

    maxKey = move_states[1][3]



  for (p,material_score,key) in move_states



  #  println("current_player: ",player)

    x = 0

    if state_plays[key,player] <= 0 #node not visited



      if max_material_score == min_material_score

        x = 0

      elseif log_total != 0

        x = ((material_score - min_material_score)/(max_material_score - min_material_score))+(C*sqrt(log_total/e))



      else

        x = ((material_score - min_material_score)/(max_material_score - min_material_score))

      end

      #println("pushed new state: state_score: ",overall_state_scores[p,S]," ",p)

    elseif state_plays[key,player] > 0

    #  println("readPlay(db,player, key): ",readPlay(db,player, key))

    #  println("readWin(db,player, key): ",readWin(db,player, key))

      #println("readWin(db,player, key)/readPlay(db,player, key)= ",readWin(db,player, key)/readPlay(db,player, key))

      #println("C * sqrt(log_total / readPlay(db,player, key))= ", C * sqrt(log_total / readPlay(db,player, key)))

        x = (state_wins[key,player]/1 + C * sqrt(log_total / state_plays[key,player]))

    #println("added score for existing state: state_score: ",overall_state_scores[p,S],p)

    end

      if x > maxValue

        maxMove = p

        maxValue = x

      end

    end



      flag,state = deepcopy(next_state(deepcopy(state),maxMove))

      if flag == false

        break

      end





     #Display(state)

     println("chosen maxState: ",maxMove)

     println("score: ",maxValue)

      stateKey = maxKey



      if expand == true && get(playsCount,(player,stateKey),-1) ==-1

        expand = false

      #  println("added new (player,state): ")

        #Display(state)

        playsCount[(player,stateKey)] = 0

        winsCount[(player,stateKey)] = 0

        if i > maxDepth

          maxDepth = i

        end

      end



      push!(visited_states,(player,stateKey))



      if flag == true

        winningPlayer = win(moves,player,deepcopy(state))

        player = current_player(deepcopy(state))

        #winningPlayer = win(states_copy)

        if winningPlayer != 'n' #if game is ongoing, 'n'is sent

          println("winningPlayer: ",winningPlayer)

          break

        end

      end

  end



  if winningPlayer == 'n'

    println("no winning player. Determining material_score...")

    current_score = evaluateMove(deepcopy(state),originPlayer)

    first_score = evaluateMove(originState,originPlayer)

    println("current_score: ", current_score)

    println("firstState_score: ",first_score)

    println("originPlayer: ",originPlayer)



    if (current_score - first_score)> 4

      winningPlayer = originPlayer

    elseif (current_score - first_score) < -4

      if originPlayer == 'b'

        winningPlayer = 'w'

      elseif originPlayer == 'w'

        winningPlayer = 'b'

      end

    end

  end

  for (plyer, key) in visited_states

    if get(playsCount,(plyer,key),-1)!=-1

      playsCount[(plyer,key)] = get(playsCount,(plyer,key),0)+1

      #println("added a new play: ")

      if plyer == winningPlayer

        winsCount[(plyer,key)] = get(winsCount,(plyer,key),0)+1

    #   println("added a new win ")

      #  println("wins[player,stateKey]: ",readWin(db,plyer,key),", ", plyer)

      end

    end

  end

  return toBeReturned

end



 function randomIndex(arr::Vector)

   n = length(arr)

   index = rand(1:n)

   return arr[index]

 end



function doStuffTwo(legal::Vector{moveTable},state::shogiData,player::Char)

#  println("line 371")

  global winsCount

  global playsCount

  finish_time = now() + Dates.Second(3)

  move_states = Vector{Tuple{Int,String,moveTable}}(0)

  max_material_score = -999

  min_material_score = 999

  totalVisits = 0

  log_total = 0

  for p in legal



    s = deepcopy(next_state(deepcopy(state),p))

    if s == false

      continue

    end

    score = evaluateMove(s,player)

    push!(move_states,(score,arrayToString(s.board),p))

    if score > max_material_score

      max_material_score = score

    elseif score < min_material_score

      min_material_score = score

    end

  end

  for (score,key,p) in move_states

    visit = get(playsCount,(player,key),-1)

    if visit > 0

      totalVisits+=visit

    end

  end



  if totalVisits!=0

    log_total = log(totalVisits)

  end



#  println("max_material_score: ",max_material_score)

#  println("min_material_score: ",min_material_score)

  #println("log_total: ",log_total)

  #println("current_player: ",player)

maxValue = Float64(-999.0)

maxMove = move_states[1][3]

maxKey = move_states[1][2]

for (material_score,key,p) in move_states

  x = 0

  numPlays = get(playsCount,(player,key),-1)

  numWins = get(winsCount,(player,key),-1)

  if numPlays != -1

  #  println("numPlays: ",numPlays)

  end

  #println("numPlays: ",numPlays)

  #println("numWins: ",numwins)

  if numPlays <= 0 #node not visited



    if max_material_score == min_material_score

      x = 0

    elseif log_total != 0

      x = ((material_score - min_material_score)/(max_material_score - min_material_score))+(C*sqrt(log_total/e))



    else

      x = ((material_score - min_material_score)/(max_material_score - min_material_score))

    end

    #println("pushed new state: state_score: ",x," ",p)

  elseif numPlays > 0

      x = (numWins/numPlays + C * sqrt(log_total / numPlays))

  #println("added score for existing state: state_score: ",overall_state_scores[p,S],p)

  end

    if x > maxValue

      maxMove = p

      maxValue = x

      maxKey = key

    end

  end

#  println("done")

  println("maxMove: ",maxMove)

  return maxMove,maxValue,maxKey

end



end
