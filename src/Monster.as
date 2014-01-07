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
		
		public var _health:int = 1;
		public var _strength:int = 1;
		public var _speed:int = 1;
		public var _armour:int = 0;
		
		private var _playState:PlayState;
		
		public function Monster(playState:PlayState, type:String, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			_type = type;
			
			loadGraphic(charactersPNG, false, true, 24, 24);
			switch (_type) {
				case "Runty Goblin":
					_desc = "A small goblin. Not much of a threat..";
					addAnimation(_type, [157]);		
					_dread = 2;
					_health = 3;
					_strength = 1;
					_speed = 3;
					_armour = 0;
					break;
				case "Goblin Leader":
					_desc = "Bigger and meaner than the usual runt.";
					addAnimation(_type, [162]);
					_dread = 5;
					_health = 6;
					_strength = 4;
					_speed = 2;
					_armour = 2;
					break;
				case "Giant Bat":
					_desc = "Bats aren't scary. Unless they weigh more than you..";
					addAnimation(_type, [217]);
					_dread = 3;
					_health = 1;
					_strength = 2;
					_speed = 4;
					_armour = 0;
					break;
				case "Chicken":
					_desc = "*cluck* *cluck*\nHow did this get in here?";
					addAnimation(_type, [210]);
					_dread = 0;
					_health = 1;
					_strength = 0;
					_speed = 1;
					_armour = 0;
					break;
				case "Filthy Rat":
					_desc = "Nasty spreader of pestilence, and smelly too";
					addAnimation(_type, [213]);
					_dread = 1;
					_health = 2;
					_strength = 1;
					_speed = 1;
					_armour = 0;
					break;
				case "Skeleton":
					_desc = "Once a hoplite, always a hoplite";
					addAnimation(_type, [193]);
					_dread = 4;
					_health = 4;
					_strength = 3;
					_speed = 1;
					_armour = 2;
					break;
				default:
					throw new Error("no matching monster defined for " + _type);
			}
			play(_type);
		}
		
		public function GetStats():String {
			var stats:String = "";
			stats += "Health: " + _health + "\n";
			stats += "Strength: " + _strength + "\n";
			stats += "Speed: " + _speed + "\n";
			stats += "Armour: " + _armour + "\n";
			return stats;
		}
		

	}
}