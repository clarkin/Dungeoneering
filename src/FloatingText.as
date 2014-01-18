package  
{
	import org.flixel.*;
	
	public class FloatingText extends FlxText 
	{
		public static const FADETIME:Number = 3;
		public static const SPEED:Number = 2;
		public static const COLOR_THINKING:uint = 0xFF83F06D
		public static const COLOR_THINKING_SHADOW:uint = 0xFF36632D;
		
		public var _lifetime:Number = 0;
		
		public function FloatingText(X:Number, Y:Number, Text:String=null) {
			super(X, Y, 400, Text)
			
			setFormat("LemonsCanFly", 40, COLOR_THINKING, "left", COLOR_THINKING_SHADOW);
			alpha = 1;
			_lifetime = FADETIME;
		}
		
		override public function update():void {	
			
			_lifetime -= FlxG.elapsed;
			if (_lifetime <= 1) {
				alpha = _lifetime / FADETIME;
				y -= FlxG.elapsed * (SPEED * (1 / alpha));
			}
			
			if (_lifetime <= 0) {
				kill();
			}
			
			super.update();
		}
	}

}