package 
{
	import org.flixel.*;
	
	public class Monster extends FlxSprite
	{
		[Embed(source = "../assets/ass_char_tran.png")] private var charactersPNG:Class;
		
		public static const ICON_OFFSET:FlxPoint = new FlxPoint(10, 5);
		
		public static const ALL_MONSTERS:Array = [
			"Runty Goblin", "Goblin Leader", "Giant Bat", "Chicken", "Filthy Rat", "Skeleton"];
		
		public var _type:String = "";
		public var _desc:String = "";
		public var _dread:Number = 0;
		
		private var _playState:PlayState;
		
		public function Monster(playState:PlayState, type:String, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			_type = type;
			
			loadGraphic(charactersPNG, false, true, 24, 24);
			switch (_type) {
				case "Runty Goblin":
					_desc = "A small goblin. Shouldn't be much of a threat for a tough adventurer..";
					addAnimation(_type, [157]);		
					_dread = 2;
					break;
				case "Goblin Leader":
					_desc = "Bigger and meaner than the usual runt.";
					addAnimation(_type, [162]);
					_dread = 5;
					break;
				case "Giant Bat":
					_desc = "Bats aren't scary. Unless they weigh more than you..";
					addAnimation(_type, [217]);
					_dread = 3;
					break;
				case "Chicken":
					_desc = "*cluck* *cluck*\nHow did this get in here?";
					addAnimation(_type, [210]);
					_dread = 0;
					break;
				case "Filthy Rat":
					_desc = "Nasty spreader of pestilence, but no threat unless they swarm.";
					addAnimation(_type, [213]);
					_dread = 1;
					break;
				case "Skeleton":
					_desc = "Once a hoplite, always a hoplite.";
					addAnimation(_type, [193]);
					_dread = 4;
					break;
				default:
					throw new Error("no matching monster defined for " + _type);
			}
			play(_type);
		}
		

	}
}