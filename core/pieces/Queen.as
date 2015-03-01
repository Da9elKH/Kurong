package core.pieces {
	// Importerer klassen Piece (Piece er baseklassen for alle brikkene).
	import core.Piece;
	
	// Queen er en extension av Piece.
	public class Queen extends Piece {
		
		// Constructor-funksjon (Kjører når en versjon av objektet blir laget)
		public function Queen(X:Number, Y:Number):void {
			// Setter egenskapene til Queen ved konstruksjon
			x = X;
			y = Y;
			mass = 5;
			radius = 15.5;
			type = "Queen";
		}
	}
}