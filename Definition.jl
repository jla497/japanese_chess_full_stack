module Definition
export metaTable, moveTable, shogiData, piece

type piece
    name::String
    team::Char
    sourcex::Int16
    sourcey::Int16
    promoted::Bool
    captured::Bool
	maxCapture::Int

    function piece(n, t, x, y, p, c, mc)
		new(n, t, x, y, p, c, mc)
    end
end

type metaTable
shogiType::String
cheating::String
seed::String
limit::Int
limit_add::Int
senteTime::Int
goteTime::Int
metaTable() = new()
	function metaTable(s::String, c::String, d::String, l::Int, lA::Int, sT::Int, gT::Int)
		new(s, c, d, l, lA, sT, gT)
	end
end


type moveTable
	boardSize::Int
	move_number::UInt16
	move_type::String
	sourcex::Int16
	sourcey::Int16
	targetx::Int16
	targety::Int16
	option::String
	i_am_cheating::Bool
	targetx2::Int16
	targety2::Int16
	targetx3::Int16
	targety3::Int16
	targetx4::Int16
	targety4::Int16
	targetx5::Int16
	targety5::Int16
	
	
	moveTable() = new(9,1," ",1,1,1,1,"?",false,-1,-1,-1,-1,-1,-1,-1,-1)
	function moveTable(bs,mn,mt,sx,sy,tx,ty,o,iac,tx2,ty2,tx3,ty3,tx4,ty4,tx5,ty5)
		new(bs,mn,mt,sx,sy,tx,ty,o,iac,tx2,ty2,tx3,ty3,tx4,ty4,tx5,ty5)
	end
	
end


type shogiData
	#board
	board::Array{String}
#	array of all pieces under type "piece"
	pieces::Array{piece}
	#check if space is occupied
	occupied::Array{Bool}
  	move::moveTable
  	meta::metaTable
	color::Char
	player::String
	boardSize::Int16
	lionCapture::Bool
	difficulty::Int
	shogiData() = new(Array{String}(12,12), #board
					Array{piece}(92),	#pieces
					Array{Bool}(12,12), moveTable(), metaTable(),'b',"AI", 10, false,1) #occupied)
end


end