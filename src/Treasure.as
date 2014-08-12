package 
{
	import org.flixel.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class Treasure extends FlxSprite
	{
		[Embed(source = "../assets/treasure_spritesheet_80px_COLOUR.png")] private var itemsPNG:Class;
		[Embed(source = "../assets/treasure_spritesheet_80px_WHITE.png")] private var itemsWhitePNG:Class;
		[Embed(source = "../assets/treasure_spritesheet_120px_COLOUR.png")] private var itemsLargePNG:Class;
		[Embed(source = "../assets/treasure_spritesheet_120px_WHITE.png")] private var itemsLargeWhitePNG:Class;
				
		public static const ICON_OFFSET:FlxPoint = new FlxPoint(10, 5);
		public var SPRITE_SIZE:int = 80;
		
		public static const ALL_TREASURES:Array = [
			"Gold Coin", "Silver Coins", "Gold Pouch", "Candlestick", "Sapphire Ring", "Massive Gem", 
			"Large Chest", "Leather Cap", "Spiked Helm", "Winged Fury", "Scale Mail", "Chainmail", "Breastplate",
			"Wood Shield", "Buckler", "Silver Shield", "Greatshield", "Club", "Spiked Mace", "Sword", "Battle Axe"];
		
		public var _type:String = "";
		public var _desc:String = "";
		public var _hope:Number = 0;
		public var _equippable_type:String = "";
		public var _equippable_strength:int = 0;
		public var _equippable_speed:int = 0;
		public var _equippable_armour:int = 0;
		public var _equippables_frame:int = 0;
		public var _equip_noise:String = "leather_helm";
		
		private var _playState:PlayState;
		
		public function Treasure(playState:PlayState, type:String, colour:Boolean = true, large:Boolean = false, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			_type = type;
			//tr("adding treasure " + type);
			
			if (large) {
				SPRITE_SIZE = 120;
			}
			
			if (colour) {
				if (large) {
					loadGraphic(itemsLargePNG, false, true, SPRITE_SIZE, SPRITE_SIZE);
				} else {
					loadGraphic(itemsPNG, false, true, SPRITE_SIZE, SPRITE_SIZE);
				}
			} else {
				if (large) {
					loadGraphic(itemsLargeWhitePNG, false, true, SPRITE_SIZE, SPRITE_SIZE);
				} else {
					loadGraphic(itemsWhitePNG, false, true, SPRITE_SIZE, SPRITE_SIZE);
				}
			}
			
			switch (_type) {
				case "Gold Coin":
					_desc = "A single coin lying in the dirt";	
					_equip_noise = "equip_coin_single";
					addAnimation(_type, [0]);
					_hope = 0;
					break;
				case "Silver Coins":
					_desc = "A handful of silver scattered aground";	
					_equip_noise = "equip_coin_double";
					addAnimation(_type, [1]);
					_hope = 0;
					break;
				case "Gold Pouch":
					_desc = "A pouch bulging with coins";	
					_equip_noise = "equip_coin_bag";
					addAnimation(_type, [2]);
					_hope = 1;
					break;
				case "Candlestick":
					_desc = "Does this match the set we have in the guild?";	
					_equip_noise = "equip_staff";
					addAnimation(_type, [3]);
					_hope = 2;
					break;
				case "Sapphire Ring":
					_desc = "Mounted with a huge sapphire, fit for a princess";	
					_equip_noise = "bell";
					addAnimation(_type, [4]);
					_hope = 3;
					break;
				case "Massive Gem":
					_desc = "A gem as big as your head. Gotta have it!";
					_equip_noise = "bell";
					addAnimation(_type, [5]);
					_hope = 5;
					break;
				case "Large Chest":
					_desc = "A heavy wooden chest. What could be inside?";
					_equip_noise = "equip_coin_chest";
					addAnimation(_type, [6]);
					_hope = 4;
					break;
				case "Leather Cap":
					_desc = "A simple leather cap. Might warm you up.";
					_equip_noise = "equip_leather_helm";
					addAnimation(_type, [7]);
					_hope = 1;
					_equippable_type = "helmet";
					_equippable_armour = 1;
					_equippables_frame = 11;
					break;
				case "Spiked Helm":
					_desc = "Spiky. Menacing. Stylish!";
					_equip_noise = "equip_horned_helm";
					addAnimation(_type, [8]);
					_hope = 2;
					_equippable_type = "helmet";
					_equippable_strength = 1;
					_equippable_armour = 1;
					_equippables_frame = 12;
					break;
				case "Winged Fury":
					_desc = "It gleams in the dark. Could it be magical?";
					_equip_noise = "equip_winged_helm";
					addAnimation(_type, [9]);
					_hope = 4;
					_equippable_type = "helmet";
					_equippable_armour = 1;
					_equippable_speed = 1;
					_equippables_frame = 13;
					break;
				case "Scale Mail":
					_desc = "Layered scales. Works for dragons, right?";
					_equip_noise = "equip_scalemail";
					addAnimation(_type, [10]);
					_hope = 2;
					_equippable_type = "armour";
					_equippable_armour = 2;
					_equippable_speed = -1;
					_equippables_frame = 15;
					break;
				case "Chainmail":
					_desc = "A shirt of linked rings. Seems comfortable";
					_equip_noise = "equip_chainmail";
					addAnimation(_type, [11]);
					_hope = 3;
					_equippable_type = "armour";
					_equippable_armour = 2;
					_equippables_frame = 16;
					break;
				case "Breastplate":
					_desc = "Awkward, but looks like it will keep you safe";
					_equip_noise = "equip_platemail";
					addAnimation(_type, [12]);
					_hope = 4;
					_equippable_type = "armour";
					_equippable_armour = 3;
					_equippable_speed = -1;
					_equippables_frame = 17;
					break;
				case "Wood Shield":
					_desc = "Better than nothing.. maybe";
					_equip_noise = "equip_wooden_shield";
					addAnimation(_type, [13]);
					_hope = 0;
					_equippable_type = "shield";
					_equippable_armour = 1;
					_equippable_strength = -1;
					_equippables_frame = 18;
					break;
				case "Buckler":
					_desc = "Buckles onto your arm, not under pressure!";
					_equip_noise = "equip_buckler";
					addAnimation(_type, [14]);
					_hope = 1;
					_equippable_type = "shield";
					_equippable_armour = 1;
					_equippables_frame = 19;
					break;
				case "Silver Shield":
					_desc = "Shines with a bright inner light";
					_equip_noise = "equip_silver_shield";
					addAnimation(_type, [15]);
					_hope = 4;
					_equippable_type = "shield";
					_equippable_armour = 2;
					_equippable_strength = 1;
					_equippables_frame = 20;
					break;
				case "Greatshield":
					_desc = "A huge shield. Can you lift it?";
					_equip_noise = "equip_great_shield";
					addAnimation(_type, [16]);
					_hope = 3;
					_equippable_type = "shield";
					_equippable_armour = 3;
					_equippable_speed = -2;
					_equippables_frame = 21;
					break;
				case "Club":
					_desc = "A heavy wooden club. ME SMASH NOW!";
					_equip_noise = "equip_club";
					addAnimation(_type, [17]);
					_hope = 1;
					_equippable_type = "weapon";
					_equippable_strength = 2;
					_equippable_speed = -2;
					_equippables_frame = 22;
					break;
				case "Spiked Mace":
					_desc = "Spiky metal on a stick";
					_equip_noise = "equip_mace";
					addAnimation(_type, [18]);
					_hope = 2;
					_equippable_type = "weapon";
					_equippable_strength = 2;
					_equippable_speed = -1;
					_equippables_frame = 23;
					break;
				case "Sword":
					_desc = "Simple. Effective. BORING";
					_equip_noise = "equip_sword";
					addAnimation(_type, [19]);
					_hope = 2;
					_equippable_type = "weapon";
					_equippable_strength = 2;
					_equippables_frame = 24;
					break;
				case "Battle Axe":
					_desc = "Time to CLEAVE them to pieces!";
					_equip_noise = "equip_axe";
					addAnimation(_type, [20]);
					_hope = 4;
					_equippable_type = "weapon";
					_equippable_strength = 4;
					_equippable_armour = -1;
					_equippables_frame = 25;
					break;
				default:
					throw new Error("no matching treasure defined for " + _type);
			}
			play(_type);
		}

	}
}