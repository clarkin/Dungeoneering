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
		
		private var _playState:PlayState;
		
		public var _sounds:Array = new Array();
		public var _sound_names:Array = new Array();
		
		public function AssetManager(playState:PlayState) 
		{
			_playState = playState;
				
			_sound_names = ["bell", "card_single", "cards_shuffle", "click_double", "click_down", "click_up", "dice1", "dice2", 
				"paper1", "paper2", "paper3", "paper4", "pop1", "pop2", "scroll_rollup", "scroll_unroll", "swoosh",
				
				"attack_axe", "attack_bow", "attack_club", "attack_knife", "attack_mace", "attack_staff", "attack_sword", "clash",
				
				"equip_axe", "equip_bow", "equip_buckler", "equip_chainmail", "equip_cloth_hat", "equip_club", "equip_coin_bag", 
				"equip_coin_chest", "equip_coin_double", "equip_coin_single", "equip_great_shield", "equip_horned_helm", "equip_knife", 
				"equip_leather_armour", "equip_leather_helm", "equip_mace", "equip_platemail", "equip_potion", "equip_robes", 
				"equip_scalemail", "equip_silver_shield", "equip_staff", "equip_staff_magic", "equip_sword", "equip_winged_helm", 
				"equip_wooden_shield"];
			
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
		
	}

}