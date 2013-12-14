package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	import org.flixel.FlxG;

	public class GambrinousPreloader extends MovieClip
	{
		[Embed(source="../assets/gambrinous_logo.jpg")] protected var ImgLogo:Class;
		[Embed(source="../assets/logo_corners.png")] protected var ImgLogoCorners:Class;

		protected var _init:Boolean;
		protected var _buffer:Sprite;
		protected var _bmpBar:Bitmap;
		protected var _text:TextField;
		protected var _width:uint;
		protected var _height:uint;
		protected var _logo:Bitmap;
		protected var _logoGlow:Bitmap;
		protected var _min:uint;
		public var className:String;
		public var myURL:String;
		public var minDisplayTime:Number;
		
		public var VERSION:Number = 0.6;
		
		public function GambrinousPreloader()
		{
			minDisplayTime = 5;
			
			stop();
            stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = "";// StageAlign.TOP_LEFT;
			
			//Check if we are on debug or release mode and set _DEBUG accordingly
            try
            {
                throw new Error("Setting global debug flag...");
            }
            catch(E:Error)
            {
                var re:RegExp = /\[.*:[0-9]+\]/;
                FlxG.debug = re.test(E.getStackTrace());
            }
			
			var tmp:Bitmap;
			if(!FlxG.debug && (myURL != null) && (root.loaderInfo.url.indexOf(myURL) < 0))
			{
				tmp = new Bitmap(new BitmapData(stage.stageWidth,stage.stageHeight,true,0xFFFFFFFF));
				addChild(tmp);
				
				var format:TextFormat = new TextFormat();
				format.color = 0x000000;
				format.size = 24;
				format.align = "center";
				format.bold = true;
				format.font = "system";
				
				var textField:TextField = new TextField();
				textField.width = tmp.width-16;
				textField.height = tmp.height-16;
				textField.y = 24;
				textField.multiline = true;
				textField.wordWrap = true;
				textField.embedFonts = true;
				textField.defaultTextFormat = format;
				textField.text = "Hi there!  It looks like somebody copied this game without my permission.  Just click anywhere, or copy-paste this URL into your browser.\n\n"+myURL+"\n\nto play the game at my site.  Thanks, and have fun!";
				addChild(textField);
				
				textField.addEventListener(MouseEvent.CLICK,goToMyURL);
				tmp.addEventListener(MouseEvent.CLICK,goToMyURL);
				return;
			}
			this._init = false;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function goToMyURL(event:MouseEvent=null):void
		{
			navigateToURL(new URLRequest("http://"+myURL));
		}
		
		private function onEnterFrame(event:Event):void
        {
			if(!this._init)
			{
				if((stage.stageWidth <= 0) || (stage.stageHeight <= 0))
					return;
				create();
				this._init = true;
			}
            graphics.clear();
			var time:uint = getTimer();
            if((framesLoaded >= totalFrames) && (time > _min))
            {
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                nextFrame();
                var mainClass:Class = Class(getDefinitionByName(className));
	            if(mainClass)
	            {
	                var app:Object = new mainClass();
	                addChild(app as DisplayObject);
	            }
                destroy();
            }
            else
			{
				var percent:Number = root.loaderInfo.bytesLoaded/root.loaderInfo.bytesTotal;
				if((_min > 0) && (percent > time/_min))
					percent = time/_min;
            	update(percent);
			}
        }
		
		/**
		 * Override this to create your own preloader objects.
		 * Highly recommended you also override update()!
		 */
		protected function create():void
		{
			_min = 0;
			if(!FlxG.debug)
				_min = minDisplayTime*1000;
			_buffer = new Sprite();
			_buffer.scaleX = 2;
			_buffer.scaleY = 2;
			addChild(_buffer);
			_width = stage.stageWidth/_buffer.scaleX;
			_height = stage.stageHeight/_buffer.scaleY;
			_buffer.addChild(new Bitmap(new BitmapData(_width,_height,false,0x000000)));
			//var bitmap:Bitmap = new ImgLogoLight();
			//bitmap.smoothing = true;
			//bitmap.width = bitmap.height = _height;
			//bitmap.x = (_width-bitmap.width)/2;
			//_buffer.addChild(bitmap);
			_bmpBar = new Bitmap(new BitmapData(1,7,false,0x5f6aff));
			_bmpBar.x = 4;
			_bmpBar.y = _height-11;
			_buffer.addChild(_bmpBar);
			_text = new TextField();
			_text.defaultTextFormat = new TextFormat("system",8,0x5f6aff);
			_text.embedFonts = true;
			_text.selectable = false;
			_text.multiline = false;
			_text.x = 2;
			_text.y = _bmpBar.y - 11;
			_text.width = 80;
			_buffer.addChild(_text);
			_logo = new ImgLogo();
			//_logo.scaleX = _logo.scaleY = _height/8;
			_logo.x = (_width-_logo.width)/2;
			_logo.y = (_height-_logo.height)/2;
			_buffer.addChild(_logo);
			_logoGlow = new ImgLogo();
			_logoGlow.smoothing = true;
			_logoGlow.blendMode = "screen";
			_logoGlow.scaleX = _logoGlow.scaleY = _height/8;
			_logoGlow.x = (_width-_logoGlow.width)/2;
			_logoGlow.y = (_height-_logoGlow.height)/2;
			_buffer.addChild(_logoGlow);
			var bitmap:Bitmap = new ImgLogoCorners();
			bitmap.smoothing = true;
			bitmap.width = _width;
			bitmap.height = _height;
			_buffer.addChild(bitmap);
			bitmap = new Bitmap(new BitmapData(_width,_height,false,0xffffff));
			var i:uint = 0;
			var j:uint = 0;
			while(i < _height)
			{
				j = 0;
				while(j < _width)
					bitmap.bitmapData.setPixel(j++,i,0);
				i+=2;
			}
			bitmap.blendMode = "overlay";
			bitmap.alpha = 0.25;
			_buffer.addChild(bitmap);
		}
		
		protected function destroy():void
		{
			removeChild(_buffer);
			_buffer = null;
			_bmpBar = null;
			_text = null;
			_logo = null;
			_logoGlow = null;
		}
		
		/**
		 * Override this function to manually update the preloader.
		 * 
		 * @param	Percent		How much of the program has loaded.
		 */
		protected function update(Percent:Number):void
		{
			_bmpBar.scaleX = Percent*(_width-8);
			_text.text = "    v"+VERSION+" "+Math.floor(Percent*100)+"%";
			_text.setTextFormat(_text.defaultTextFormat);
			if(Percent < 0.1)
			{
				_logoGlow.alpha = 0;
				_logo.alpha = 0;
			}
			else if(Percent < 0.15)
			{
				_logoGlow.alpha = Math.random();
				_logo.alpha = 0;
			}
			else if(Percent < 0.2)
			{
				_logoGlow.alpha = 0;
				_logo.alpha = 0;
			}
			else if(Percent < 0.25)
			{
				_logoGlow.alpha = 0;
				_logo.alpha = Math.random();
			}
			else if(Percent < 0.7)
			{
				_logoGlow.alpha = (Percent-0.45)/0.45;
				_logo.alpha = 1;
			}
			else if((Percent > 0.8) && (Percent < 0.9))
			{
				_logoGlow.alpha = 1-(Percent-0.8)/0.1;
				_logo.alpha = 0;
			}
			else if(Percent > 0.9)
			{
				_buffer.alpha = 1-(Percent-0.9)/0.1;
			}
		}
	}
}
