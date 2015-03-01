package core.pieces {
	// Importerer klassen Piece (Piece er baseklassen for alle brikkene).
	import core.Piece;
	
	// WhiteMan er en extension av Piece.
	public class WhiteMan extends Piece {
		
		// Constructor-funksjon (Kjører når en versjon av objektet blir laget)
		public function WhiteMan(X:Number, Y:Number):void {
			// Setter egenskapene til WhiteMan ved konstruksjon
			x = X;
			y = Y;
			mass = 5;
			radius = 15.5;
			type = "WhiteMan";
		}
	}
}