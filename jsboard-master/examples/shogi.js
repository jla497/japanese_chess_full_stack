var b = jsboard.board({attach:"game", size:"9x9", style:"checkerboard"});
b.cell("each").style({width:"60px", height:"60px"});
var loc;

var silverGen = jsboard.piece({text:"WS", textIndent:"-9999px", background:"url('images/whiteT/whitesilver_general.png') no-repeat",width:"50px", height:"50px", margin:"0 auto" });
var bishop = jsboard.piece({text:"WB", textIndent:"-9999px", background:"url('images/whiteT/whitebishop.png') no-repeat", width:"50px", height:"50px", margin:"0 auto" });
var rook   = jsboard.piece({text:"WR", textIndent:"-9999px", background:"url('images/whiteT/whiterook.png') no-repeat", width:"50px", height:"50px", margin:"0 auto" });
var goldGen  = jsboard.piece({text:"WG", textIndent:"-9999px", background:"url('images/whiteT/whitegold_general.png') no-repeat",  width:"50px", height:"50px", margin:"0 auto" });
var lance = jsboard.piece({text:"WL", textIndent:"-9999px", background:"url('images/whiteT/whitelance.png') no-repeat",  width:"50px", height:"50px", margin:"0 auto" });
var king   = jsboard.piece({text:"WK", textIndent:"-9999px", background:"url('images/whiteT/whiteking.png') no-repeat",width:"50px", height:"50px", margin:"0 auto" });
var pawn   = jsboard.piece({text:"WP", textIndent:"-9999px", background:"url('images/whiteT/whitepawn.png') no-repeat", width:"50px", height:"50px", margin:"0 auto" });
var knight = jsboard.piece({text:"WN", textIndent:"-9999px", background:"url('images/whiteT/whiteknight.png') no-repeat", width:"50px", height:"50px", margin:"0 auto" });

var whitePieces = [lance.clone(),knight.clone(),silverGen.clone(),goldGen.clone(),king.clone(),goldGen.clone(),silverGen.clone(),knight.clone(),lance.clone(),bishop.clone(),rook.clone()];


for(var i = 0; i<9;i++)
	whitePieces.push(pawn.clone());

for(var i = 0;i<9;i++)
	b.cell([6,i]).place(whitePieces[i+11]);

b.cell([7,1]).place(whitePieces[9]);
b.cell([7,7]).place(whitePieces[10]);

for(var i = 0;i<9;i++)
	b.cell([8,i]).place(whitePieces[i]);

var silverGenB = jsboard.piece({text:"BS", textIndent:"-9999px", background:"url('images/blackT/blacksilver_general.png') no-repeat",width:"50px", height:"50px", margin:"0 auto" });
var bishopB = jsboard.piece({text:"BB", textIndent:"-9999px", background:"url('images/blackT/blackbishop.png') no-repeat", width:"50px", height:"50px", margin:"0 auto" });
var rookB   = jsboard.piece({text:"BR", textIndent:"-9999px", background:"url('images/blackT/blackrook.png') no-repeat", width:"50px", height:"50px", margin:"0 auto" });
var goldGenB  = jsboard.piece({text:"BG", textIndent:"-9999px", background:"url('images/blackT/blackgold_general.png') no-repeat",  width:"50px", height:"50px", margin:"0 auto" });
var lanceB = jsboard.piece({text:"BL", textIndent:"-9999px", background:"url('images/blackT/blacklance.png') no-repeat",  width:"50px", height:"50px", margin:"0 auto" });
var kingB   = jsboard.piece({text:"BK", textIndent:"-9999px", background:"url('images/blackT/blackking.png') no-repeat",width:"50px", height:"50px", margin:"0 auto" });
var pawnB   = jsboard.piece({text:"BP", textIndent:"-9999px", background:"url('images/blackT/blackpawn.png') no-repeat", width:"50px", height:"50px", margin:"0 auto" });
var knightB = jsboard.piece({text:"BN", textIndent:"-9999px", background:"url('images/blackT/blackknight.png') no-repeat", width:"50px", height:"50px", margin:"0 auto" });

