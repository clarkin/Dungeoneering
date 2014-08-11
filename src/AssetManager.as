package  
{
	import org.flixel.*;
	import org.as3wavsound.*;
	import flash.utils.ByteArray;
	
	public class AssetManager 
	{
		[Embed(source = "../assets/sfx/ui/bell.wav", mimeType = "application/octet-stream")] private static const bell:Class;
		[Embed(source = "../assets/sfx/ui/card_single.wav", mimeType = "application/octet-stream")] private static const card_single:Class;
		[Embed(source = "../assets/sfx/ui/cards_shuffle.wav", mimeType = "application/octet-stream")] private static const cards_shuffle:Class;
		[Embed(source = "../assets/sfx/ui/dice1.wav", mimeType = "application/octet-stream")] private static const dice1:Class;
		[Embed(source = "../assets/sfx/ui/dice2.wav", mimeType = "application/octet-stream")] private static const dice2:Class;
		[Embed(source = "../assets/sfx/ui/paper1.wav", mimeType = "application/octet-stream")] private static const paper1:Class;
		[Embed(source = "../assets/sfx/ui/paper2.wav", mimeType = "application/octet-stream")] private static const paper2:Class;
		[Embed(source = "../assets/sfx/ui/paper3.wav", mimeType = "application/octet-stream")] private static const paper3:Class;
		[Embed(source = "../assets/sfx/ui/paper4.wav", mimeType = "application/octet-stream")] private static const paper4:Class;
		[Embed(source = "../assets/sfx/ui/pop1.wav", mimeType = "application/octet-stream")] private static const pop1:Class;
		[Embed(source = "../assets/sfx/ui/pop2.wav", mimeType = "application/octet-stream")] private static const pop2:Class;
		[Embed(source = "../assets/sfx/ui/scroll_rollup.wav", mimeType = "application/octet-stream")] private static const scroll_rollup:Class;
		[Embed(source = "../assets/sfx/ui/scroll_unroll.wav", mimeType = "application/octet-stream")] private static const scroll_unroll:Class;
		[Embed(source = "../assets/sfx/ui/swoosh.wav", mimeType = "application/octet-stream")] private static const swoosh:Class;
		[Embed(source = "../assets/sfx/ui/click_double.wav", mimeType = "application/octet-stream")] private static const click_double:Class;
		[Embed(source = "../assets/sfx/ui/click_down.wav", mimeType = "application/octet-stream")] private static const click_down:Class;
		[Embed(source = "../assets/sfx/ui/click_up.wav", mimeType = "application/octet-stream")] private static const click_up:Class;
		
		//[Embed(source = "../assets/sfx/ui/bell.wav", mimeType = "application/octet-stream")] private static const ui_bell:Class;
		
		private var _playState:PlayState;
		
		public var _sounds:Array = new Array();
		public var _sound_names:Array = new Array();
		
		public function AssetManager(playState:PlayState) 
		{
			_playState = playState;
			
			//_sound_names = ["bell", "card_single", "cards_shuffle", "dice1", "dice2", "paper1", "paper2", "paper3", "paper4", "pop1", "pop2", 
			//	"scroll_rollup", "scroll_unroll", "swoosh", "click_double", "click_down", "click_up", ];
				
				//"bell", "card_single", "cards_shuffle", "bell", "card_single", "cards_shuffle", "bell", "card_single", "cards_shuffle", "bell", "card_single", "cards_shuffle", 
				//"bell", "card_single", "cards_shuffle", "bell", "card_single", "cards_shuffle", "bell", "card_single", "cards_shuffle", "bell", "card_single", "cards_shuffle", ];
			
			for each (var sound_name:String in _sound_names) {
				LoadSound(sound_name);
			}
		}
		
		public function LoadSound(soundName:String):void {
			var soundReference:Class = AssetManager[soundName] as Class;
			_sounds[soundName] = new WavSound(new soundReference() as ByteArray); 
			tr("loaded sound " + soundName);
		}
		
		public function PlaySound(soundName:String):void {
			if (_sounds[soundName] == null) {
				tr(" *** ERROR sound '" + soundName + "' not defined ***");
				return;
			}
			
			if (!FlxG.mute) {
				_sounds[soundName].play();
				//tr("played sound " + soundName);
			}
		}
		
	}

}