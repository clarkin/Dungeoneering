package  
{
	import org.flixel.*;
	
	public class FloatingText extends FlxSprite
	{
		[Embed(source = "../assets/speech_bubble.png")] private var speechBubblePNG:Class;
		
		public static const FADE_IN_TIME:Number = 0.5;
		public static const DISPLAY_TIME:Number = 2;
		public static const FADE_OUT_TIME:Number = 1;
		public static const COLOR_THINKING:uint = 0xFF3333333;
		public static const COLOR_THINKING_SHADOW:uint = 0xFF666666;
		public static const TEXT_OFFSET:FlxPoint = new FlxPoint(16, 18);
		public static const ANGLE_OFFSET:FlxPoint = new FlxPoint( -10, -17);
		public static const ANGLE:Number = -10;
		public static const FADE_IN_ANGLE:Number = -50;
		
		public var _lifetime:Number = 0;
		
		public function FloatingText(X:Number, Y:Number, Text:String=null) {
			super(X + ANGLE_OFFSET.x, Y + ANGLE_OFFSET.y);
			
			_speech_bubble = new FlxSprite(X + ANGLE_OFFSET.x, Y + ANGLE_OFFSET.y);
			_speech_bubble.loadGraphic(speechBubblePNG, false, false, 200, 139, true); 
			add(_speech_bubble);
			
			_text = new FlxText(X + TEXT_OFFSET.x + ANGLE_OFFSET.x, Y + TEXT_OFFSET.y + ANGLE_OFFSET.y, 154, Text);
			_text.setFormat("LemonsCanFly", 24, COLOR_THINKING, "left");
			if (Text.length <= 50) {
				_text.setFormat("LemonsCanFly", 30, COLOR_THINKING, "left");
			} else if (Text.length <= 25) {
				_text.setFormat("LemonsCanFly", 36, COLOR_THINKING, "left");
			}
			//_text.alpha = 1;
			//_text.antialiasing = true;
			//_text.angle = FADE_IN_ANGLE + ANGLE;
			//_text.angle = ANGLE;
			
			_speech_bubble.stamp(_text, TEXT_OFFSET.x + 9, TEXT_OFFSET.y);
			
			_speech_bubble.alpha = 0;
			_speech_bubble.antialiasing = true;
			_speech_bubble.angle = FADE_IN_ANGLE + ANGLE;
			_speech_bubble.origin = new FlxPoint(0, _speech_bubble.height);
			//_speech_bubble.angle = ANGLE;
			
			//_text.origin = new FlxPoint(0 - TEXT_OFFSET.x, _text.height - TEXT_OFFSET.y);
			//_text.origin = new FlxPoint(0 - TEXT_OFFSET.x, _speech_bubble.height - TEXT_OFFSET.y);
			
			//_text.antialiasing = true;
			//_text.angle = ANGLE;
			//add(_text);
			
			_lifetime = FADE_IN_TIME + DISPLAY_TIME + FADE_OUT_TIME;
		}
		
		override public function update():void {	
			//trace("text origin: [" + (_text.x + _text.origin.x) + "," + (_text.y + _text.origin.y) + "], speech bubble origin: [" + (_speech_bubble.x + _speech_bubble.origin.x) + "," + (_speech_bubble.y + _speech_bubble.origin.y) + "]");
			var tween:Number = 0;
			_lifetime -= FlxG.elapsed;
			if (_lifetime <= FADE_OUT_TIME) {
				tween = _lifetime / FADE_OUT_TIME;
				//_text.alpha = tween;
				_speech_bubble.alpha = tween;
			} else if (_lifetime <= FADE_OUT_TIME + DISPLAY_TIME) {
				
			} else if (_lifetime <= FADE_OUT_TIME + DISPLAY_TIME + FADE_IN_TIME) {
				tween = 1 - (_lifetime - FADE_OUT_TIME - DISPLAY_TIME) / FADE_IN_TIME;
				//_text.alpha = tween;
				//_text.angle = (1 - tween) * FADE_IN_ANGLE + ANGLE;
				_speech_bubble.alpha = tween;
				_speech_bubble.angle = (1 - tween) * FADE_IN_ANGLE + ANGLE;
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