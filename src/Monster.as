package 
{
	import org.flixel.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class Monster extends FlxSprite
	{
		[Embed(source = "../assets/monster_spritesheet_80px_COLOUR.png")] private var charactersPNG:Class;
		[Embed(source = "../assets/monster_spritesheet_80px_WHITE.png")] private var charactersWhitePNG:Class;
		
		public static const ICON_OFFSET:FlxPoint = new FlxPoint(10, 5);
		public static const SPRITE_SIZE:int = 80;
		
		public static const ALL_MONSTERS:Array = [
			"Sorceress", "Skeleton", "Rubber Ducky", "Gray Ooze", "Mummy", "Zombie", "Bandito", "Cyclops",
			"Orc Grunt", "Ghost", "Giant Bat", "Scary Spider", "Goblin"];
		
		public var _type:String = "";
		public var _desc:String = "";
		public var _dread:Number = 0;
		
		public var _health:int = 1;
		public var _strength:int = 1;
		public var _speed:int = 1;
		public var _armour:int = 0;
		
		private var _playState:PlayState;
		
		public function Monster(playState:PlayState, type:String, colour:Boolean = true, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			_type = type;
			
			if (colour) {
				loadGraphic(charactersPNG, false, true, SPRITE_SIZE, SPRITE_SIZE);
			} else {
				loadGraphic(charactersWhitePNG, false, true, SPRITE_SIZE, SPRITE_SIZE);
			}
			
			switch (_type) {
				case "Sorceress":
					_desc = "She's got a wand and she's not afraid to use it";
					addAnimation(_type, [0]);		
					_dread = 3;
					_health = 3;
					_strength = 5;
					_speed = 4;
					_armour = 0;
					break;
				case "Skeleton":
					_desc = "Once a hoplite, always a hoplite";
					addAnimation(_type, [1]);
					_dread = 3;
					_health = 5;
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
					_dread = 4;
					_health = 8;
					_strength = 3;
					_speed = 1;
					_armour = 2;
					break;
				case "Zombie":
					_desc = "*groan* *drool*\nI waaas like you .. once";
					addAnimation(_type, [5]);
					_dread = 2;
					_health = 6;
					_strength = 1;
					_speed = 1;
					_armour = 0;
					break;
				case "Bandito":
					_desc = "¡La bolsa o la vida!";
					addAnimation(_type, [6]);
					_dread = 3;
					_health = 4;
					_strength = 4;
					_speed = 4;
					_armour = 1;
					break;
				case "Cyclops":
					_desc = "I spy with my little eye.. FOOD";
					addAnimation(_type, [7]);
					_dread = 5;
					_health = 10;
					_strength = 6;
					_speed = 1;
					_armour = 0;
					break;
				case "Fire Demon":
					_desc = "OW! This card is burning hot!";
					addAnimation(_type, [8]);
					_dread = 5;
					_health = 10;
					_strength = 8;
					_speed = 3;
					_armour = 3;
					break;
				case "Ghost":
					_desc = "BOO! Hey - were you scared?";
					addAnimation(_type, [11]);
					_dread = 2;
					_health = 2;
					_strength = 2;
					_speed = 4;
					_armour = 3;
					break;
				case "Giant Bat":
					_desc = "I'm not a vampire, leave me alone!";
					addAnimation(_type, [12]);
					_dread = 1;
					_health = 2;
					_strength = 2;
					_speed = 3;
					_armour = 0;
					break;
				case "Scary Spider":
					_desc = "Woah - EIGHT dungeoneers!";
					addAnimation(_type, [13]);
					_dread = 3;
					_health = 4;
					_strength = 3;
					_speed = 4;
					_armour = 1;
					break;
				case "Goblin":
					_desc = "Welcome to da club. Hehe geddit?";
					addAnimation(_type, [15]);
					_dread = 2;
					_health = 4;
					_strength = 3;
					_speed = 2;
					_armour = 0;
					break;
				case "Orc Grunt":
					_desc = "ORCZ iz da best! *sigh* Must I do the voice?";
					addAnimation(_type, [19]);
					_dread = 4;
					_health = 7;
					_strength = 4;
					_speed = 2;
					_armour = 2;
					break;
				case "Fire Demon":
					_desc = "OW! This card is burning hot!";
					addAnimation(_type, [8]);
					_dread = 5;
					_health = 12;
					_strength = 8;
					_speed = 4;
					_armour = 4;
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
		
		public function GetStatsNumbers():String {
			var stats:String = "";
			stats += _health + "\n";
			stats += _strength + "\n";
			stats += _speed + "\n";
			stats += _armour + "\n";
			return stats;
		}
	}
}