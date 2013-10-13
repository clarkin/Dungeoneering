package 
{
	import org.flixel.*;
	
	public class Hero extends FlxSprite
	{
		[Embed(source = "../assets/ass_char_tran.png")] private var charactersPNG:Class;
		
		public static const TILESIZE:int = 42;
		public static const SPEED:int = 4;
		public static const THINKING_TIME:Number = 0.5;
		public static const CARD_TIME:Number = 2;
		
		private var tile_offset_x:int = 5;
		private var tile_offset_y:int = 12;
		
		public var current_tile:Tile;
		public var moving_to_tile:Tile;
		public var is_taking_turn:Boolean = false;
		public var is_moving:Boolean = false;
		public var is_processing_cards:Boolean = false;
		public var thinking_timer:Number = 0;
		public var card_timer:Number = 0;
		
		private var _playState:PlayState;
		
		public function Hero(playState:PlayState, X:int = 0, Y:int = 0) 
		{
			super(X + tile_offset_x, Y + tile_offset_y);
			
			loadGraphic(charactersPNG, false, true, 24, 24);

			addAnimation("knight1", [36]);
			play("knight1");
			
			_playState = playState;
		}
		
		override public function update():void {	
			//trace("current tile: " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
			//trace("moving to tile: " + moving_to_tile.type + " at [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			//trace("currently at : [" + x + "," + y + "], moving to [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			
			if (is_taking_turn) {
				if (thinking_timer > 0) {
					thinking_timer -= FlxG.elapsed;
				} else {
					if (!is_moving) {
						_playState.turn_phase = PlayState.PHASE_HERO_MOVING;
						if (current_tile.type.indexOf("room") == 0) {
							_playState.sndDoorcreak.play();
						} else if (current_tile.type.indexOf("corr") == 0) {
							_playState.sndFootsteps.play();
						}
						is_moving = true;
					}
					checkMovement();
				}
			} else if (is_processing_cards) {
				if (card_timer > 0) {
					card_timer -= FlxG.elapsed;
				} else {
					
					processNextCard();
				}
			}
			
			super.update();
		}
		
		public function startTurn():void {
			is_taking_turn = true;
			thinking_timer = THINKING_TIME;
			var possible_directions:Array = current_tile.validEntrances();
			var valid_tiles:Array = new Array();
			//trace("picking tile from possible directions: " + possible_directions);
			for each (var dir:int in possible_directions) {
				var coords:FlxPoint = current_tile.getTileCoordsThroughExit(dir);
				//trace("current_tile at [" + current_tile.x + "," + current_tile.y + "]");
				//trace("checking for tile in direction " + dir + " at [" + coords.x + "," + coords.y + "]");
				var possible_tile:Tile = _playState.getTileAt(coords);
				//trace("possible_tile: " + possible_tile);
				if (possible_tile != null && possible_tile.checkExit(Tile.oppositeDirection(dir))) {
					valid_tiles.push(possible_tile);
				}
			}
			
			if (valid_tiles.length == 0) {
				_playState.turn_phase = PlayState.PHASE_NEWTURN;
			} else {
				moving_to_tile = valid_tiles[Math.floor(Math.random() * (valid_tiles.length))];
				_playState.turn_phase = PlayState.PHASE_HERO_THINK;
			}
		}
		
		private function checkMovement():void {
			if (moving_to_tile != null && current_tile != moving_to_tile) {
				var distance_x:int = moving_to_tile.x + tile_offset_x - x;
				var distance_y:int = moving_to_tile.y + tile_offset_y - y;
				
				x += distance_x * FlxG.elapsed * SPEED;
				y += distance_y * FlxG.elapsed * SPEED;
				
				if (distance_x >= -1 && distance_x <= 1 && distance_y >= -1 && distance_y <= 1) {
					setCurrentTile(moving_to_tile);
					is_taking_turn = false;
					is_moving = false;
					_playState.heroArrivedAt(moving_to_tile);
				}
			}
		}
		
		public function setCurrentTile(new_tile:Tile):void {
			current_tile = new_tile;
			x = new_tile.x + tile_offset_x;
			y = new_tile.y + tile_offset_y;
			//trace("** hero at target tile ** " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
		}
		
		public function processNextCard():void {
			if (current_tile.cards.length == 0) {
				is_processing_cards = false;
				_playState.turn_phase = PlayState.PHASE_NEWTURN;
			} else {
				var next_card:Card = current_tile.cards.pop();
				//trace("processing card " + next_card._title);
				
				if (next_card._type == "TREASURE" || next_card._type == "WEAPON") {
					_playState.sndCoins.play();
					_playState.player_treasure += 1;
				} else if (next_card._type == "MONSTER") {
					_playState.player_life -= 1;
					if (_playState.player_life <= 0) {
						_playState.player_alive = false;
						_playState.leaveDungeon();
					} else {
						_playState.sndSwordkill.play();
					}
				}

				is_processing_cards = true;
				card_timer = CARD_TIME;				
			}
			
			
		}

	}
}