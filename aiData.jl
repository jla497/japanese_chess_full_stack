module aiData
push!(LOAD_PATH,pwd())
if Pkg.installed("SQLite") == nothing
	Pkg.add("SQLite")
end
using SQLite
using Definition
export createDBAI, createDBtableAI, arrayToString, stringToArray, updateAIDataBase,addPlay, addWin, updatePlay, updateWin, readWin, readPlay

function updateAIDataBase(db::SQLite.DB,playsCount::Dict{Tuple{Char,String},Int}, winsCount::Dict{Tuple{Char,String},Int})
	println("line 11")
	for key in collect(keys(playsCount))
		println("key: ",key)
		println("playsCount: ",playsCount[key])
		if readPlay(db,key[1],key[2])==-1
			addPlay(db,key[1],key[2])
			println("added new play")
		elseif readPlay(db,key[1],key[2]) == playsCount[key]
			continue
		else
			updatePlay(db,key[1],key[2],playsCount[key])
			println("updated play")
		end
	end

	for key in collect(keys(winsCount))
		if readWin(db,key[1],key[2])==-1
			addWin(db,key[1],key[2])
		elseif readWin(db,key[1],key[2]) == winsCount[key]
			continue
		else
			updateWin(db,key[1],key[2],winsCount[key])
		end
	end
end

function arrayToString(arr::Array{String,2})
  str = join(arr)
  return str
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

# creates the database file
function createDBAI(filename::AbstractString)
	return SQLite.DB(filename)
end


# takes in a database file and creates the meta and moves table
function createDBtableAI(Database::SQLite.DB)
	SQLite.query(Database, "CREATE table plays ( player Char, state String, count Int16, PRIMARY KEY(player, state))")
  SQLite.query(Database, "CREATE table wins(player Char, state String, count Int16, PRIMARY KEY(player, state))")
end


# updates the meta table (for start.jl)
function updatePlay(Database::SQLite.DB, player::Char, state::String,count::Int)
	startTime = now()
	timeout = Dates.Second(1)
	newCount = 0
	flag =
	while now()-startTime<timeout
		try
			res = SQLite.query(Database, "SELECT * FROM plays WHERE player = '$player' and state='$state'")
			if size(res)[1] > 0
		 		newCount = get(res[3][1])
			println("updatePlay count: ",newCount)
				newCount = newCount + count
				SQLite.query(Database, "UPDATE plays SET count = '$newCount' WHERE player='$player'and state='$state'")

			else
				println("failed to updatePlay")
	    end
			break
		catch
			sleep(0.001)
		end
	end
end

function addPlay(Database::SQLite.DB, p::Char, s::String)
    newCount = 0
		startTime = now()
		timeout = Dates.Second(1)
		while now()-startTime<timeout
			try
  			SQLite.query(Database, "INSERT INTO plays VALUES('$p','$s','$newCount')")
				break
			catch
				sleep(0.001)
			end
		end
end

function readPlay(Database::SQLite.DB, p::Char, s::String)
	newCount = 0
	startTime = now()
	timeout = Dates.Second(1)
	while now()-startTime<timeout
		try
	 		res = SQLite.query(Database, "SELECT * FROM plays WHERE player = '$p' AND state ='$s' ")
			if size(res)[1] > 0
		 	newCount = get(res[3][1])
	 		else
		 		newCount = -1
	 		end
				break
		catch
			sleep(0.001)
		end
	end
	return newCount
end

function addWin(Database::SQLite.DB, p::Char, s::String)
	newCount = 0
	startTime = now()
	timeout = Dates.Second(1)
	while now()-startTime<timeout
		try
			SQLite.query(Database, "INSERT INTO wins VALUES('$p','$s','$newCount')")
			break
		catch
			sleep(0.001)
		end
	end
end

function updateWin(Database::SQLite.DB, player::Char, state::String,count::Int)

	startTime = now()
	timeout = Dates.Second(1)
	newCount = 0
	while now()-startTime<timeout
		try
			res = SQLite.query(Database, "SELECT * FROM wins WHERE player = '$player' and state='$state'")
			if size(res)[1] > 0
		 		newCount = get(res[3][1])
				newCount = newCount+count
				SQLite.query(Database, "UPDATE wins SET count = '$newCount' WHERE player='$player'and state='$state'")
			println("updateWin count: ",newCount)
			else
				println("failed to updateWin")
	    end
			break
		catch
			sleep(0.001)
		end
	end
end


function readWin(Database::SQLite.DB, p::Char, s::String)
	newCount = 0
	startTime = now()
	timeout = Dates.Second(1)
	while now()-startTime<timeout
		try
	 		res = SQLite.query(Database, "SELECT * FROM wins WHERE player = '$p' AND state ='$s' ")
			if size(res)[1] > 0
		 	newCount = get(res[3][1])
	 		else
		 		newCount = -1
	 		end
				break
		catch
			sleep(0.01)
		end
	end
	return newCount
end

end
