package 
{
	import org.flixel.*;
	
	public class Tile extends FlxSprite
	{
		[Embed(source = "../assets/dungeon_tiles.png")] private var dungeonTilesPNG:Class;
		
		public static const TILESIZE:Number = 42;
		
		public static const ALL_TILES:Array = 
			["corr_dead1","corr_dead2","corr_dead3","corr_dead4","corr_left1","corr_left2","corr_left3","corr_left4", 
			 "corr_junction1","corr_junction2","corr_junction3","corr_junction4","corr_straight1","corr_straight2","corr_fourway","highlight",
			 "room_dead1", "room_dead2", "room_dead3", "room_dead4", "room_left1", "room_left2", "room_left3", "room_left4",
			 "room_junction1", "room_junction2", "room_junction3", "room_junction4", "room_straight1", "room_straight2", "room_fourway", "hint_treasure_room",
			 "empty", "room_treasure"];
			 
		public static const NORTH:int = 1;
		public static const EAST:int  = 2;
		public static const SOUTH:int = 4;
		public static const WEST:int  = 8;
		
		public var entry_north:Boolean = false;
		public var entry_east:Boolean = false;
		public var entry_south:Boolean = false;
		public var entry_west:Boolean = false;
		
		public var highlight_entrance:int;
		
		public var type:String = "";
		public var treasure_cards:int = 0;
		public var monster_cards:int = 0;
		
		public static const TREASURE_CHANCE:Array = [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 3];
		public static const MONSTER_CHANCE:Array =  [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2];
		
		private static const ICON_OFFSET:FlxPoint = new FlxPoint(10, 5);
		public var cards:Array = new Array();
		
		public function Tile(type:String, X:int = 0, Y:int = 0) 
		{
			super(X,Y);
			
			loadGraphic(dungeonTilesPNG, true, false, TILESIZE, TILESIZE);
			for (var i:int = 0; i < ALL_TILES.length; i++) {
				addAnimation(ALL_TILES[i], [i]);
			}
			
			switch (type) {
				case "empty":
				case "highlight":
				case "hint_treasure_room":
					break;
				case "corr_dead1":
				case "room_dead1":
					entry_north = true;
					break;
				case "corr_dead2":
				case "room_dead2":
					entry_east = true;
					break;
				case "corr_dead3":
				case "room_dead3":
					entry_south = true;
					break;
				case "corr_dead4":
				case "room_dead4":
					entry_west = true;
					break;
				case "corr_left1":
				case "room_left1":
					entry_north = true;
					entry_east = true;
					break;
				case "corr_left2":
				case "room_left2":
					entry_east = true;
					entry_south = true;
					break;
				case "corr_left3":
				case "room_left3":
					entry_south = true;
					entry_west = true;
					break;
				case "corr_left4":
				case "room_left4":
					entry_west = true;
					entry_north = true;
					break;
				case "corr_junction1":
				case "room_junction1":
					entry_north = true;
					entry_east = true;
					entry_west = true;
					break;
				case "corr_junction2":
				case "room_junction2":
					entry_east = true;
					entry_south = true;
					entry_north = true;
					break;
				case "corr_junction3":
				case "room_junction3":
					entry_south = true;
					entry_west = true;
					entry_east = true;
					break;
				case "corr_junction4":
				case "room_junction4":
					entry_west = true;
					entry_north = true;
					entry_south = true;
					break;
				case "corr_straight1":
				case "room_straight1":
					entry_north = true;
					entry_south = true;
					break;
				case "corr_straight2":
				case "room_straight2":
					entry_east = true;
					entry_west = true;
					break;
				case "corr_fourway":
				case "room_fourway":
				case "room_treasure":
					entry_east = true;
					entry_west = true;
					entry_north = true;
					entry_south = true;
					break;
				default:
					throw new Error("no matching tile type defined for " + type);
			}
			
			if (type.indexOf("room") == 0) {
				treasure_cards = TREASURE_CHANCE[Math.floor(Math.random() * (TREASURE_CHANCE.length))];
				monster_cards = MONSTER_CHANCE[Math.floor(Math.random() * (MONSTER_CHANCE.length))];
			}
			
			this.type = type;
			play(type);
		}
		
		override public function update():void {	
			super.update();
		}
		
		override public function draw():void {	
			super.draw();
			
			for each (var card:Card in this.cards) {
				card._sprite.draw();
			}
		}
		
		public function addCard(card:Card):void {
			//copy of given card
			var newCard:Card = new Card(this.x, this.y, card._type, card._title);
			newCard._sprite.x = this.x + ICON_OFFSET.x;
			newCard._sprite.y = this.y + ICON_OFFSET.y;
			//trace("added card " + newCard._type + ":" + newCard._title + " to tile " + this.type);
			this.cards.push(newCard);
		}
		
		public function validEntrances():Array {
			var valid_entrances:Array = new Array();
			if (this.entry_north)
				valid_entrances.push(NORTH);
			if (this.entry_east)
				valid_entrances.push(EAST);
			if (this.entry_south)
				valid_entrances.push(SOUTH);
			if (this.entry_west)
				valid_entrances.push(WEST);
			return valid_entrances;
		}
		
		public function checkExit(direction:int):Boolean {
			switch (direction) {
				case NORTH:
					return this.entry_north;
				case EAST:
					return this.entry_east;
				case SOUTH:
					return this.entry_south;
				case WEST:
					return this.entry_west;
				default:
					throw new Error("invalid direction " + direction);
			}
		}
		
		public static function oppositeDirection(direction:int):int {
			switch (direction) {
				case NORTH:
					return SOUTH;
				case EAST:
					return WEST;
				case SOUTH:
					return NORTH;
				case WEST:
					return EAST;
				default:
					throw new Error("invalid direction " + direction);
			}
		}
		
	}
}