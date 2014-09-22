package  
{
	import org.flixel.*;
	import org.as3wavsound.*;
	import flash.utils.*;
	
	public class AssetManager 
	{
		[Embed(source = "../assets/sfx/ui/bell.wav", mimeType = "application/octet-stream")] private static const bell:Class;
		[Embed(source = "../assets/sfx/ui/bling.wav", mimeType = "application/octet-stream")] private static const bling:Class;
		[Embed(source = "../assets/sfx/ui/card_single.wav", mimeType = "application/octet-stream")] private static const card_single:Class;
		[Embed(source = "../assets/sfx/ui/cards_shuffle.wav", mimeType = "application/octet-stream")] private static const cards_shuffle:Class;
		[Embed(source = "../assets/sfx/ui/cheer.wav", mimeType = "application/octet-stream")] private static const cheer:Class;
		[Embed(source = "../assets/sfx/ui/click_double.wav", mimeType = "application/octet-stream")] private static const click_double:Class;
		[Embed(source = "../assets/sfx/ui/click_down.wav", mimeType = "application/octet-stream")] private static const click_down:Class;
		[Embed(source = "../assets/sfx/ui/click_up.wav", mimeType = "application/octet-stream")] private static const click_up:Class;
		[Embed(source = "../assets/sfx/ui/deathscream.wav", mimeType = "application/octet-stream")] private static const deathscream:Class;
		[Embed(source = "../assets/sfx/ui/dice1.wav", mimeType = "application/octet-stream")] private static const dice1:Class;
		[Embed(source = "../assets/sfx/ui/dice2.wav", mimeType = "application/octet-stream")] private static const dice2:Class;
		[Embed(source = "../assets/sfx/ui/paper1.wav", mimeType = "application/octet-stream")] private static const paper1:Class;
		[Embed(source = "../assets/sfx/ui/paper2.wav", mimeType = "application/octet-stream")] private static const paper2:Class;
		[Embed(source = "../assets/sfx/ui/paper3.wav", mimeType = "application/octet-stream")] private static const paper3:Class;
		[Embed(source = "../assets/sfx/ui/paper4.wav", mimeType = "application/octet-stream")] private static const paper4:Class;
		[Embed(source = "../assets/sfx/ui/pencil1.wav", mimeType = "application/octet-stream")] private static const pencil1:Class;
		[Embed(source = "../assets/sfx/ui/pencil2.wav", mimeType = "application/octet-stream")] private static const pencil2:Class;
		[Embed(source = "../assets/sfx/ui/pencil3.wav", mimeType = "application/octet-stream")] private static const pencil3:Class;
		[Embed(source = "../assets/sfx/ui/pencil4.wav", mimeType = "application/octet-stream")] private static const pencil4:Class;
		[Embed(source = "../assets/sfx/ui/pencil5.wav", mimeType = "application/octet-stream")] private static const pencil5:Class;
		[Embed(source = "../assets/sfx/ui/pencil6.wav", mimeType = "application/octet-stream")] private static const pencil6:Class;
		[Embed(source = "../assets/sfx/ui/pop1.wav", mimeType = "application/octet-stream")] private static const pop1:Class;
		[Embed(source = "../assets/sfx/ui/pop2.wav", mimeType = "application/octet-stream")] private static const pop2:Class;
		[Embed(source = "../assets/sfx/ui/scroll_rollup.wav", mimeType = "application/octet-stream")] private static const scroll_rollup:Class;
		[Embed(source = "../assets/sfx/ui/scroll_unroll.wav", mimeType = "application/octet-stream")] private static const scroll_unroll:Class;
		
		[Embed(source = "../assets/sfx/battle/attack_axe.wav", mimeType = "application/octet-stream")] private static const attack_axe:Class;
		[Embed(source = "../assets/sfx/battle/attack_bow.wav", mimeType = "application/octet-stream")] private static const attack_bow:Class;
		[Embed(source = "../assets/sfx/battle/attack_club.wav", mimeType = "application/octet-stream")] private static const attack_club:Class;
		[Embed(source = "../assets/sfx/battle/attack_knife.wav", mimeType = "application/octet-stream")] private static const attack_knife:Class;
		[Embed(source = "../assets/sfx/battle/attack_mace.wav", mimeType = "application/octet-stream")] private static const attack_mace:Class;
		[Embed(source = "../assets/sfx/battle/attack_staff.wav", mimeType = "application/octet-stream")] private static const attack_staff:Class;
		[Embed(source = "../assets/sfx/battle/attack_sword.wav", mimeType = "application/octet-stream")] private static const attack_sword:Class;
		[Embed(source = "../assets/sfx/battle/clash.wav", mimeType = "application/octet-stream")] private static const clash:Class;
		
		[Embed(source = "../assets/sfx/equipment/equip_axe.wav", mimeType = "application/octet-stream")] private static const equip_axe:Class;
		[Embed(source = "../assets/sfx/equipment/equip_bow.wav", mimeType = "application/octet-stream")] private static const equip_bow:Class;
		[Embed(source = "../assets/sfx/equipment/equip_buckler.wav", mimeType = "application/octet-stream")] private static const equip_buckler:Class;
		[Embed(source = "../assets/sfx/equipment/equip_chainmail.wav", mimeType = "application/octet-stream")] private static const equip_chainmail:Class;
		[Embed(source = "../assets/sfx/equipment/equip_cloth_hat.wav", mimeType = "application/octet-stream")] private static const equip_cloth_hat:Class;
		[Embed(source = "../assets/sfx/equipment/equip_club.wav", mimeType = "application/octet-stream")] private static const equip_club:Class;
		[Embed(source = "../assets/sfx/equipment/equip_coin_bag.wav", mimeType = "application/octet-stream")] private static const equip_coin_bag:Class;
		[Embed(source = "../assets/sfx/equipment/equip_coin_chest.wav", mimeType = "application/octet-stream")] private static const equip_coin_chest:Class;
		[Embed(source = "../assets/sfx/equipment/equip_coin_double.wav", mimeType = "application/octet-stream")] private static const equip_coin_double:Class;
		[Embed(source = "../assets/sfx/equipment/equip_coin_single.wav", mimeType = "application/octet-stream")] private static const equip_coin_single:Class;
		[Embed(source = "../assets/sfx/equipment/equip_great_shield.wav", mimeType = "application/octet-stream")] private static const equip_great_shield:Class;
		[Embed(source = "../assets/sfx/equipment/equip_horned_helm.wav", mimeType = "application/octet-stream")] private static const equip_horned_helm:Class;
		[Embed(source = "../assets/sfx/equipment/equip_knife.wav", mimeType = "application/octet-stream")] private static const equip_knife:Class;
		[Embed(source = "../assets/sfx/equipment/equip_leather_armour.wav", mimeType = "application/octet-stream")] private static const equip_leather_armour:Class;
		[Embed(source = "../assets/sfx/equipment/equip_leather_helm.wav", mimeType = "application/octet-stream")] private static const equip_leather_helm:Class;
		[Embed(source = "../assets/sfx/equipment/equip_mace.wav", mimeType = "application/octet-stream")] private static const equip_mace:Class;
		[Embed(source = "../assets/sfx/equipment/equip_platemail.wav", mimeType = "application/octet-stream")] private static const equip_platemail:Class;
		[Embed(source = "../assets/sfx/equipment/equip_potion.wav", mimeType = "application/octet-stream")] private static const equip_potion:Class;
		[Embed(source = "../assets/sfx/equipment/equip_robes.wav", mimeType = "application/octet-stream")] private static const equip_robes:Class;
		[Embed(source = "../assets/sfx/equipment/equip_scalemail.wav", mimeType = "application/octet-stream")] private static const equip_scalemail:Class;
		[Embed(source = "../assets/sfx/equipment/equip_silver_shield.wav", mimeType = "application/octet-stream")] private static const equip_silver_shield:Class;
		[Embed(source = "../assets/sfx/equipment/equip_staff.wav", mimeType = "application/octet-stream")] private static const equip_staff:Class;
		[Embed(source = "../assets/sfx/equipment/equip_staff_magic.wav", mimeType = "application/octet-stream")] private static const equip_staff_magic:Class;
		[Embed(source = "../assets/sfx/equipment/equip_sword.wav", mimeType = "application/octet-stream")] private static const equip_sword:Class;
		[Embed(source = "../assets/sfx/equipment/equip_winged_helm.wav", mimeType = "application/octet-stream")] private static const equip_winged_helm:Class;
		[Embed(source = "../assets/sfx/equipment/equip_wooden_shield.wav", mimeType = "application/octet-stream")] private static const equip_wooden_shield:Class;
		
		[Embed(source = "../assets/sfx/voice/male/angry1.wav", mimeType = "application/octet-stream")] private static const male_angry1:Class;
		[Embed(source = "../assets/sfx/voice/male/angry2.wav", mimeType = "application/octet-stream")] private static const male_angry2:Class;
		[Embed(source = "../assets/sfx/voice/male/bored1.wav", mimeType = "application/octet-stream")] private static const male_bored1:Class;
		[Embed(source = "../assets/sfx/voice/male/bored2.wav", mimeType = "application/octet-stream")] private static const male_bored2:Class;
		[Embed(source = "../assets/sfx/voice/male/confident.wav", mimeType = "application/octet-stream")] private static const male_confident:Class;
		[Embed(source = "../assets/sfx/voice/male/curious.wav", mimeType = "application/octet-stream")] private static const male_curious:Class;
		[Embed(source = "../assets/sfx/voice/male/excited.wav", mimeType = "application/octet-stream")] private static const male_excited:Class;
		[Embed(source = "../assets/sfx/voice/male/happy1.wav", mimeType = "application/octet-stream")] private static const male_happy1:Class;
		[Embed(source = "../assets/sfx/voice/male/happy2.wav", mimeType = "application/octet-stream")] private static const male_happy2:Class;
		[Embed(source = "../assets/sfx/voice/male/worried.wav", mimeType = "application/octet-stream")] private static const male_worried:Class;
		
		[Embed(source = "../assets/sfx/voice/demon/demon1.wav", mimeType = "application/octet-stream")] private static const demon1:Class;
		[Embed(source = "../assets/sfx/voice/demon/demon2.wav", mimeType = "application/octet-stream")] private static const demon2:Class;
		[Embed(source = "../assets/sfx/voice/demon/demon3.wav", mimeType = "application/octet-stream")] private static const demon3:Class;
		
		[Embed(source = "../assets/sfx/voice/monsters/bandito.wav", mimeType = "application/octet-stream")] private static const bandito:Class;
		[Embed(source = "../assets/sfx/voice/monsters/cyclops.wav", mimeType = "application/octet-stream")] private static const cyclops:Class;
		[Embed(source = "../assets/sfx/voice/monsters/ghost.wav", mimeType = "application/octet-stream")] private static const ghost:Class;
		[Embed(source = "../assets/sfx/voice/monsters/giant_bat.wav", mimeType = "application/octet-stream")] private static const giant_bat:Class;
		[Embed(source = "../assets/sfx/voice/monsters/goblin.wav", mimeType = "application/octet-stream")] private static const goblin:Class;
		[Embed(source = "../assets/sfx/voice/monsters/gray_ooze.wav", mimeType = "application/octet-stream")] private static const gray_ooze:Class;
		[Embed(source = "../assets/sfx/voice/monsters/mummy.wav", mimeType = "application/octet-stream")] private static const mummy:Class;
		[Embed(source = "../assets/sfx/voice/monsters/orc_grunt.wav", mimeType = "application/octet-stream")] private static const orc_grunt:Class;
		[Embed(source = "../assets/sfx/voice/monsters/rubber_ducky.wav", mimeType = "application/octet-stream")] private static const rubber_ducky:Class;
		[Embed(source = "../assets/sfx/voice/monsters/scary_spider.wav", mimeType = "application/octet-stream")] private static const scary_spider:Class; //TODO proper sound
		[Embed(source = "../assets/sfx/voice/monsters/skeleton.wav", mimeType = "application/octet-stream")] private static const skeleton:Class;
		[Embed(source = "../assets/sfx/voice/monsters/sorceress.wav", mimeType = "application/octet-stream")] private static const sorceress:Class;
		[Embed(source = "../assets/sfx/voice/monsters/zombie.wav", mimeType = "application/octet-stream")] private static const zombie:Class;
		
		[Embed(source = "../assets/music/dungeon_delvers.mp3")] private static const dungeon_delvers:Class;
		[Embed(source = "../assets/music/adventurers_tavern.mp3")] private static const adventurers_tavern:Class;
		[Embed(source = "../assets/music/final_synthasy.mp3")] private static const final_synthasy:Class;
		public var music_choices:Array = ["dungeon_delvers", "adventurers_tavern", "final_synthasy"];
		
		private var _playState:PlayState;
		
		public var _sounds:Array = new Array();
		public var _sound_names:Array = new Array();
		
		public function AssetManager(playState:PlayState) 
		{
			_playState = playState;
				
			_sound_names = ["bell", "bling", "card_single", "cards_shuffle", "cheer", "click_double", "click_down", "click_up", 
				"deathscream", "dice1", "dice2", "paper1", "paper2", "paper3", "paper4", "pencil1", "pencil2", "pencil3", "pencil4", 
				"pencil5", "pencil6", "pop1", "pop2", "scroll_rollup", "scroll_unroll",
				
				"attack_axe", "attack_bow", "attack_club", "attack_knife", "attack_mace", "attack_staff", "attack_sword", "clash",
				
				"equip_axe", "equip_bow", "equip_buckler", "equip_chainmail", "equip_cloth_hat", "equip_club", "equip_coin_bag", 
				"equip_coin_chest", "equip_coin_double", "equip_coin_single", "equip_great_shield", "equip_horned_helm", "equip_knife", 
				"equip_leather_armour", "equip_leather_helm", "equip_mace", "equip_platemail", "equip_potion", "equip_robes", 
				"equip_scalemail", "equip_silver_shield", "equip_staff", "equip_staff_magic", "equip_sword", "equip_winged_helm", 
				"equip_wooden_shield",
				
				"male_angry1", "male_angry2", "male_bored1", "male_bored2", "male_confident", "male_curious", "male_excited", 
				"male_happy1", "male_happy2", "male_worried",
				
				"demon1", "demon2", "demon3"];
				
			for each (var monster_type:String in Monster.ALL_MONSTERS) {
				var monster_sound:String = monster_type.replace(" ", "_").toLowerCase();
				_sound_names.push(monster_sound);
			}
			
			for each (var sound_name:String in _sound_names) {
				LoadSound(sound_name);
			}
		}
		
		public function LoadSound(soundName:String):void {
			var soundReference:Class = AssetManager[soundName] as Class;
			_sounds[soundName] = new WavSound(new soundReference() as ByteArray); 
			//tr("loaded sound " + soundName);
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
		
		public function StartMusic():void {
			StopMusic();
			var chosen_music_string:String = music_choices[Math.floor(Math.random() * music_choices.length)];
			var chosen_music:Class = AssetManager[chosen_music_string] as Class;
			FlxG.playMusic(chosen_music, 0.3);
			_playState.music_label.text = "\"" + chosen_music_string.replace("_", " ") + "\"";
			//tr("Now playing: " + chosen_music_string);
		}
		
		public function StopMusic():void {
			if (FlxG.music) {
				_playState.music_label.text = "";
				FlxG.music.stop();
			}
		}
		
	}

}