var blackPieces = [lanceB.clone(),knightB.clone(),silverGenB.clone(),goldGenB.clone(),kingB.clone(),goldGenB.clone(),silverGenB.clone(),knightB.clone(),lanceB.clone(),rookB.clone(),bishopB.clone()];

for(var i = 0; i<9;i++)
	blackPieces.push(pawnB.clone());

for(var i = 0;i<9;i++)
	b.cell([2,i]).place(blackPieces[i+11]);

b.cell([1,1]).place(blackPieces[9]);
b.cell([1,7]).place(blackPieces[10]);

for(var i = 0;i<9;i++)
	b.cell([0,i]).place(blackPieces[i]);

var bindMoveLocs, bindMovePiece;

// give functionality to pieces
var pieceLocs;
/*for (var i=0; i<whitePieces.length; i++) 
    whitePieces[i].addEventListener("click", function() { showMoves(this); 
    });
*/
for (var i=0; i<whitePieces.length; i++) 
    blackPieces[i].addEventListener("click", function() { showMoves(this);
    
     });

// show new locations 
function showMoves(piece) {

    resetBoard();
        
    // parentNode is needed because the piece you are clicking 
    // on doesn't have access to cell functions, therefore you 
    // need to access the parent of the piece because pieces are 
    // always contained within in cells

    // piece clicked on will be either: WK, WB, WR, WQ, WG, WP
    var thisPiece = b.cell(piece.parentNode).get();
    var newLocs = [];
    loc = b.cell(piece.parentNode).where();

    // movement for knights
    if (thisPiece=="BN") {
        newLocs.push(
            //[loc[0]+1,loc[1]-2], [loc[0]+1,loc[1]+2],
            [loc[0]+2,loc[1]-1], [loc[0]+2,loc[1]+1]
        );
    }
    
    if (thisPiece=="WN") {
        newLocs.push(
            //[loc[0]+1,loc[1]-2], [loc[0]+1,loc[1]+2],
            [loc[0]-2,loc[1]-1], [loc[0]-2,loc[1]+1]
        );
    }

    // movement for pawns
    if (thisPiece=="BP") {
        newLocs.push([loc[0]+1,loc[1]]); 
    }
    
     if (thisPiece=="WP") {
        newLocs.push([loc[0]-1,loc[1]]); 
    }

    // movement for bishops
    // queen also moves like a bishop
    if (thisPiece=="WB" || thisPiece =="BB") {
        var check = 7;
        // up left diagonal
        var ULD = [loc[0]-1,loc[1]-1];
        while (check>0) {
            if (b.cell(ULD).get()==null||b.cell(ULD).get().indexOf('W')>-1) { newLocs.push(ULD); ULD = [ULD[0]-1,ULD[1]-1]; } 
            check--;  
        }
        check = 7;
        // up right diagonal
        var URD = [loc[0]-1,loc[1]+1];
        while (check>0) {
            if (b.cell(URD).get()==null||b.cell(ULD).get().indexOf('W')>-1) { newLocs.push(URD); URD = [URD[0]-1,URD[1]+1]; } 
            check--;  
        }
        check = 7;
        // down left diagonal
        var DLD = [loc[0]+1,loc[1]-1];
        while (check>0) {
            if (b.cell(DLD).get()==null||b.cell(ULD).get().indexOf('W')>-1) { newLocs.push(DLD); DLD = [DLD[0]+1,DLD[1]-1]; } 
            check--;  
        }
        check = 7;
        // down right diagonal
        var DRD = [loc[0]+1,loc[1]+1];
        while (check>0) {
            if (b.cell(DRD).get()==null||b.cell(ULD).get().indexOf('W')>-1) { newLocs.push(DRD); DRD = [DRD[0]+1,DRD[1]+1]; } 
            check--;  
        }
    }

    // movement for rooks
    // queen also moves like a rook
    
    if(thisPiece =="WL")
    {
    	var check = 7;
        var U = [loc[0]-1,loc[1]];
        while (check>0) {
            if (b.cell(U).get()==null) { newLocs.push(U); U = [U[0]-1,U[1]]; } 
            check--;  
        }
    }
    
     if(thisPiece =="BL")
    {
    	var check = 7;
        var U = [loc[0]+1,loc[1]];
        while (check>0) {
            if (b.cell(U).get()==null) { newLocs.push(U); U = [U[0]+1,U[1]]; } 
            check--;  
        }
    }
    
    
    if (thisPiece=="WR" || thisPiece =="BR") {
        var check = 7;
        var U = [loc[0]-1,loc[1]];
        while (check>0) {
            if (b.cell(U).get()==null||b.cell(U).get().includes("W")>-1) { newLocs.push(U); U = [U[0]-1,U[1]]; } 
            check--;  
        }
        check = 7;
        // up right diagonal
        var L = [loc[0],loc[1]-1];
        while (check>0) {
            if (b.cell(L).get()==null||b.cell(U).get().includes("W")>-1) { newLocs.push(L); L = [L[0],L[1]-1]; } 
            check--;  
        }
        check = 7;
        // down left diagonal
        var R = [loc[0],loc[1]+1];
        while (check>0) {
            if (b.cell(R).get()==null||b.cell(U).get().includes("W")>-1) { newLocs.push(R); R = [R[0],R[1]+1]; } 
            check--;  
        }
        check = 7;
        // down right diagonal
        var D = [loc[0]+1,loc[1]];
        while (check>0) {
            if (b.cell(D).get()==null||b.cell(U).get().includes("W")>-1) { newLocs.push(D); D = [D[0]+1,D[1]]; } 
            check--;  
        }
    }

    // movement for king
    if (thisPiece=="WK" || thisPiece =="BK") {
        newLocs.push(
            [loc[0]-1,loc[1]],   [loc[0]+1,loc[1]],
            [loc[0],loc[1]-1],   [loc[0],loc[1]+1],
            [loc[0]-1,loc[1]-1], [loc[0]-1,loc[1]+1],
            [loc[0]+1,loc[1]-1], [loc[0]+1,loc[1]+1]
        );
    }
		
		   if (thisPiece=="BS") {
        newLocs.push(
            [loc[0]+1,loc[1]],
            [loc[0]-1,loc[1]-1], [loc[0]-1,loc[1]+1],
            [loc[0]+1,loc[1]-1], [loc[0]+1,loc[1]+1]
        );
    }
    
    if (thisPiece=="WS") {
        newLocs.push(
            [loc[0]-1,loc[1]],
            [loc[0]+1,loc[1]-1], [loc[0]+1,loc[1]+1],
            [loc[0]-1,loc[1]-1], [loc[0]-1,loc[1]+1]
        );
    }
    
       if (thisPiece=="BG") {
        newLocs.push(
            [loc[0]-1,loc[1]],   [loc[0]+1,loc[1]],
            [loc[0],loc[1]-1],   [loc[0],loc[1]+1],
            [loc[0]+1,loc[1]-1], [loc[0]+1,loc[1]+1]
        );
    }
    
    if (thisPiece=="WG") {
        newLocs.push(
            [loc[0]+1,loc[1]],   [loc[0]-1,loc[1]],
            [loc[0],loc[1]-1],   [loc[0],loc[1]+1],
            [loc[0]-1,loc[1]+1], [loc[0]-1,loc[1]-1]
        );
    }
    // remove illegal moves by checking 
    // content of b.cell().get()
    (function removeIllegalMoves(arr) {
        var fixedLocs = [];
        for (var i=0; i<arr.length; i++) 
            if (b.cell(arr[i]).get()==null||b.cell(arr[i]).get().indexOf('W')>-1)
                fixedLocs.push(arr[i]); 
        newLocs = fixedLocs;
    })(newLocs); 

    // bind green spaces to movement of piece
    bindMoveLocs = newLocs.slice();
    bindMovePiece = piece; 
    bindMoveEvents(bindMoveLocs);

}

