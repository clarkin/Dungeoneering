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
		public static const THINKING_TIME:Number = FloatingText.FADE_IN_TIME + FloatingText.DISPLAY_TIME + FloatingText.FADE_OUT_TIME;
		public static const OFFSCREEN_POINT:FlxPoint = new FlxPoint(-150, 120);
		public static const ONSCREEN_POINT:FlxPoint = new FlxPoint(12, 120);
		public static const TILE_OFFSET:FlxPoint = new FlxPoint(20, 20); 
		public static const THOUGHT_OFFSET:FlxPoint = new FlxPoint(60, -86);
		
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
			} else if (_playState.turn_number >= 15 && _usedChats.indexOf("coming_soon") == -1) {
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

			_usedChats.push(chat_type);
			
			if (moveToBoard) {
				PickBossRoom();
				TweenLite.delayedCall(appearDelay + 0.05, BossNowOnBoard);
				TweenLite.to(this, TIME_TO_MOVE, { x:_current_tile.x + TILE_OFFSET.x, y:_current_tile.y + TILE_OFFSET.y, delay:appearDelay + 0.1, ease:Back.easeInOut.config(0.8) } );
				appearDelay += TIME_TO_MOVE;
				TweenLite.delayedCall(appearDelay, _playState.BossChatOver);
			} else {
				TweenLite.to(this, TIME_TO_MOVE, { x:OFFSCREEN_POINT.x, y:OFFSCREEN_POINT.y, delay:appearDelay, ease:Back.easeInOut.config(0.8) } );
				appearDelay += TIME_TO_MOVE;
				_playState.BossChatOver();
			}
		}
		
		public function BossAddChat(chat:String, delay:Number = 0, angry:Boolean = true):void {
			var eventualPosition:FlxPoint = new FlxPoint(ONSCREEN_POINT.x, ONSCREEN_POINT.y);
			if (_onBoard) {
				eventualPosition = new FlxPoint(x, y);
			}
			
			TweenMax.to(this, 0.15, { x:eventualPosition.x + 1, y:eventualPosition.y - 2, bothScale:bothScale + 0.1, delay:delay, repeat:5, yoyo:true } );
			var boss_shout:FloatingText = new FloatingText(eventualPosition.x + THOUGHT_OFFSET.x, eventualPosition.y + THOUGHT_OFFSET.y, chat, delay);
			if (!_onBoard) {
				boss_shout.scrollFactor = new FlxPoint(0, 0);
			}
			_playState.floatingTexts.add(boss_shout);
			
			if (angry) {
				TweenLite.delayedCall(delay, _playState.sndDemontalk1.play);
			} else {
				TweenLite.delayedCall(delay, _playState.sndDemontalk2.play);
			}
		}
		
		public function thinkSomething(thought_type:String, card_clicked:Card = null):void {
			var thought:String = "";
			var angry:Boolean = true;
			
			if (thought_type == "movement") {
				if (_moving_to_tile.cards.length > 0) {
					var top_card:Card = _moving_to_tile.cards[_moving_to_tile.cards.length - 1];
					switch (top_card._type) {
						case "MONSTER":
							var monster_thoughts:Array = ["OUT OF MY WAY MINION!", "GET OUT OF MY SIGHT MONSTER",
								"BURN MONSTER, BURN! You only gave him hope!", "Remind me not to stock any more MONSTERs..", "Oh look another useless MONSTER",
								"RROOAAARRRGH!!", "*sigh* more useless minions.."];
							thought = monster_thoughts[Math.floor(Math.random() * (monster_thoughts.length))];
							thought = thought.replace(/MONSTER/g, top_card._title);
							break;
						case "TREASURE":
							var treasure_thoughts:Array = ["Who left this here?!", "TREASURE? Where did that come from?",
								"TREASURE! Back into my loot box with you!", "Look at this clutter!", "Just as I get peckish.. a TREASURE! *om nyom*"];
							thought = treasure_thoughts[Math.floor(Math.random() * (treasure_thoughts.length))];
							thought = thought.replace(/TREASURE/g, top_card._title);
							break;
					}
				} else {
					if (_moving_to_tile == _playState.hero.current_tile) {
						var hero_thoughts:Array = ["THERE YOU ARE! I HOPE YOU LIKE BURNING", "TIME TO BURN!!!", "NOW I HAVE YOU"];
						thought = hero_thoughts[Math.floor(Math.random() * (hero_thoughts.length))];
					} else {
						var random_thoughts:Array = ["Does this make me a wandering monster?", "How come I don't know the way around my own dungeon!?", "This dungeon makes no sense!",
							"I think I'm getting closer!", "If only I had a NOSE I would sniff them out!!", "If only I could hold a map without burning it!", "Hmm...", "I can hear you .. somewhere!"];
						thought = random_thoughts[Math.floor(Math.random() * (random_thoughts.length))];
						angry = false;
					}
				}
			}
			BossAddChat(thought, 0, angry);
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
			var possible_directions:Array = _current_tile.validEntrances();
			var valid_tiles:Array = new Array();
			//trace("picking tile from possible directions: " + possible_directions);
			for each (var dir:int in possible_directions) {
				var coords:FlxPoint = _current_tile.getTileCoordsThroughExit(dir);
				//trace("current_tile at [" + current_tile.x + "," + current_tile.y + "]");
				//trace("checking for tile in direction " + dir + " at [" + coords.x + "," + coords.y + "]");
				var possible_tile:Tile = _playState.GetTileAt(coords);
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
				_current_tile.cards = [];
				var delay:Number = 0;
				thinkSomething("movement");
				delay += THINKING_TIME;
				TweenLite.to(this, TIME_TO_MOVE, { x:_moving_to_tile.x + TILE_OFFSET.x, y:_moving_to_tile.y + TILE_OFFSET.y, delay: delay, ease:Back.easeInOut.config(0.8) } );
				delay += TIME_TO_MOVE;
				TweenLite.delayedCall(delay, FinishedMove);
			}
		}
		
		public function FinishedMove():void {
			//trace('arrived at tile at [' + _moving_to_tile.x + ',' + _moving_to_tile.y + ']');
			_current_tile = _moving_to_tile;
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
			var path_to_hero:Array = _playState.tileManager.findPath(_current_tile, _playState.hero.current_tile);
			//go to next step
			return path_to_hero[1];
		}
		
		public function SetBossCardOnTile(tile:Tile):void {
			var bossMonster:Monster = new Monster(_playState, "Fire Demon");
			var bossCard:Card = new Card(_playState, 0, 0, "MONSTER", null, bossMonster); 
			bossCard._monster = bossMonster;
			tile.cards = [];
			tile.cards.push(bossCard);
			//trace("added boss card to tile at [" + tile.x + "," + tile.y + "]. frame at " + bossCard._monster.frame);
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