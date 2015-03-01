package core {
	// Importerer MovieClip. Dette brukes som extension til klassen
	import flash.display.MovieClip;
	
	public class Piece extends MovieClip {
		// Deklarerer egenskaper som er felles for alle brikkene.
		protected var vx:Number = 0;
		protected var vy:Number = 0;
		protected var type:String = "Undefined";
		protected var mass:Number = 0;
		protected var radius:Number = 0;
		
		// Gjør det mulig å hente og endre fart i X-retning utenfra klassen
		public function get vX():Number{
			return vx;
		}
		public function set vX(newValue:Number):void{
			vx = newValue;
		} 
		
		// Gjør det mulig å hente og endre fart i Y-retning utenfra klassen
		public function get vY():Number{
			return vy;
		}
		public function set vY(newValue:Number):void{
			vy = newValue;
		}
		
		// Gjør det mulig å hente masse, radius og type brikke
		public function get Mass():Number{
			return mass;
		}
		public function get Radius():Number {
			return radius;
		}
		public function get Type():String {
			return type;
		}
	}
}