// bind move event to new piece locations
function bindMoveEvents(locs) {
    for (var i=0; i<locs.length; i++) {
        b.cell(locs[i]).DOM().classList.add("green");
        b.cell(locs[i]).on("click", movePiece);  
    }
}

// actually move the piece
function movePiece() {
    var userClick = b.cell(this).where();
    if (bindMoveLocs.indexOf(userClick)) {
	console.log(b.cell(userClick).get());
	b.cell(userClick).rid();
	console.log(bindMovePiece);
        b.cell(userClick).place(bindMovePiece);
        resetBoard();
        console.log("user click: "+userClick);
        console.log("bindmoveloc: "+loc);
	var sX = loc[1]+1;
	var sY = 9-loc[0];
	var dX = userClick[1]+1;
	var dY = 9-userClick[0];
        var req = sX+"."+sY+"."+dX+"."+dY;
        var theURL =  "/hello/"+req;
	$("#status").empty();
	$("#status").text("Waiting for AI's move...");
  	httpGetAsync(theURL,responsePrint);
    }
}

// remove previous green spaces and event listeners
function resetBoard() {
    for (var r=0; r<b.rows(); r++) {
        for (var c=0; c<b.cols(); c++) {
            b.cell([r,c]).DOM().classList.remove("green");
            b.cell([r,c]).removeOn("click", movePiece);
        }
    }
}


