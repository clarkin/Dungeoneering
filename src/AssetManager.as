package  
{
	import org.flixel.*;
	import org.as3wavsound.*;
	import flash.utils.ByteArray;
	
	public class AssetManager 
	{
		[Embed(source = "../assets/sfx/cheer.wav", mimeType = "application/octet-stream")] private static const cheer:Class;
		[Embed(source = "../assets/sfx/coins.wav", mimeType = "application/octet-stream")] private static const coins:Class;
		[Embed(source = "../assets/sfx/deathscream.wav", mimeType = "application/octet-stream")] private static const deathscream:Class;
		[Embed(source = "../assets/sfx/doorcreak.wav", mimeType = "application/octet-stream")] private static const doorcreak:Class;
		[Embed(source = "../assets/sfx/footsteps.wav", mimeType = "application/octet-stream")] private static const footsteps:Class;
		[Embed(source = "../assets/sfx/lots_of_coins.wav", mimeType = "application/octet-stream")] private static const lotsofcoins:Class;
		[Embed(source = "../assets/sfx/sword_kill.wav", mimeType = "application/octet-stream")] private static const swordkill:Class;
		[Embed(source = "../assets/sfx/demon_talk1.wav", mimeType = "application/octet-stream")] private static const demontalk1:Class;
		[Embed(source = "../assets/sfx/demon_talk2.wav", mimeType = "application/octet-stream")] private static const demontalk2:Class;
		[Embed(source = "../assets/sfx/dungeoneer_talk1.wav", mimeType = "application/octet-stream")] private static const dungeoneertalk1:Class;
		
		private var _playState:PlayState;
		
		public var _sounds:Array = new Array();
		public var _soundsEnabled:Boolean = true;
		
		public function AssetManager(playState:PlayState) 
		{
			_playState = playState;
			
			LoadSound("cheer");
			LoadSound("coins");
			LoadSound("deathscream");
			LoadSound("doorcreak");
			LoadSound("footsteps");
			LoadSound("lotsofcoins");
			LoadSound("swordkill");
			LoadSound("demontalk1");
			LoadSound("demontalk2");
			LoadSound("dungeoneertalk1");
		}
		
		public function LoadSound(soundName:String):void {
			var soundReference:Class = AssetManager[soundName] as Class;
			_sounds[ soundName ] = new WavSound(new soundReference() as ByteArray); 
		}
		
		public function PlaySound(soundName:String):void {
			if (_soundsEnabled) {
				_sounds[ soundName ].play();
				tr("played sound " + soundName);
			}
		}
		
	}

}