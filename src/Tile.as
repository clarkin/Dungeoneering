package 
{
	import org.flixel.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class Tile extends FlxSprite
	{
		//[Embed(source = "../assets/dungeon_tiles.png")] private var dungeonTilesPNG:Class;
		[Embed(source = "../assets/tiles_150.png")] private var dungeonTilesLargePNG:Class;
		[Embed(source = "../assets/tiles_80.png")] private var dungeonTilesPNG:Class;
		
		public static const TILESIZE:Number = 150.0;
		
		public static const ALL_TILES:Array = 
			["corr_fat_nesw", "corr_well_nesw", "corr_thin_nesw", "corr_hatch_nesw", "corr_carpet_ns",
			 "corr_carpet_ew", "corr_rubble_ew", "corr_rubble_ns", "corr_bridge_ew", "corr_bridge_ns", 
			 "corr_regular_ew", "corr_regular_ns", "corr_pit_nsw", "corr_pit_esw", "corr_pit_nes", 
			 "corr_pit_new", "corr_regular_nsw", "corr_regular_esw", "corr_regular_nes", "corr_regular_new", 
			 "corr_crushed_nw", "corr_crushed_sw", "corr_crushed_es", "corr_crushed_ne", "corr_curved_nw", 
			 "corr_curved_sw", "corr_curved_es", "corr_curved_ne", "corr_grate_w", "corr_grate_s", 
			 "corr_grate_e", "corr_grate_n", "corr_rubble_w", "corr_rubble_s", "corr_rubble_e", 
			 "corr_rubble_n", "room_large_w", "room_large_s", "room_large_e", "room_large_n",
			 "room_round_w", "room_round_s", "room_round_e", "room_round_n", "room_waterfall_w",
			 "room_waterfall_s", "room_waterfall_e", "room_waterfall_n", "room_torture_w", "room_torture_s",
			 "room_torture_e", "room_torture_n", "room_pit_new", "room_pit_nsw", "room_pit_esw", 
			 "room_pit_nes", "room_semicircle_new", "room_semicircle_nsw", "room_semicircle_esw", "room_semicircle_nes", 
			 "room_hatch_new", "room_hatch_nsw", "room_hatch_esw", "room_hatch_nes", "room_collapse_new", 
			 "room_collapse_nsw", "room_collapse_esw", "room_collapse_nes", "room_beds_nw", "room_beds_sw", 
			 "room_beds_es", "room_beds_ne", "room_throne_nw", "room_throne_sw", "room_throne_se", 
			 "room_throne_ne", "room_cavern_nw", "room_cavern_sw", "room_cavern_es", "room_cavern_ne", 
			 "room_circle_ew", "room_circle_ns", "room_cages_ew", "room_cages_ns", "room_chasm_ew", 
			 "room_chasm_ns", "room_carpet_nesw", "room_steps_nesw", "room_well_nesw", "room_skeleton_nesw",
			 "empty", "highlight"];
			 
		public static const NORTH:int = 1;
		public static const EAST:int  = 2;
		public static const SOUTH:int = 4;
		public static const WEST:int  = 8;
		
		public static const FLASH_SPEED:Number = 2;
		public static const MONSTER_ICON_OFFSET:FlxPoint = new FlxPoint(50, 20);
		public static const TREASURE_ICON_OFFSET:FlxPoint = new FlxPoint(20, 50);
		
		public var entry_north:Boolean = false;
		public var entry_east:Boolean = false;
		public var entry_south:Boolean = false;
		public var entry_west:Boolean = false;
		
		public var highlight_entry_north:Boolean = false;
		public var highlight_entry_east:Boolean = false;
		public var highlight_entry_south:Boolean = false;
		public var highlight_entry_west:Boolean = false;
		
		public var type:String = "";
		public var flashing:Boolean = false;
		public var has_visited:Boolean = true;
		public var cards:Array = new Array();
		
		public var g:Number = 0;
		public var h:Number = 0;
		public var f:Number = 0;
		public var pathingParent:Tile;
		public var pathToThis:Array;
		
		public var distance_to_hero:Number = 0;
		public var treasure_value:Number = 0;
		public var unexplored_area_value:Number = 0;
		public var monsters_between:Number = 0;
		public var weighted_value:Number = 0;
		
		public var debug_text:String = "";
		public var debug_text_holder:FlxText;
		
		private var _playState:PlayState;
		
		public function Tile(playState:PlayState, type:String, large:Boolean = true, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			
			var actual_tilesize:Number = TILESIZE;
			if (large) {
				loadGraphic(dungeonTilesLargePNG, true, false, actual_tilesize, actual_tilesize);
			} else {
				actual_tilesize = 80;
				loadGraphic(dungeonTilesPNG, true, false, actual_tilesize, actual_tilesize);
			}
			
			for (var i:int = 0; i < ALL_TILES.length; i++) {
				addAnimation(ALL_TILES[i], [i]);
			}
			
			if (type.indexOf("corr_") != -1 || type.indexOf("room_") != -1) {			
				var exits:String = type.substring(type.lastIndexOf("_") + 1, type.length);
				//tr("added tile of type: " + type + ", exits: " + exits);
				
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
			
			if (type != "highlight" && type != "empty") { //TODO don't add these unless FlxG.debug is true
				debug_text_holder = new FlxText(X, Y, this.width, "");
				debug_text_holder.setFormat(null, 8, 0x000000, null, 0xFFFFFF);
				_playState.debugText.add(debug_text_holder);
			}
		}
		
		override public function update():void {	
			if (flashing) {
				alpha -= FlxG.elapsed / FLASH_SPEED;
				if (alpha < 0.5) {
					alpha = 1;
				}
			} else if (!has_visited) {
				//alpha = 0.8;
			} else {
				//alpha = 1;
			}
			
			super.update();
		}
		
		public function resetPathingVars():void {
			g = 0;
			h = 0;
			f = 0;
			pathingParent = null;
		}
		
		public function setDebugText():void {
			debug_text_holder.x = this.x;
			debug_text_holder.y = this.y;
			var coords:FlxPoint = getCoordinatesFromXY(this.x, this.y);
			debug_text_holder.text = this.type + " at [" + coords.x + "," + coords.y + "]";
			
			if (this.f > 0) {
				debug_text_holder.text += "\ng:" + this.g + ", h:" + this.h + ", f:" + this.f;
				if (this.pathingParent) {
					debug_text_holder.text += "\nfrom: " + directionArrow(directionToTile(pathingParent));
				}
			}
			
		}
		
		public function validForCard(card:Card):Boolean {
			var validity:Boolean = false;
			if (validEntrances().length > 0) {
				if (cards.length == 0) {
					validity = true;
				} else if (cards.length == 1) {
					if (card._type != cards[0]._type) {
						validity = true;
					}
				}
			}
			
			return validity;
		}
		
		public function addCard(card:Card):void {
			//copy of given card
			var newCard:Card = new Card(_playState, this.x, this.y, card._type, null, card._monster, card._treasure);
			if (newCard._monster != null) {
				var new_placing_card_monster:Monster = new Monster(this._playState, newCard._monster._type, true);
				_playState.tokens.add(new_placing_card_monster);
				newCard._monster = new_placing_card_monster;
				newCard._monster.x = this.x + MONSTER_ICON_OFFSET.x;
				newCard._monster.y = this.y + MONSTER_ICON_OFFSET.y;
				newCard._monster.Appear();
				_playState.assetManager.PlaySound("pop1"); //TODO replace with monster noises
			}
			if (newCard._treasure != null) {
				var new_placing_card_treasure:Treasure = new Treasure(this._playState, newCard._treasure._type, true);
				_playState.tokens.add(new_placing_card_treasure);
				newCard._treasure = new_placing_card_treasure;
				newCard._treasure.x = this.x + TREASURE_ICON_OFFSET.x;
				newCard._treasure.y = this.y + TREASURE_ICON_OFFSET.y;
				newCard._treasure.Appear();
				_playState.assetManager.PlaySound(newCard._treasure._equip_noise);
			}
			//tr("added card " + newCard._type + ":" + newCard._title + " to tile " + this.type);
			addTreasureOrMonsterCard(newCard);
		}
		
		public function addTreasureOrMonsterCard(newCard:Card):void {
			if (this.cards.length == 0) {
				this.cards.push(newCard);
			} else {
				if (newCard._type == "MONSTER") {
					//monster cards always put on end of array (encountered first)
					this.cards.push(newCard);
				} else {
					//treasure cards at start of array (encountered second)
					this.cards.unshift(newCard);
				}
			}
		}
		
		public function countCards(type:String = ""):int {
			var total:int = 0;
			for each (var card:Card in cards) {
				if (card._type == type || type == "") {
					total++;
				}
			}
			return total;
		}
		
		public function countCardValue(type:String = ""):int {
			var total:int = 0;
			for each (var card:Card in cards) {
				if (card._type == type || type == "") {
					total += card._cost + 1;
				}
			}
			return total;
		}
				
		public function getConnectedTiles():Array {
			var connected_tiles:Array = new Array();
			
			for each (var direction:int in validEntrances()) {
				var tile_coords:FlxPoint = getTileCoordsThroughExit(direction);
				var possible_tile:Tile = _playState.GetTileAtXY(tile_coords.x, tile_coords.y);
				//tr("checking for tile in direction " + Tile.directionName(direction) + " at [" + tile_coords.x + "," + tile_coords.y + "]");
				if (possible_tile && possible_tile.checkExit(Tile.oppositeDirection(direction))) {
					connected_tiles.push(possible_tile);
				}
			}
			
			return connected_tiles;
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
		
		//note: flipped directions
		public function validExits():Array {
			var valid_entrances:Array = validEntrances();
			var valid_exits:Array = new Array();
			for each (var entrance:int in valid_entrances) {
				valid_exits.push(Tile.oppositeDirection(entrance));
			}
			
			return valid_exits;
		}
		
		public function validHighlightEntrances():Array {
			var valid_entrances:Array = new Array();
			if (this.highlight_entry_north)
				valid_entrances.push(NORTH);
			if (this.highlight_entry_east)
				valid_entrances.push(EAST);
			if (this.highlight_entry_south)
				valid_entrances.push(SOUTH);
			if (this.highlight_entry_west)
				valid_entrances.push(WEST);
			return valid_entrances;
		}
		
		public function setHighlightEntrance(direction:int):void {
			//tr("setting highlight entrance at [" + Math.floor(x / Tile.TILESIZE) + "," + Math.floor(y / Tile.TILESIZE) + "] for direction " + direction + " " + Tile.directionName(direction));
			switch (direction) {
				case NORTH:
					this.highlight_entry_north = true;
					break;
				case EAST:
					this.highlight_entry_east = true;
					break;
				case SOUTH:
					this.highlight_entry_south = true;
					break;
				case WEST:
					this.highlight_entry_west = true;
					break;
				default:
					throw new Error("invalid direction " + direction);
			}
		}
		
		public function validForHighlight(highlight:Tile):Boolean {
			var valid_directions:Array = highlight.validHighlightEntrances();
			var highlight_coords:FlxPoint = Tile.getCoordinatesFromXY(highlight.x, highlight.y);
			//tr("in validForHighlight for tile with validEntrances: " + validEntrances());
			//tr(" checking highlight at (" + highlight_coords.x + "," + highlight_coords.y + ") with valid_directions: " + valid_directions);
			
			//check all highlight entrances are matched
			for each (var direction:int in valid_directions) {
				if (!checkExit(direction)) {
					//tr(" match NOT found in direction " + direction + " " + Tile.directionName(direction));
					return false;
				}
			}
			
			//check all exits of placing tile - make sure there are no tiles without corresponding entrances
			for each (direction in validEntrances()) {
				var tile_coords:FlxPoint = highlight.getTileCoordsThroughExit(direction);
				var possible_tile:Tile = _playState.GetTileAtXY(tile_coords.x, tile_coords.y);
				//tr("checking for tile in direction " + Tile.directionName(direction) + " at [" + tile_coords.x + "," + tile_coords.y + "]");
				if (possible_tile && !possible_tile.checkExit(Tile.oppositeDirection(direction))) {
					//tr(" tile found that wouldn't connect back");
					return false;
				}
			}
			
			return true;
		}
		
		public function GainGlory(amount:Number = 1, delay:Number = 0):void {
			if (delay > 0) {
				
			} else if (amount > 0) {
				_playState.player_glory += amount;
				_playState.BulgeObject(_playState.player_glory_label);
				var tilePoint:FlxPoint = this.getScreenXY();
				_playState.particleEmitter.x = tilePoint.x + this.width / 2;
				_playState.particleEmitter.y = tilePoint.y + this.height / 2;
				_playState.particleEmitter.start(true, 0.5, 0, amount * 3);
			}
		}
		
		public function distanceSquaredToTile(other_tile:Tile):Number {
			return (this.x - other_tile.x) * (this.x - other_tile.x) + (this.y - other_tile.y) * (this.y - other_tile.y);
		}
		
		public function stepsToTile(other_tile:Tile):Number {
			var this_coords:FlxPoint = getCoordinatesFromXY(this.x, this.y);
			var other_coords:FlxPoint = getCoordinatesFromXY(other_tile.x, other_tile.y);
			return Math.abs(this_coords.x - other_coords.x) + Math.abs(this_coords.y - other_coords.y);
		}
		
		public function directionToTile(other_tile:Tile):int {
			//note: assumes tiles are adjacent
			var this_coords:FlxPoint = getCoordinatesFromXY(this.x, this.y);
			var other_coords:FlxPoint = getCoordinatesFromXY(other_tile.x, other_tile.y);
			var x_dist:int = this_coords.x - other_coords.x;
			var y_dist:int = this_coords.y - other_coords.y;
			if (y_dist == 1) {
				return NORTH;
			} else if (x_dist == -1) {
				return EAST;
			} else if (y_dist == -1) {
				return SOUTH;
			} else if (x_dist == 1) {
				return WEST;
			} else {
				return -1;
			}
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
					return "NORTH";
				case EAST:
					return "EAST";
				case SOUTH:
					return "SOUTH";
				case WEST:
					return "WEST";
				default:
					throw new Error("invalid direction " + direction);
			}
		}
		
		public static function directionArrow(direction:int):String {
			switch (direction) {
				case NORTH:
					return "^";
				case EAST:
					return ">";
				case SOUTH:
					return "V";
				case WEST:
					return "<";
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
		
		public static function getCoordinatesFromXY(x:Number, y:Number):FlxPoint {
			return new FlxPoint(Math.floor(x / TILESIZE), Math.floor(y / TILESIZE));
		}
		
	}
}