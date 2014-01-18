package  
{
	import org.flixel.*;
	
	public class FloatingText extends FlxGroup 
	{
		[Embed(source = "../assets/speech_bubble.png")] private var speechBubblePNG:Class;
		
		public static const FADETIME:Number = 3;
		public static const SPEED:Number = 2;
		public static const COLOR_THINKING:uint = 0xFF3333333;
		public static const COLOR_THINKING_SHADOW:uint = 0xFF666666;
		public static const TEXT_OFFSET:FlxPoint = new FlxPoint(16, 18);
		public static const ANGLE:Number = -10;
		public static const ANGLE_OFFSET:FlxPoint = new FlxPoint( -10, -17);
		
		public var _lifetime:Number = 0;
		
		private var _speech_bubble:FlxSprite;
		private var _text:FlxText;
		
		public function FloatingText(X:Number, Y:Number, Text:String=null) {
			super();
			
			_speech_bubble = new FlxSprite(X + ANGLE_OFFSET.x, Y + ANGLE_OFFSET.y, speechBubblePNG);
			_speech_bubble.alpha = 1;
			_speech_bubble.antialiasing = true;
			_speech_bubble.angle = ANGLE;
			add(_speech_bubble);
			
			_text = new FlxText(X + TEXT_OFFSET.x + ANGLE_OFFSET.x, Y + TEXT_OFFSET.y + ANGLE_OFFSET.y, 154, Text);
			_text.setFormat("LemonsCanFly", 24, COLOR_THINKING, "left");
			if (Text.length <= 50) {
				_text.setFormat("LemonsCanFly", 30, COLOR_THINKING, "left");
			} else if (Text.length <= 25) {
				_text.setFormat("LemonsCanFly", 36, COLOR_THINKING, "left");
			}
			_text.alpha = 1;
			_text.antialiasing = true;
			_text.angle = ANGLE;
			add(_text);
			
			_lifetime = FADETIME;
		}
		
		override public function update():void {	
			
			_lifetime -= FlxG.elapsed;
			if (_lifetime <= 1) {
				_text.alpha = _lifetime / 1;
				_speech_bubble.alpha = _lifetime / 1;
				//y -= FlxG.elapsed * (SPEED * (1 / alpha));
			}
			
			if (_lifetime <= 0) {
				_text = null;
				_speech_bubble = null;
				kill();
			}
			
			super.update();
		}
	}

}