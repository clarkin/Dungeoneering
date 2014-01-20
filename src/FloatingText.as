package  
{
	import org.flixel.*;
	
	public class FloatingText extends FlxSprite
	{
		[Embed(source = "../assets/speech_bubble.png")] private var speechBubblePNG:Class;
		
		public static const FADE_IN_TIME:Number = 0.3;
		public static const DISPLAY_TIME:Number = 2.5;
		public static const FADE_OUT_TIME:Number = 0.5;
		public static const COLOR_THINKING:uint = 0xFF3333333;
		public static const COLOR_THINKING_SHADOW:uint = 0xFF666666;
		public static const TEXT_OFFSET:FlxPoint = new FlxPoint(16, 18);
		public static const ANGLE:Number = -10;
		public static const FADE_IN_ANGLE:Number = -50;
		
		public var _lifetime:Number = 0;
		
		public function FloatingText(X:Number, Y:Number, Text:String = null) {
			super(X, Y);
			
			loadGraphic(speechBubblePNG, false, false, 200, 139, true); 
			
			var _text:FlxText = new FlxText(X, Y, 154, Text);
			_text.setFormat("LemonsCanFly", 24, COLOR_THINKING, "left");
			if (Text.length <= 50) {
				_text.setFormat("LemonsCanFly", 30, COLOR_THINKING, "left");
			} else if (Text.length <= 25) {
				_text.setFormat("LemonsCanFly", 36, COLOR_THINKING, "left");
			}
			stamp(_text, TEXT_OFFSET.x + 9, TEXT_OFFSET.y);
			_text = null;
			
			alpha = 0;
			antialiasing = true;
			angle = FADE_IN_ANGLE + ANGLE;
			origin = new FlxPoint(0, height);
			scale = new FlxPoint(0.0, 0.0);
			
			_lifetime = FADE_IN_TIME + DISPLAY_TIME + FADE_OUT_TIME;
		}
		
		override public function update():void {	
			var tween:Number = 0;
			_lifetime -= FlxG.elapsed;
			if (_lifetime <= FADE_OUT_TIME) {
				tween = _lifetime / FADE_OUT_TIME;
				alpha = tween;
				angle = (1 - tween) * FADE_IN_ANGLE + ANGLE;
				scale.x = scale.y = tween;
			} else if (_lifetime <= FADE_OUT_TIME + DISPLAY_TIME) {
				
			} else if (_lifetime <= FADE_OUT_TIME + DISPLAY_TIME + FADE_IN_TIME) {
				tween = 1 - (_lifetime - FADE_OUT_TIME - DISPLAY_TIME) / FADE_IN_TIME;
				alpha = tween;
				angle = (1 - tween) * FADE_IN_ANGLE + ANGLE;
				scale.x = scale.y = tween;
			}
			
			if (_lifetime <= 0) {
				kill();
			}
			
			super.update();
		}
	}

}