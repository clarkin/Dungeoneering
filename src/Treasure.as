package 
{
	import org.flixel.*;
	
	public class Treasure extends FlxSprite
	{
		[Embed(source = "../assets/treasure_spritesheet.png")] private var itemsPNG:Class;
		
		public static const ICON_OFFSET:FlxPoint = new FlxPoint(10, 5);
		
		public static const ALL_TREASURES:Array = [
			"Silver Coins", "Gold Pouch", "Candlestick", "Sapphire Ring", "Massive Gem", 
			"Large Chest"];
		
		public var _type:String = "";
		public var _desc:String = "";
		public var _hope:Number = 0;
		
		private var _playState:PlayState;
		
		public function Treasure(playState:PlayState, type:String, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			_type = type;
			//trace("adding treasure " + type);
			
			loadGraphic(itemsPNG, false, true, 80, 80);
			switch (_type) {
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
				default:
					throw new Error("no matching treasure defined for " + _type);
			}
			play(_type);
		}

	}
}