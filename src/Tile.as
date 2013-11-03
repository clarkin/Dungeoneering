package 
{
	import org.flixel.*;
	
	public class Tile extends FlxSprite
	{
		//[Embed(source = "../assets/dungeon_tiles.png")] private var dungeonTilesPNG:Class;
		[Embed(source = "../assets/tiles.png")] private var dungeonTilesPNG:Class;
		
		public static const TILESIZE:Number = 150;
		
		public static const ALL_TILES_OLD:Array = 
			["corr_dead1","corr_dead2","corr_dead3","corr_dead4","corr_left1","corr_left2","corr_left3","corr_left4", 
			 "corr_junction1","corr_junction2","corr_junction3","corr_junction4","corr_straight1","corr_straight2","corr_fourway","highlight",
			 "room_dead1", "room_dead2", "room_dead3", "room_dead4", "room_left1", "room_left2", "room_left3", "room_left4",
			 "room_junction1", "room_junction2", "room_junction3", "room_junction4", "room_straight1", "room_straight2", "room_fourway", "hint_treasure_room",
			 "empty", "room_treasure"];
		
		public static const ALL_TILES:Array = 
			["corr_fat_nesw", "corr_well_nesw", "corr_thin_nesw", "corr_hatch_nesw", "corr_carpet_ns",
			 "corr_rubble_ew", "corr_rubble_ns", "corr_bridge_ew", "corr_bridge_ns", "corr_regular_ew",
			 "corr_regular_ns", "corr_pit_nsw", "corr_pit_esw", "corr_pit_nes", "corr_pit_new",
			 "corr_regular_nsw", "corr_regular_esw", "corr_regular_nes", "corr_regular_new", "corr_crushed_nw",
			 "corr_crushed_sw", "corr_crushed_es", "corr_crushed_ne", "corr_curved_nw", "corr_curved_sw",
			 "corr_curved_es", "corr_curved_ne", "corr_grate_w", "corr_grate_s", "corr_grate_e",
			 "corr_grate_n", "corr_rubble_w", "corr_rubble_s", "corr_rubble_e", "corr_rubble_n",
			 "room_skeleton_nesw",
			 "empty", "highlight"];
			 
		public static const NORTH:int = 1;
		public static const EAST:int  = 2;
		public static const SOUTH:int = 4;
		public static const WEST:int  = 8;
		
		public static const FLASH_SPEED:Number = 2;
		
		public var entry_north:Boolean = false;
		public var entry_east:Boolean = false;
		public var entry_south:Boolean = false;
		public var entry_west:Boolean = false;
		
		public var highlight_entrance:int;
		
		public var type:String = "";
		public var flashing:Boolean = false;
		
		public static const TREASURE_CHANCE:Array = [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 3];
		public static const MONSTER_CHANCE:Array =  [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2];
		
		private static const ICON_OFFSET:FlxPoint = new FlxPoint(80, 45);
		public var cards:Array = new Array();
		
		private var _playState:PlayState;
		
		public function Tile(playState:PlayState, type:String, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			
			loadGraphic(dungeonTilesPNG, true, false, TILESIZE, TILESIZE);
			for (var i:int = 0; i < ALL_TILES.length; i++) {
				addAnimation(ALL_TILES[i], [i]);
			}
			
			if (type.indexOf("corr_") != -1 || type.indexOf("room_") != -1) {			
				var exits:String = type.substring(type.lastIndexOf("_") + 1, type.length);
				trace("type: " + type + ", exits: " + exits);
				
				if (exits.indexOf("n") != -1) {
					entry_north = true;
				}
				if (exits.indexOf("e") != -1) {
					entry_east = true;
				}
				if (exits.indexOf("s") != -1) {
					entry_south = true;
				}
				if (exits.indexOf("w") != -1) {
					entry_west = true;
				}
			}
			
			this.type = type;
			play(type);
			
			if (type == "highlight") {
				flashing = true;
				//alpha = 1 - Math.random() / 2; //between 0.5 and 1.0
			}
		}
		
		override public function update():void {	
			if (flashing) {
				alpha -= FlxG.elapsed / FLASH_SPEED;
				if (alpha < 0.5) {
					alpha = 1;
				}
			} else {
				alpha = 1;
			}
			
			super.update();
		}
		
		override public function draw():void {	
			super.draw();
			
			//TODO: is this really the best way to do this?
			for each (var card:Card in this.cards) {
				if (card._sprite != null) {
					card._sprite.draw();
				}
				if (card._monster != null) {
					card._monster.draw();
				}
			}
		}
		
		public function validForCard(card:Card):Boolean {
			var validity:Boolean = false;
			if (validEntrances().length > 0 && cards.length == 0) {
				validity = true;
			}
			
			return validity;
		}
		
		public function addCard(card:Card):void {
			//copy of given card
			var newCard:Card = new Card(_playState, this.x, this.y, card._type, card._title, null, card._monster);
			if (newCard._sprite != null) {
				newCard._sprite.x = this.x + ICON_OFFSET.x;
				newCard._sprite.y = this.y + ICON_OFFSET.y;
			}
			if (newCard._monster != null) {
				newCard._monster.x = this.x + ICON_OFFSET.x;
				newCard._monster.y = this.y + ICON_OFFSET.y;
			}
			//trace("added card " + newCard._type + ":" + newCard._title + " to tile " + this.type);
			this.cards.push(newCard);
		}
		
		public function countCards(type:String):int {
			var total:int = 0;
			for each (var card:Card in cards) {
				if (card._type == type) {
					total++;
				}
			}
			return total;
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
		
		public function getTileCoordsThroughExit(direction:int):FlxPoint {
			switch (direction) {
				case NORTH:
					return new FlxPoint(this.x, this.y - TILESIZE);
				case EAST:
					return new FlxPoint(this.x + TILESIZE, this.y);
				case SOUTH:
					return new FlxPoint(this.x, this.y + TILESIZE);
				case WEST:
					return new FlxPoint(this.x - TILESIZE, this.y);
				default:
					throw new Error("invalid direction " + direction);
			}
		}
		
		public static function directionName(direction:int):String {
			switch (direction) {
				case NORTH:
					return "SOUTH";
				case EAST:
					return "WEST";
				case SOUTH:
					return "NORTH";
				case WEST:
					return "EAST";
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