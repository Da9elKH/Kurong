package core.pieces {
	// Importerer klassen Piece (Piece er baseklassen for alle brikkene).
	import core.Piece;
	
	// Striker er en extension av Piece.
	public class Striker extends Piece {
		
		// Constructor-funksjon (Kjører når en versjon av objektet blir laget)
		public function Striker(X:Number, Y:Number):void {
			// Setter egenskapene til Striker ved konstruksjon
			x = X;
			y = Y;
			mass = 15;
			radius = 20.5;
			type = "Striker";
		}
	}
}