package 
{
	import org.flixel.*;
	
	public class Monster extends FlxSprite
	{
		[Embed(source = "../assets/monster_spritesheet.png")] private var charactersPNG:Class;
		
		public static const ICON_OFFSET:FlxPoint = new FlxPoint(10, 5);
		
		public static const ALL_MONSTERS:Array = [
			"Sorceress", "Skeleton", "Rubber Ducky", "Gray Ooze", "Mummy", "Zombie"];
		
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
			
			loadGraphic(charactersPNG, false, true, 80, 80);
			switch (_type) {
				case "Sorceress":
					_desc = "She's got a wand and she's not afraid to use it";
					addAnimation(_type, [0]);		
					_dread = 3;
					_health = 2;
					_strength = 5;
					_speed = 3;
					_armour = 0;
					break;
				case "Skeleton":
					_desc = "Once a hoplite, always a hoplite";
					addAnimation(_type, [1]);
					_dread = 4;
					_health = 2;
					_strength = 3;
					_speed = 1;
					_armour = 2;
					break;
				case "Rubber Ducky":
					_desc = "OK this doesn't look dangerous AT ALL";
					addAnimation(_type, [2]);
					_dread = 0;
					_health = 1;
					_strength = 0;
					_speed = 1;
					_armour = 0;
					break;
				case "Gray Ooze":
					_desc = "Gloopy stains on your armour a guarantee";
					addAnimation(_type, [3]);
					_dread = 1;
					_health = 4;
					_strength = 1;
					_speed = 1;
					_armour = 1;
					break;
				case "Mummy":
					_desc = "Never ever caught without any toilet paper";
					addAnimation(_type, [4]);
					_dread = 5;
					_health = 6;
					_strength = 3;
					_speed = 1;
					_armour = 2;
					break;
				case "Zombie":
					_desc = "*groan* *drool*\nI waaas like you .. once";
					addAnimation(_type, [5]);
					_dread = 2;
					_health = 3;
					_strength = 2;
					_speed = 1;
					_armour = 0;
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