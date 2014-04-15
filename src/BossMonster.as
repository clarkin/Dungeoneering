package 
{
	import com.greensock.loading.data.VideoLoaderVars;
	import org.flixel.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class BossMonster extends FlxSprite
	{
		[Embed(source = "../assets/monster_spritesheet_120px_COLOUR.png")] private var charactersBossPNG:Class;
		
		public static const SPRITE_SIZE:int = 120;
		public static const TIME_TO_MOVE:Number = 1.0;
		public static const OFFSCREEN_POINT:FlxPoint = new FlxPoint(-150, 120);
		public static const ONSCREEN_POINT:FlxPoint = new FlxPoint(12, 120);
		public static const TILE_OFFSET:FlxPoint = new FlxPoint(20, 20); 
		
		public var _type:String = "";
		public var _desc:String = "";
		public var _dread:Number = 0;
		
		public var _health:int = 1;
		public var _strength:int = 1;
		public var _speed:int = 1;
		public var _armour:int = 0;
		
		public var _onBoard:Boolean = false;
		public var _current_tile:Tile;
		public var _moving_to_tile:Tile;
		public var _previous_tile:Tile;
		public var _bossCard:Card;
		public var _is_taking_turn:Boolean = true;
		
		private var _playState:PlayState;
		
		private var _usedChats:Array = [];
		
		public function BossMonster(playState:PlayState, type:String, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			_type = type;
			
			loadGraphic(charactersBossPNG, false, true, SPRITE_SIZE, SPRITE_SIZE);
			antialiasing = true;
						
			switch (_type) {
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
			
			var bossMonster:Monster = new Monster(_playState, "Fire Demon");
			bossMonster.visible = false;
			_bossCard = new Card(_playState, X, Y, "MONSTER", null, bossMonster); 
			_bossCard._monster = bossMonster;
		}
		
		public function CheckChat():void {
			if (_onBoard) {
				_playState.BossChatOver();
				return;
			}
			
			if (_playState.turn_number == 1 && _usedChats.indexOf("intruder") == -1) {
				DoBossChat("intruder");
			} else if (_playState.monsters_killed == 1 && _usedChats.indexOf("first_kill") == -1) {
				DoBossChat("first_kill");
			} else if (_playState.monsters_killed >= 5 && _usedChats.indexOf("fifth_kill") == -1) {
				DoBossChat("fifth_kill");
			} else if (_playState.turn_number >= 20 && _usedChats.indexOf("coming_soon") == -1) {
				DoBossChat("coming_soon");
			} else {
				_playState.BossChatOver();
			}
		}
		
		public function DoBossChat(chat_type:String):void {
			var appearDelay:Number = 0;
			TweenLite.to(this, TIME_TO_MOVE, { x:ONSCREEN_POINT.x, y:ONSCREEN_POINT.y, delay:appearDelay, ease:Back.easeInOut.config(0.8) } );
			appearDelay += TIME_TO_MOVE;
			
			var oneChatCycle:Number = FloatingText.FADE_IN_TIME * 2 + FloatingText.DISPLAY_TIME + FloatingText.FADE_OUT_TIME;
			var moveToBoard:Boolean = false;
			
			if (chat_type == "intruder") {
				BossAddChat("WHO DARES INVADE THE HOT, HOT LAIR OF EMBRO, LORD OF FLAME?!", appearDelay);
				appearDelay += oneChatCycle;
				
				BossAddChat("Right in the middle of bath time, too. Look at this puddle.", appearDelay, false);
				appearDelay += oneChatCycle;
				
				BossAddChat("MINIONS! DESTROY THEM! BRING ME THEIR BONES!", appearDelay);
				appearDelay += oneChatCycle;
				moveToBoard = true; //todo: remove
			} else if (chat_type == "first_kill") {
				BossAddChat("HAR HAR! YOU THINK I'LL MISS THAT " + _playState.battling_monster._type.toUpperCase() + "?", appearDelay);
				appearDelay += oneChatCycle;
				
				BossAddChat("NO! HE WAS MY LEAST FAVORITE MINION!", appearDelay);
				appearDelay += oneChatCycle;
			} else if (chat_type == "fifth_kill") {
				BossAddChat("*sigh* As usual my minions are bumbling fools..", appearDelay, false);
				appearDelay += oneChatCycle;
				
				BossAddChat("If only those sharks with spears attached to their heads had arrived.", appearDelay, false);
				appearDelay += oneChatCycle;
				
				BossAddChat("Oh well. SEND MORE RUBBER DUCKIES!", appearDelay);
				appearDelay += oneChatCycle;
			} else if (chat_type == "coming_soon") {
				BossAddChat("*GRRAAAARGH!* That's it, you've made me angry!", appearDelay);
				appearDelay += oneChatCycle;
				
				BossAddChat("Time to deal with you myself!!", appearDelay, false);
				appearDelay += oneChatCycle;
				
				moveToBoard = true;
			}
			
			if (moveToBoard) {
				PickBossRoom();
				TweenLite.delayedCall(appearDelay + 0.05, BossNowOnBoard);
				TweenLite.to(this, TIME_TO_MOVE, { x:_current_tile.x + TILE_OFFSET.x, y:_current_tile.y + TILE_OFFSET.y, delay:appearDelay + 0.1, ease:Back.easeInOut.config(0.8) } );
				appearDelay += TIME_TO_MOVE;
			} else {
				TweenLite.to(this, TIME_TO_MOVE, { x:OFFSCREEN_POINT.x, y:OFFSCREEN_POINT.y, delay:appearDelay, ease:Back.easeInOut.config(0.8) } );
				appearDelay += TIME_TO_MOVE;
			}
			TweenLite.delayedCall(appearDelay, _playState.BossChatOver);
			
			_usedChats.push(chat_type);
		}
		
		public function BossAddChat(chat:String, delay:Number = 0, angry:Boolean = true):void {
			TweenMax.to(this, 0.15, { x:ONSCREEN_POINT.x + 1, y:ONSCREEN_POINT.y - 2, bothScale:bothScale + 0.1, delay:delay, repeat:5, yoyo:true } );
			var boss_shout:FloatingText = new FloatingText(ONSCREEN_POINT.x + 60, ONSCREEN_POINT.y - 86, chat, delay);
			boss_shout.scrollFactor = new FlxPoint(0, 0);
			_playState.floatingTexts.add(boss_shout);
			
			if (angry) {
				TweenLite.delayedCall(delay, _playState.sndDemontalk1.play);
			} else {
				TweenLite.delayedCall(delay, _playState.sndDemontalk2.play);
			}
		}
		
		public function PickBossRoom():void {
			var searching:Boolean = true;
			var cardThreshold:int = 20;
			var numberOfChecks:int = 0;
			var possible_tile:Tile;
			while (searching) {
				possible_tile = _playState.tiles.getRandom() as Tile;
				if (possible_tile != _playState.hero.current_tile) {
					if (numberOfChecks > cardThreshold || possible_tile.countCards() == 0) {
						searching = false;
					}
				}
				numberOfChecks += 1;
			}
			_current_tile = possible_tile;
			//_current_tile.cards = [];
			//_current_tile.cards.push(_bossCard);
			SetBossCardOnTile(_current_tile);
			//trace('picked tile at world [' + current_tile.x + ',' + current_tile.y + '], screen [' + current_tile.getScreenXY().x + ',' + current_tile.getScreenXY().y + ']')
		}
		
		public function BossNowOnBoard():void {
			//BossTraceXY();
			var old_point:FlxPoint = new FlxPoint(x, y);
			x = old_point.x + FlxG.camera.scroll.x;
			y = old_point.y + FlxG.camera.scroll.y;
			scrollFactor = new FlxPoint(1.0, 1.0);
			_is_taking_turn = false;
			_onBoard = true;
			//BossTraceXY();
		}
		
		public function StartTurn():void {
			//_playState.following_hero = true;
			_is_taking_turn = true;
			//thinking_timer = THINKING_TIME;
			var possible_directions:Array = _current_tile.validEntrances();
			var valid_tiles:Array = new Array();
			//trace("picking tile from possible directions: " + possible_directions);
			for each (var dir:int in possible_directions) {
				var coords:FlxPoint = _current_tile.getTileCoordsThroughExit(dir);
				//trace("current_tile at [" + current_tile.x + "," + current_tile.y + "]");
				//trace("checking for tile in direction " + dir + " at [" + coords.x + "," + coords.y + "]");
				var possible_tile:Tile = _playState.getTileAt(coords);
				//trace("possible_tile: " + possible_tile);
				if (possible_tile != null && possible_tile.checkExit(Tile.oppositeDirection(dir))) {
					valid_tiles.push(possible_tile);
				}
			}
			
			if (valid_tiles.length == 0) {
				EndTurn();
				trace('** WARNING: no valid tiles to move to **');
			} else {
				_moving_to_tile = chooseTile(valid_tiles);
				if (_moving_to_tile.x < _current_tile.x) {
					facing = LEFT;
				} else if (_moving_to_tile.x > _current_tile.x) {
					facing = RIGHT;
				}
				//thinkSomething("movement");
				//_playState.turn_phase = PlayState.PHASE_HERO_THINK;
				_current_tile.cards = [];
				TweenLite.to(this, TIME_TO_MOVE, { x:_moving_to_tile.x + TILE_OFFSET.x, y:_moving_to_tile.y + TILE_OFFSET.y, ease:Back.easeInOut.config(0.8) } );
				TweenLite.delayedCall(TIME_TO_MOVE, FinishedMove);
			}
		}
		
		public function FinishedMove():void {
			//trace('arrived at tile at [' + _moving_to_tile.x + ',' + _moving_to_tile.y + ']');
			_current_tile = _moving_to_tile;
			//_current_tile.cards = [];
			//_current_tile.cards.push(_bossCard);
			SetBossCardOnTile(_current_tile);
			EndTurn();
			if (_current_tile == _playState.hero.current_tile) {
				trace('** arrived at hero! **');
				_playState.turn_phase = PlayState.PHASE_HERO_CARDS;
			}
		}
		
		public function EndTurn():void {
			_playState.turn_phase = PlayState.PHASE_NEWTURN;
			_is_taking_turn = false;
		}
		
		private function chooseTile(valid_tiles:Array):Tile {
			//default: random tile
			var favorite_tile:Tile = valid_tiles[Math.floor(Math.random() * (valid_tiles.length))];
			/*
			for each (var tile:Tile in valid_tiles) {
				//check if this is preferable to current fave
				if (tile.countCards("TREASURE") > favorite_tile.countCards("TREASURE") || (favorite_tile.has_visited && !tile.has_visited)) {
					favorite_tile = tile;
				}
			} */
			return favorite_tile;
		}
		
		public function SetBossCardOnTile(tile:Tile):void {
			var bossMonster:Monster = new Monster(_playState, "Fire Demon");
			bossMonster.visible = false;
			var bossCard:Card = new Card(_playState, 0, 0, "MONSTER", null, bossMonster); 
			bossCard._monster = bossMonster;
			tile.cards = [];
			tile.cards.push(bossCard);
		}
		
		public function BossTraceXY():void {
			trace('boss at world [' + x + ',' + y +'], screen [' + getScreenXY().x + ',' + getScreenXY().y + ']');
			trace('boss.current_tile at world [' + _current_tile.x + ',' + _current_tile.y + '], screen [' + _current_tile.getScreenXY().x + ',' + _current_tile.getScreenXY().y + ']')
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