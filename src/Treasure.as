package 
{
	import org.flixel.*;
	
	public class Treasure extends FlxSprite
	{
		[Embed(source = "../assets/ass_item_tran.png")] private var itemsPNG:Class;
		
		public static const ICON_OFFSET:FlxPoint = new FlxPoint(10, 5);
		
		public static const ALL_TREASURES:Array = [
			"Silver Coins", "Small Chest", "Gold Coins", "Sapphire Ring", "Short Sword", 
			"Magic Axe", "Long Sword", "Wooden Shield", "Leather Vest"];
		
		public var _type:String = "";
		public var _desc:String = "";
		public var _hope:Number = 0;
		
		private var _playState:PlayState;
		
		public function Treasure(playState:PlayState, type:String, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			_type = type;
			
			loadGraphic(itemsPNG, false, true, 24, 24);
			switch (_type) {
				case "Silver Coins":
					_desc = "A handful of silver, strewn carelessly on the ground.";	
					addAnimation(_type, [84]);
					_hope = 0;
					break;
				case "Small Chest":
					_desc = "An ornate wooden chest. What might be inside?";	
					addAnimation(_type, [81]);
					_hope = 2;
					break;
				case "Gold Coins":
					_desc = "A small pile of coins, gleaming temptfully.";	
					addAnimation(_type, [83]);
					_hope = 1;
					break;
				case "Sapphire Ring":
					_desc = "A ring mounted with a huge sapphire, fit for a princess.";	
					addAnimation(_type, [74]);
					_hope = 4;
					break;
				case "Short Sword":
					_desc = "A dull sword about a foot long. Easy to use but without much reach.";
					addAnimation(_type, [6]);
					_hope = 0;
					break;
				case "Magic Axe":
					_desc = "This axe gleams and shines in the darkness with an inner fire.";
					addAnimation(_type, [17]);
					_hope = 5;
					break;
				case "Long Sword":
					_desc = "The classic, versatile weapon. Perhaps a little boring.";
					addAnimation(_type, [0]);
					_hope = 2;
					break;
				case "Wooden Shield":
					_desc = "A solid weight of wood to fend off a few blows.";
					addAnimation(_type, [41]);
					_hope = 1;
					break;
				case "Leather Vest":
					_desc = "Tight fitted leather for your midriff, not great but better than nothing.";
					addAnimation(_type, [48]);
					_hope = 0;
					break;
				default:
					throw new Error("no matching treasure defined for " + _type);
			}
			play(_type);
		}

	}
}