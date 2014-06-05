package  
{
	import org.flixel.*;
	import org.as3wavsound.*;
	import flash.utils.ByteArray;
	
	public class AssetManager 
	{
		[Embed(source = "../assets/sfx/cheer.wav", mimeType = "application/octet-stream")] private const WAVcheer:Class;
		[Embed(source = "../assets/sfx/coins.wav", mimeType = "application/octet-stream")] private const WAVcoins:Class;
		[Embed(source = "../assets/sfx/deathscream.wav", mimeType = "application/octet-stream")] private const WAVdeathscream:Class;
		[Embed(source = "../assets/sfx/doorcreak.wav", mimeType = "application/octet-stream")] private const WAVdoorcreak:Class;
		[Embed(source = "../assets/sfx/footsteps.wav", mimeType = "application/octet-stream")] private const WAVfootsteps:Class;
		[Embed(source = "../assets/sfx/lots_of_coins.wav", mimeType = "application/octet-stream")] private const WAVlotsofcoins:Class;
		[Embed(source = "../assets/sfx/sword_kill.wav", mimeType = "application/octet-stream")] private const WAVswordkill:Class;
		[Embed(source = "../assets/sfx/demon_talk1.wav", mimeType = "application/octet-stream")] private const WAVdemontalk1:Class;
		[Embed(source = "../assets/sfx/demon_talk2.wav", mimeType = "application/octet-stream")] private const WAVdemontalk2:Class;
		[Embed(source = "../assets/sfx/dungeoneer_talk1.wav", mimeType = "application/octet-stream")] private const WAVdungeoneertalk1:Class;
		
		public var sndCheer:WavSound;
		public var sndCoins:WavSound;
		public var sndDeathscream:WavSound;
		public var sndDoorcreak:WavSound;
		public var sndFootsteps:WavSound;
		public var sndLotsofcoins:WavSound;
		public var sndSwordkill:WavSound;
		public var sndDemontalk1:WavSound;
		public var sndDemontalk2:WavSound;
		public var sndDungeoneertalk1:WavSound;
		
		private var _playState:PlayState;
		
		public function AssetManager(playState:PlayState) 
		{
			_playState = playState;
			
			sndCheer = new WavSound(new WAVcheer() as ByteArray);
			sndCoins = new WavSound(new WAVcoins() as ByteArray);
			sndDeathscream = new WavSound(new WAVdeathscream() as ByteArray);
			sndDoorcreak = new WavSound(new WAVdoorcreak() as ByteArray);
			sndFootsteps = new WavSound(new WAVfootsteps() as ByteArray);
			sndLotsofcoins = new WavSound(new WAVlotsofcoins() as ByteArray);
			sndSwordkill = new WavSound(new WAVswordkill() as ByteArray);
			sndDemontalk1 = new WavSound(new WAVdemontalk1() as ByteArray);
			sndDemontalk2 = new WavSound(new WAVdemontalk2() as ByteArray);
			sndDungeoneertalk1 = new WavSound(new WAVdungeoneertalk1() as ByteArray);
			
		}
		
	}

}