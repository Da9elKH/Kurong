package core.pieces {
	// Importerer klassen Piece (Piece er baseklassen for alle brikkene).
	import core.Piece;
	
	// BlackMan er en extension av Piece.
	public class BlackMan extends Piece {
		
		// Constructor-funksjon (Kjører når en versjon av objektet blir laget)
		public function BlackMan(X:Number, Y:Number):void {
			// Setter egenskapene til BlackMan ved konstruksjon
			x = X;
			y = Y;
			mass = 5;
			radius = 15.5;
			type = "BlackMan";
		}
	}
}