function httpGetAsync(theUrl, callback)
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function() { 
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
            callback(xmlHttp.responseText);
    }
    xmlHttp.open("GET", theUrl, true); // true for asynchronous 
    xmlHttp.send(null);
}

function responsePrint(data){
	
	var arr = data.split(".");
	console.log(arr);
	var sX = arr[0]-1;
	var sY = 9-arr[1];
	var dX = arr[2]-1;
	var dY = 9-arr[3];
	
	var piece = b.cell([sY,sX]).get();
	b.cell([sY,sX]).rid();
	b.cell([dY,dX]).rid();
	getPiece(piece,dY,dX);
	$("#status").empty();
	$("#status").text("AI's move: "+sX+", "+sY+", "+dX+", "+dY);
	console.log(piece);
	
}

function getPiece(piece,dY,dX){

	switch(piece){
	
		case "WL":
			b.cell([dY,dX]).place(lance.clone());	
		break;
		
		case "WN":
			b.cell([dY,dX]).place(knight.clone()); 
		break;

		case "WS":
			b.cell([dY,dX]).place(silverGen.clone()); 
		break;

		case "WG":
			b.cell([dY,dX]).place(goldGen.clone()); 
		break;

		case "WK":
			b.cell([dY,dX]).place(king.clone()); 
		break;

		case "WB":
			b.cell([dY,dX]).place(bishop.clone()); 
		break;

		case "WR":
			b.cell([dY,dX]).place(rook.clone()); 
		break;

		case "WP":
			b.cell([dY,dX]).place(pawn.clone()); 
		break;


	}

}
$(document).ready(function(){
  

   $("#start").click(function(){

        var req = "/hello/.restart";
        $.ajax({

                url: req,
                type: "GET",
                success: function(data,status){
                        if(data =="success")
                        {
                                location.reload();
                        }
                }
        });
  });

  $("#restart").click(function(){

	var req = "/hello/.restart";
	$.ajax({

		url: req,
		type: "GET",
		success: function(data,status){
			if(data =="success")
			{
				location.reload();
			}
		}
	});
  });
});
