package  
{
	import org.flixel.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	
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
		public var _delay:Number = 0;
		public var _status:String = "FADING_IN";
		
		public function FloatingText(X:Number, Y:Number, Text:String = null, delay:Number = 0) {
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
			_delay = delay;
			
			_lifetime = _delay + FADE_IN_TIME + DISPLAY_TIME + FADE_OUT_TIME;
			//trace("_lifetime: " + _lifetime + " including delay of " + _delay);
			
			TweenLite.to(this, FADE_IN_TIME, { angle:ANGLE, delay:_delay, ease:Back.easeOut.config(1) } );
			TweenLite.to(this, FADE_IN_TIME, { alpha:1.0, delay:_delay, ease:Back.easeOut.config(1) } );
			TweenLite.to(this, FADE_IN_TIME, { bothScale:1.0, delay:_delay, ease:Back.easeOut.config(1) } );
		}
		
		override public function update():void {	
			_lifetime -= FlxG.elapsed;
			if (_lifetime <= 0) {
				//trace("status: killing, _lifetime: " + _lifetime);
				kill();
			} else if (_lifetime <= FADE_OUT_TIME && _status == "SHOWING") {
				//trace("status: fading_out, _lifetime: " + _lifetime);
				_status = "FADING_OUT";
				TweenLite.to(this, FADE_OUT_TIME, { angle:FADE_IN_ANGLE + ANGLE, ease:Back.easeIn.config(1) } );
				TweenLite.to(this, FADE_OUT_TIME, { alpha:0.0, ease:Back.easeIn.config(1) } );
				TweenLite.to(this, FADE_OUT_TIME, { bothScale:0.0, ease:Back.easeIn.config(1) } );
			} else if (_lifetime <= FADE_OUT_TIME + DISPLAY_TIME && _status == "FADING_IN") {
				//trace("status: showing, _lifetime: " + _lifetime);
				_status = "SHOWING";
			} else if (_lifetime <= FADE_OUT_TIME + DISPLAY_TIME + FADE_IN_TIME) {
				
			}
			
			
			
			super.update();
		}
		
	}

}