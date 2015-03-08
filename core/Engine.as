package core {
	//{ IMPORTS
	import core.Piece;
	import core.pieces.WhiteMan;
	import core.pieces.BlackMan;
	import core.pieces.Queen;
	import core.pieces.Striker;
	import flash.display.MovieClip;
	import flash.display.ShaderParameter;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.media.Sound;
	//}
	
	public class Engine {
		
		//{	VARIABLER
		
		var whiteColor:int = 0xFFE49F;
		var blackColor:int = 0x4B2F1F;
		var neutralColor:int = 0xFFFFFF;
		
		public var wallCollisionSound:Sound;
		public var pieceCollisionSound:Sound;
		public var holeSound:Sound;
		
		private var gameTimer:Timer = new Timer(0, 0); // Spilltimeren (kjører oppdateringsfunksjonen)
		private var rotateTimer:Timer = new Timer(0, 180); // Rotasjonstimer (kjører når brettet roteres 180 grader)
		
		public var currentPlayer:int; // 0=spiller1 && 1=spiller2 //
		private var currentRound:int; // Lagrer foreløpig runde i en eventuell turnering.
		private var friction:Number = 0.01; // Friksjonskonstant mellom brett og brikke
		
		public var piecesArray:Array; // Lagrer alle brikker i spill
		private var deadPiecesArray:Array; // Lagrer alle brikker som har blitt slått ut av spillet
		private var currentDeadPiecesArray:Array = new Array; // Lagrer brikker som har blitt slått ned i dette slaget.
		private var holesArray:Array = new Array(); // Lagrer hullene på brettet
		public var scores:Array = [0, 0]; // Lagrer poengene til hver spiller
		private var scoreBoard:MovieClip; // 
		private var players:Array = new Array(); // Kopler spiller og brikker sammen.
		private var numGames:int = 1; // Antall spill som skal spilles.
		public var winMessage:MovieClip; // Overlayen som kommer opp når en spiller vinner.
		
		public var strikerIsHit:Boolean; // Lagrer hvorvidt runden har blitt startet ved å skyte striker.
		private var gameBoard:MovieClip; // Lagrer brettet
		public var striker:Striker; //} Lagrer Striker
		
		public function set Scores(newValue:Array):void {
			scores = newValue;
			updateScores();
		}
		
		public function Engine(board:MovieClip, ScoreBoard:MovieClip, gameCount:int):void { // Contructor-funksjon for Engine-klassen.
			gameTimer.addEventListener(TimerEvent.TIMER, update);
			rotateTimer.addEventListener(TimerEvent.TIMER, rotateTick);
			scoreBoard = ScoreBoard;
			gameBoard = board;
			holesArray.push(board.h1);
			holesArray.push(board.h2);
			holesArray.push(board.h3);
			holesArray.push(board.h4);
			numGames = gameCount;
			newGame();
		}
		
		public function newGame():void { // Resetter brettet til en ny start.

			gameTimer.start(); // Starter spill-timeren
			clearAll(); // Fjerner alle brikkene som har blitt slått ned fra forrige runde (og resetter fargene på poengsummene)
			
		//////////////////// PLASSERING AV BRIKKER ///////////////////
		const radius:Number = 15.5;
		// Striker-plassering
			piecesArray.push(new Striker(0, 245.2));
		// Queen-plassering
			piecesArray.push(new Queen(0,0));
		// WhiteMan-plasseringer:
			piecesArray.push(new WhiteMan( 0*radius,  2*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan( 0*radius, -2*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(-3*radius,  1*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(-3*radius, -1*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan(-2*radius,  0*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan( 1*radius,  1*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan( 1*radius, -1*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan( 3*radius,  1*Math.sqrt(3)*radius ));
			piecesArray.push(new WhiteMan( 3*radius, -1*Math.sqrt(3)*radius ));
		// BlackMan-plasseringer:
			piecesArray.push(new BlackMan(-4*radius,  0*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(-2*radius,  2*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(-2*radius, -2*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(-1*radius,  1*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan(-1*radius, -1*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan( 2*radius,  0*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan( 2*radius,  2*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan( 2*radius, -2*Math.sqrt(3)*radius ));
			piecesArray.push(new BlackMan( 4*radius,  0*Math.sqrt(3)*radius ));
		//////////////////////////////////////////////////////////////
			striker = Striker(getPiece("Striker", piecesArray)); // Lagrer strikeren i en egen variabel som kan nås utenfra klassen. (Brukes til plassering og skyting av Striker da dette skjer i Main.fla)
			for each(var piece:Piece in piecesArray) { // Legger brikkenes symboler til på brettet slik at brikkene blir synlige.
				gameBoard.addChild(piece);
			}
		}
		
		public function clearAll():void { // Rensker brettet og tilhørende data før et eventuelt nytt turneringssett begynner
			// Rensker alle brikkene på brettet (kun visuell fjerning/fjerning av childs)
			for each(var piece in piecesArray) {
				gameBoard.removeChild(piece);
			}
			// Resetting av score-farger (den visuelle representasjonen av brikke-tilknytning)
			scoreBoard.lblPlayerScore1.textColor = neutralColor;
			scoreBoard.lblPlayerPoints1.textColor = neutralColor;
			scoreBoard.lblPlayerScore2.textColor = neutralColor;
			scoreBoard.lblPlayerPoints2.textColor = neutralColor;
			
			currentPlayer = 0; // Setter første spiller til å begynne
			gameBoard.rotation = 0; // Setter brettet i sin startrotasjon
			players = new Array(); // Rensker farger koplet til spillere fra en eventuell tidligere runde.
			piecesArray = new Array(); // Rensker arrayen som lagrer alle brikkene på brettet fra en eventuell tidligere runde.
			deadPiecesArray = new Array(); // Rensker alle de tidligere nedslåtte brikkene fra en eventuell tidligere runde.
			currentDeadPiecesArray = new Array(); // Rensker brikkene som sist ble slått ned fra en eventuell tidligere runde.
			scoreBoard.currentPlayerStriker.y = -103.8; // Resetter posisjonen til strikeren som viser spillers tur
			strikerIsHit = false; // Forteller at et slag ikke er satt i gang, og derfor kan gjennomføres.
			updateScores(); // Oppdaterer spillernes poengsummer.
			
			// Brikkene og tallene som representerer antall nedslåtte brikker skjules frem til første brikke er slått ned, og fargene er bestemt.
			scoreBoard.objPlayerWhite.visible = false;
			scoreBoard.objPlayerBlack.visible = false;
			scoreBoard.lblPlayerPoints1.visible = false;
			scoreBoard.lblPlayerPoints2.visible = false;
		}
		
		public function strikeFinished():void { // Kjører når alle brikkene har stoppet etter et slag.
			var roundWon:Boolean = false; // Sjekker om spillet er vunnet
			if(players.length){
				if (getPiece("Queen", currentDeadPiecesArray) && !getPiece(players[currentPlayer], piecesArray)) { 
					// Dersom dronningen blir slått ned og spilleren som slår ikke lenger har brikker av sin farge på brettet vil denne spilleren vinne runden.
					scores[currentPlayer]++; // Spilleren får poeng for vunnet runde
					Scores = scores; // Sørger for at poengsummene blir oppdatert ved å bruke set-funksjonen for score.
					roundWon = true; // Hopper over resten av koden som ville kjørt dersom spillet ikke var vunnet
					if (scores[0] < (numGames + 1) / 2 && scores[1] < (numGames + 1) / 2) { // Dersom en spillers totale poengsum kan overskrides av motspilleren i de gjenværende rundene, starter en ny runde.
						newGame();
					}else { // Alle runder er ferdig, og en melding popper opp som sier hvem som vant sammenlagt. {Hurtigspill->først til 1p , 3 runder->først til 2p , 5 runder->først til 3p}
						gameTimer.stop();
						strikerIsHit = true;
						if (scores[0] > scores[1]) {
							winMessage.lblMessage.text = "Spiller 1 har vunnet!";
						}else {
							winMessage.lblMessage.text = "Spiller 2 har vunnet!";
						}winMessage.visible = true;
					}
				}
			}
			if (!roundWon) { // Skjer dersom runden ikke er over
				var punishment:int = 0; // Holder styr på hvor mange brikker som skal tilbake på brettet
				var otherPlayer:int = int(!Boolean(currentPlayer)); // Tallverdien for den andre spilleren
				var nextPlayer:Boolean = false; // Lagrer hvorvidt turen skal gå videre til neste spiller, eller om spilleren får et nytt slag.
				//////////
				if (!players.length) { // Dersom brikkenes farger er tilknyttet til spillerne
					nextPlayer = true;
				}else{
					if (getPiece(players[otherPlayer], currentDeadPiecesArray)) {
						nextPlayer = true;
					} else if (!getPiece(players[currentPlayer], currentDeadPiecesArray)) {
						nextPlayer = true;
					}
				}
				///////
				for each(var p:Piece in currentDeadPiecesArray) {
					if (p.Type == "Queen") { // Dersom en dronning er slått ned før alle andre egne brikker
						// Plasserer brikken et sted i sentrum av brettet.
						p.x = 10*(Math.random()-0.5);
						p.y = 10*(Math.random()-0.5);
						gameBoard.addChild(p);
						piecesArray.push(p);
						punishment++; // Legger til på straffekvoten
						nextPlayer = true;
					}else if (p.Type == "Striker") { // Dersom strikeren har blitt slått ned, plasseres den tilbake på brettet.
						p.x = 0;
						p.y = (currentPlayer == 0) ? 245.2: -245.2; // Plasserer den i midten av feltet fra hvor den skal skytes i neste slag.
						gameBoard.addChild(p);
						piecesArray.push(p);
						punishment++;
						nextPlayer = true;
					}else {
						deadPiecesArray.push(p);
					}
				} 
				currentDeadPiecesArray = new Array();
				updateScores();
				
				if(players.length){
					for (var i:int = 0; i < punishment; i++ ) { // Utfører straffen ved å plassere brikker tilbake på brettet dersom tilstrekkelig er slått ned
						var piece:Piece = getPiece(players[currentPlayer],deadPiecesArray);
						if (piece) {
							piece.x = 10*(Math.random()-0.5); // 
							piece.y = 10*(Math.random()-0.5);
							gameBoard.addChild(piece);
							piecesArray.push(piece);
							deadPiecesArray.splice(deadPiecesArray.indexOf(piece), 1);
						}
					} updateScores();
				}
				
				if (nextPlayer) { // Roterer brettet og flytter spillermarkøren (striker-bildet)
					rotateTimer.reset();
					rotateTimer.start();
					currentPlayer = otherPlayer;
					if(otherPlayer == 0){
						scoreBoard.currentPlayerStriker.y = -103.8;
					}else {
						scoreBoard.currentPlayerStriker.y = 48.8;
					}
				}
			}
		}
		
		public function update(e:TimerEvent = void):void { // Oppdateringsfunksjon
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
			var sPlay:Boolean = false;
			
			if (piece.x >= 370 - piece.Radius) { // Høyre vegg
				piece.vX = - Math.abs(piece.vX);
				piece.x = 370 - piece.Radius;
				sPlay = true;
			} if (piece.x <= -370 + piece.Radius) { // Venstre vegg
				piece.vX = Math.abs(piece.vX);
				piece.x = -370 + piece.Radius;
				sPlay = true;
			} if (piece.y <= -370 + piece.Radius) { // Øverste vegg
				piece.vY = Math.abs(piece.vY);
				piece.y = -370 + piece.Radius;
				sPlay = true;
			} if (piece.y >= 370 - piece.Radius) { // Nederste vegg
				piece.vY = - Math.abs(piece.vY);
				piece.y = 370 - piece.Radius;
				sPlay = true;
			}
			
			if (sPlay) {
				wallCollisionSound.play(0);
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
				
				if (vX1*vX1 + vY1*vY1 != 0 || vX2*vX2 + vY2*vY2 != 0) {
					//Spiller av lyden av kollisjon med brikke (gitt at farten til begge brikkene ikke er 0);
					pieceCollisionSound.play(0);
				}
				
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
				//Spiller av lyd
				holeSound.play(0);
				
				// Nullstiller brikkens fart
				piece.vX = 0;
				piece.vY = 0;
				
				currentDeadPiecesArray.push(piece); // Legger brikken til i arrayen for midlertidige utslåtte brikker
				
				gameBoard.removeChild(piece); // Fjerner brikken visuelt fra brettet
				piecesArray.splice(piecesArray.indexOf(piece), 1); // Fjerner brikken fra oppdateringsarrayen
				updateScores();
				
				if (!players.length && piece.Type != "Queen" && piece.Type != "Striker") { // Dersom ikke farger er bestemt, bestemmes disse når første brikke blir slått ned (som ikke er Striker eller Queen)
					scoreBoard.objPlayerWhite.visible = true;
					scoreBoard.objPlayerBlack.visible = true;
					scoreBoard.lblPlayerPoints1.visible = true;
					scoreBoard.lblPlayerPoints2.visible = true;
					
					if ((piece.Type == "WhiteMan" && currentPlayer == 0) || (piece.Type == "BlackMan" && currentPlayer == 1)){
						players = ["WhiteMan", "BlackMan"];
						scoreBoard.lblPlayerScore1.textColor = whiteColor;
						scoreBoard.lblPlayerScore2.textColor = blackColor;
						scoreBoard.lblPlayerPoints1.textColor = whiteColor;
						scoreBoard.lblPlayerPoints2.textColor = blackColor;
						scoreBoard.objPlayerWhite.y = -52;
						scoreBoard.objPlayerBlack.y = 99;
					}else {
						players = ["BlackMan", "WhiteMan"];
						scoreBoard.lblPlayerScore1.textColor = blackColor;
						scoreBoard.lblPlayerScore2.textColor = whiteColor;
						scoreBoard.lblPlayerPoints1.textColor = blackColor;
						scoreBoard.lblPlayerPoints2.textColor = whiteColor;
						scoreBoard.objPlayerWhite.y = 99;
						scoreBoard.objPlayerBlack.y = -52;
					}
					updateScores();
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
		
		public function getPieceCount(type:String, array:Array):int {
			var count:int = 0;
			for each(var p:Piece in array) {
				if (p.Type == type) count++;
			}
			return count;
		}
		
		public function updateScores():void {
			scoreBoard.lblPlayerScore1.text = String(scores[0]) + " p";
			scoreBoard.lblPlayerScore2.text = String(scores[1]) + " p";
			if(players){
				scoreBoard.lblPlayerPoints1.text = "x" + String(getPieceCount(players[0], deadPiecesArray) + getPieceCount(players[0], currentDeadPiecesArray));
				scoreBoard.lblPlayerPoints2.text = "x" + String(getPieceCount(players[1], deadPiecesArray) + getPieceCount(players[1], currentDeadPiecesArray));
			}
		}
	}
}