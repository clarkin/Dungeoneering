package 
{
	import org.flixel.*;
	
	public class Treasure extends FlxSprite
	{
		[Embed(source = "../assets/treasure_spritesheet_80px_COLOUR.png")] private var itemsPNG:Class;
		[Embed(source = "../assets/treasure_spritesheet_80px_WHITE.png")] private var itemsWhitePNG:Class;
				
		public static const ICON_OFFSET:FlxPoint = new FlxPoint(10, 5);
		public static const SPRITE_SIZE:int = 80;
		
		public static const ALL_TREASURES:Array = [
			"Gold Coin", "Silver Coins", "Gold Pouch", "Candlestick", "Sapphire Ring", "Massive Gem", 
			"Large Chest", "Leather Cap", "Spiked Helm", "Winged Fury"];
		
		public var _type:String = "";
		public var _desc:String = "";
		public var _hope:Number = 0;
		public var _equippable_type:String = "";
		public var _equippable_strength:int = 0;
		public var _equippable_speed:int = 0;
		public var _equippable_armour:int = 0;
		public var _equippables_frame:int = 0;
		
		private var _playState:PlayState;
		
		public function Treasure(playState:PlayState, type:String, colour:Boolean = true, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			_type = type;
			//trace("adding treasure " + type);
			
			if (colour) {
				loadGraphic(itemsPNG, false, true, SPRITE_SIZE, SPRITE_SIZE);
			} else {
				loadGraphic(itemsWhitePNG, false, true, SPRITE_SIZE, SPRITE_SIZE);
			}
			
			switch (_type) {
				case "Gold Coin":
					_desc = "A single coin lying in the dirt";	
					addAnimation(_type, [0]);
					_hope = 0;
					break;
				case "Silver Coins":
					_desc = "A handful of silver scattered aground";	
					addAnimation(_type, [1]);
					_hope = 0;
					break;
				case "Gold Pouch":
					_desc = "A pouch bulging with coins";	
					addAnimation(_type, [2]);
					_hope = 1;
					break;
				case "Candlestick":
					_desc = "Does this match the set we have in the guild?";	
					addAnimation(_type, [3]);
					_hope = 2;
					break;
				case "Sapphire Ring":
					_desc = "Mounted with a huge sapphire, fit for a princess";	
					addAnimation(_type, [4]);
					_hope = 3;
					break;
				case "Massive Gem":
					_desc = "A gem as big as your head. Gotta have it!";
					addAnimation(_type, [5]);
					_hope = 5;
					break;
				case "Large Chest":
					_desc = "A heavy wooden chest. What could be inside?";
					addAnimation(_type, [6]);
					_hope = 4;
					break;
				case "Leather Cap":
					_desc = "A simple leather cap. Might warm you up.";
					addAnimation(_type, [7]);
					_hope = 1;
					_equippable_type = "helmet";
					_equippable_armour = 1;
					_equippables_frame = 11;
					break;
				case "Spiked Helm":
					_desc = "Spiky. Menacing. Stylish!";
					addAnimation(_type, [8]);
					_hope = 2;
					_equippable_type = "helmet";
					_equippable_armour = 2;
					_equippables_frame = 12;
					break;
				case "Winged Fury":
					_desc = "It gleams in the dark. Could it be magical?";
					addAnimation(_type, [9]);
					_hope = 4;
					_equippable_type = "helmet";
					_equippable_armour = 2;
					_equippable_speed = 1;
					_equippables_frame = 13;
					break;
				default:
					throw new Error("no matching treasure defined for " + _type);
			}
			play(_type);
		}

	}
}