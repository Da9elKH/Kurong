package core {
	//{ IMPORTS
	import core.Piece;
	import core.pieces.WhiteMan;
	import core.pieces.BlackMan;
	import core.pieces.Queen;
	import core.pieces.Striker;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	//}
	
	public class Engine {
		
		//{	VARIABLER
		
		private var gameTimer:Timer = new Timer(0, 0); // Spilltimeren (kjører oppdateringsfunksjonen)
		private var rotateTimer:Timer = new Timer(0, 180); // Rotasjonstimer (kjører når brettet roteres 180 grader)
		
		public var currentPlayer:int; // 0=spiller1 && 1=spiller2 //
		//private var currentStrike:int; // Slag nr. (begynner å telle på 0)
		private var currentRound:int; // Lagrer foreløpig runde i en eventuell turnering.
		private var friction:Number = 0.01; // Friksjonskonstant mellom brett og brikke
		
		private var piecesArray:Array; // Lagrer alle brikker i spill
		private var deadPiecesArray:Array; // Lagrer alle brikker som har blitt slått ut av spillet
		private var currentDeadPiecesArray:Array = new Array; // Lagrer brikker som har blitt slått ned i dette slaget.
		private var holesArray:Array = new Array(); // Lagrer hullene på brettet
		public var scores:Array = [0, 0]; // Lagrer poengene til hver spiller
		private var ScoreText1:TextField; // Tekstboksen til spiller1 sin poengsum
		private var ScoreText2:TextField; // Tekstboksen til spiller2 sin poengsum
		private var players:Array = new Array(); // Kopler spiller og brikker sammen.
		private var numGames:int = 1; // Antall spill som skal spilles.
		
		public var strikerIsHit:Boolean; // Lagrer hvorvidt runden har blitt startet ved å skyte striker.
		private var gameBoard:MovieClip; // Lagrer brettet
		public var striker:Striker; //} Lagrer Striker
		
		public function set scoreText1(newValue:TextField):void {
			ScoreText1 = newValue;
			ScoreText1.text = String(scores[0]) + " p";
		}
		
		public function set scoreText2(newValue:TextField):void {
			ScoreText2 = newValue;
			ScoreText2.text = String(scores[1]) + " p";
		}
		
		public function set Scores(newValue:TextField):void {
			scores = newValue;
			ScoreText1.text = ScoreText1.text = String(scores[0]) + " p";
			ScoreText2.text = ScoreText2.text = String(scores[1]) + " p";
		}

		
		public function Engine(board:MovieClip, gameCount:int):void { // Contructor-funksjon for Engine-klassen.
			gameTimer.addEventListener(TimerEvent.TIMER, update);
			rotateTimer.addEventListener(TimerEvent.TIMER, rotateTick);
			holesArray.push(board.h1);
			holesArray.push(board.h2);
			holesArray.push(board.h3);
			holesArray.push(board.h4);
			gameBoard = board;
			numGames = gameCount;
			newGame();
		}
		
		public function newGame():void { // Resetter brettet til en ny start.
			players = new Array();
			gameTimer.start();
			clearChildren(); // Fjerner alle brikkene som har blitt slått ned fra forrige runde
			piecesArray = new Array();
			deadPiecesArray = new Array();
			
		//////////////////// PLASSERING AV BRIKKER ///////////////////
		const radius:Number = 15.5;
		// Striker-plassering
			piecesArray.push(new Striker(0, 245.2));
			striker = piecesArray[0];
		// Queen-plassering
			piecesArray.push(new Queen(0,0));
		// WhiteMan-plasseringer:
			piecesArray.push(new WhiteMan(+0*radius, +2*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(+0*radius, -2*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(-3*radius, +1*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(-3*radius, -1*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(-2*radius, +0*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(+1*radius, +1*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(+1*radius, -1*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(+3*radius, +1*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(+3*radius, -1*Math.sqrt(3)*radius ));
		// BlackMan-plasseringer:
			piecesArray.push(new BlackMan(-4*radius, +0*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(-2*radius, +2*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(-2*radius, -2*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(-1*radius, +1*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(-1*radius, -1*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(+2*radius, +0*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(+2*radius, +2*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(+2*radius, -2*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(+4*radius, +0*Math.sqrt(3)*radius ));
		//////////////////////////////////////////////////////////////
			for each(var piece:Piece in piecesArray) {
				gameBoard.addChild(piece);
			}
		}
		
		public function clearChildren():void { // Rensker brettet før et eventuelt nytt turneringssett begynner
			// Rensker alle brikkene på brettet
			for each(var piece in piecesArray) {
				gameBoard.removeChild(piece);
			}
		}
		
		public function strikeFinished():void { // Kjører når alle brikkene har stoppet etter et slag.
			// Striker ned = 1 brikke av spillers farge opp
			// Queen ned = 1 brikke av spillers farge opp
			//if(getPiece("Striker", currentDeadPiecesArray))
		}
		
		public function update(e:TimerEvent=void):void{ // Oppdateringsfunksjon
			if (!piecesHaveStopped() && !strikerIsHit) { // Dersom brikker beveger seg og ikke slag er registrert, så registreres slag.
				strikerIsHit = true;
			}else if (piecesHaveStopped() && strikerIsHit) { // Dersom brikkene ikke beveger seg og et slag har blitt registrert
				// Her skal det sjekkes for neste runde
				strikerIsHit = false;
				strikeFinished();
			}
			
			for (var i = 0; i < piecesArray.length; i++ ) {
				for (var j = 0; j < i; j++ ) {
					pieceCollider(piecesArray[i], piecesArray[j]);
				}
				wallCollider(piecesArray[i]);
				piecesArray[i].x += piecesArray[i].vX;
				piecesArray[i].y += piecesArray[i].vY;
				applyFriction(piecesArray[i]);
				collectIfDead(piecesArray[i]);
			}
		}
		
		public function rotateTick(e:TimerEvent):void { // Roterer brettet
			const boardLength:int = 600;
			gameBoard.rotation += 1;
			if(Math.abs(gameBoard.rotation % 180) > 45 && Math.abs(gameBoard.rotation % 180) < 135){
				gameBoard.scaleX = boardLength/740 * Math.sqrt(2)/2;
				gameBoard.scaleY = boardLength/740 * Math.sqrt(2)/2;
			}else{
				gameBoard.height = boardLength;
				gameBoard.width = boardLength;
			}
		}
		
		public function piecesHaveStopped():Boolean { // Sjekker om brikkene ikke beveger seg / har sluttet å bevege seg
			var piecesMoving:Boolean = false;
			for each(var piece:Piece in piecesArray) {
				if (piece.vX != 0 || piece.vY != 0) {
					piecesMoving = true;
				}
			} return !piecesMoving;
		}
		
		public function wallCollider(piece:Piece):void { // Utfører veggkollisjoner for en brikke
			if (piece.x >= 370 - piece.Radius) { // Høyre vegg
				piece.vX = - Math.abs(piece.vX);
				piece.x = 370 - piece.Radius;
			} if (piece.x <= -370 + piece.Radius) { // Venstre vegg
				piece.vX = Math.abs(piece.vX);
				piece.x = -370 + piece.Radius;
			} if (piece.y <= -370 + piece.Radius) { // Øverste vegg
				piece.vY = Math.abs(piece.vY);
				piece.y = -370 + piece.Radius;
			} if (piece.y >= 370 - piece.Radius) { // Nederste vegg
				piece.vY = - Math.abs(piece.vY);
				piece.y = 370 - piece.Radius;
			}
		}
		
		public function pieceCollider(piece1:Piece, piece2:Piece):void { // Utfører et elastisk støt mellom to brikker	
			var dX:Number = piece1.x - piece2.x; // Forskjell i plassering sidelengs (langs x-aksen)
			var dY:Number = piece1.y - piece2.y // Høydeforskjell i plassering av brikkene (langs y-aksen)
			var d:Number = Math.sqrt(dX * dX + dY * dY); // Avstand mellom sentrum til de to brikkene
			var sumR:Number = piece1.Radius + piece2.Radius; // Sum av radier, altså det nærmeste to brikker kan komme hverandre.
			
			if(d <= sumR){ // Sjekker om brikkene er i kontakt med hverandre. Dersom de er dette, utføres støtet.
				// Lagring av masser i egne variabler for å gjøre formlene kortere, og enklere å forstå.
				var m1:Number = piece1.Mass;
				var m2:Number = piece2.Mass;
				
				// Lagring av fartskomponenter i egne variabler for å gjøre formlene kortere, og enklere å forstå.
				var vX1:Number = piece1.vX;
				var vY1:Number = piece1.vY;
				var vX2:Number = piece2.vX;
				var vY2:Number = piece2.vY;
				
				// Omkomponering av vektorer til vP1, vP2 som er paralelle med d, og vN1, vN2 som er normale på d
				var vP1:Number = (vX1 * dX + vY1 * dY) / d;
				var vP2:Number = (vX2 * dX + vY2 * dY) / d;
				var vN1:Number = (vX1 * dY - vY1 * dX) / d;
				var vN2:Number = (vX2 * dY - vY2 * dX) / d;
				
				var soundAmplitude:Number = Math.abs(vP1 - vP2);
				
				// Utfører det elastiske støtet mellom de to brikkene.
				var vP1_New:Number = (m1 * vP1 - m2 * vP1 + 2 * m2 * vP2) / (m1 + m2);
				var vP2_New:Number = (m2 * vP2 - m1 * vP2 + 2 * m1 * vP1) / (m1 + m2);
				
				// Omkomponerer vektorene tilbake til å være i x- og y-retning
				piece1.vX = (vP1_New * dX + vN1 * dY) / d;
				piece2.vX = (vP2_New * dX + vN2 * dY) / d;
				piece1.vY = (vP1_New * dY - vN1 * dX) / d;
				piece2.vY = (vP2_New * dY - vN2 * dX) / d;
				
				// Flytter brikkene ut av hverandre dersom de overlapper
				piece1.x += dX / (2 * d) * (piece1.Radius + piece2.Radius - d);
				piece2.x -= dX / (2 * d) * (piece1.Radius + piece2.Radius - d);
				piece1.y += dY / (2 * d) * (piece1.Radius + piece2.Radius - d);
				piece2.y -= dY / (2 * d) * (piece1.Radius + piece2.Radius - d);
			}
		}
		
		public function collectIfDead(piece:Piece):void { // Fjerner en gitt brikke fra spillet dersom den er over et hull.
			var pieceOverlaps:Boolean = false; // Sjekker om en brikke overlapper tilstrekkelig med et hull
			for each(var hole:MovieClip in holesArray) {
				var holeR:Number = hole.width/2;
				var dx:Number = hole.x - piece.x;
				var dy:Number = hole.y - piece.y;
				var d:Number = Math.sqrt(dx * dx + dy * dy);
				if (d <= holeR) {
					pieceOverlaps = true;
				}
			}
			if (pieceOverlaps) { 
				// Nullstiller brikkens fart
				piece.vX = 0;
				piece.vY = 0;
				
				gameBoard.removeChild(piece); // Fjerner brikken visuelt fra brettet
				piecesArray.splice(piecesArray.indexOf(piece), 1); // Fjerner brikken fra oppdateringsarrayen
				currentDeadPiecesArray.push(piece); // Legger brikken til i arrayen for midlertidige utslåtte brikker
				if (!players && piece.Type != "Queen" && piece.Type != "Striker") { // Dersom ikke farger er bestemt, bestemmes disse når første brikke blir slått ned (som ikke er striker eller queen)
					if ((piece.Type == "WhiteMan" && currentPlayer == 0) || (piece.Type == "BlackMan" && currentPlayer == 1)){
						players = ["WhiteMan", "BlackMan"];
					}else {
						players = ["BlackMan", "WhiteMan"];
					}
				}
			}
		}
		
		public function applyFriction(piece:Piece):void { // Utfører fartsendring forårsaket av friksjon
			var vX:Number = piece.vX;
			var vY:Number = piece.vY;
			var v:Number = Math.sqrt(vX * vX + vY * vY);
			
			if (Math.abs(v) > 25*friction) { // Standard friksjon dersom farten er større enn
				piece.vX -= friction * (vX / v);
				piece.vY -= friction * (vY / v);
			}else if (Math.abs(v) > 4*friction) { // Høyere friksjon dersom farten er lavere
				piece.vX -= 4*friction * (vX / v);
				piece.vY -= 4*friction * (vY / v);
			}else { // Dersom farten mindre enn 4*friction vil brikken stoppe
				piece.vX = 0;
				piece.vY = 0;
			}
		}
		
		public function getPiece(type:String, array:Array):Piece {
			var piece:Piece;
			for each(var p:Piece in array) {
				if (p.Type == type) piece = p;
			}
			return piece;
		}
		
		
	}
}