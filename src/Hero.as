package 
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	public class Hero extends FlxSprite
	{
		[Embed(source = "../assets/hero_sprite.png")] private var heroPNG:Class;
		
		public static const TIME_TO_MOVE_TILES:int = 1000;
		public static const ARRIVAL_THRESHOLD:int = 4;
		public static const THINKING_TIME:Number = 2;
		public static const CARD_TIME:Number = 2;
		
		public var tile_offset:FlxPoint = new FlxPoint(60, 60);
		private var thought_offset:FlxPoint = new FlxPoint(70, -20);
		
		public var current_tile:Tile;
		public var moving_to_tile:Tile;
		public var is_taking_turn:Boolean = false;
		public var is_moving:Boolean = false;
		public var is_processing_cards:Boolean = false;
		public var thinking_timer:Number = 0;
		public var card_timer:Number = 0;
		
		public var _health:int = 0;
		public var _strength:int = 0;
		public var _speed:int = 0;
		public var _armour:int = 0;
		
		private var _playState:PlayState;
		
		public function Hero(playState:PlayState, X:int = 0, Y:int = 0) 
		{
			//trace("adding hero at [" + X + "," + Y + "]");
			super(X + tile_offset.x, Y + tile_offset.y);
			
			_health = 10;
			_strength = 2;
			_speed = 2;
			_armour = 0;
			
			loadGraphic(heroPNG, false, true, 64, 79);
			
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
			_playState.following_hero = true;
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
				moving_to_tile = chooseTile(valid_tiles);
				if (moving_to_tile.x < current_tile.x) {
					facing = LEFT;
				} else if (moving_to_tile.x > current_tile.x) {
					facing = RIGHT;
				}
				thinkSomething("movement");
				_playState.turn_phase = PlayState.PHASE_HERO_THINK;
			}
		}
		
		private function chooseTile(valid_tiles:Array):Tile {
			//default: random tile
			var favorite_tile:Tile = valid_tiles[Math.floor(Math.random() * (valid_tiles.length))];
			for each (var tile:Tile in valid_tiles) {
				//check if this is preferable to current fave
				if (tile.countCards("TREASURE") > favorite_tile.countCards("TREASURE") || (favorite_tile.has_visited && !tile.has_visited)) {
					favorite_tile = tile;
				}
			}
			return favorite_tile;
		}
		
		public function thinkSomething(thought_type:String):void {
			var thought:String = "";
			
			if (thought_type == "movement") {
				if (moving_to_tile.cards.length > 0) {
					var top_card:Card = moving_to_tile.cards[moving_to_tile.cards.length - 1];
					switch (top_card._type) {
						case "MONSTER":
							var monster_thoughts:Array = ["Grrr! I hate MONSTERs!!", "That MONSTER is going to get it",
								"Yeah, I THINK I can take it..", "Oh god not a MONSTER", "Well lets get this over with",
								"BANZAAAAAIIIIII", "MONSTERs drop loot, right?"];
							thought = monster_thoughts[Math.floor(Math.random() * (monster_thoughts.length))];
							thought = thought.replace(/MONSTER/g, top_card._title);
							break;
						case "TREASURE":
							var treasure_thoughts:Array = ["SHINY", "That looks a bit like a TREASURE",
								"Is that.. TREASURE!", "THIS is why I'm a dungeoneer!", "Om nyom nyom",
								"Ooh gimme", "TREASURE? TREASURE!", "Cha-CHING!"];
							thought = treasure_thoughts[Math.floor(Math.random() * (treasure_thoughts.length))];
							thought = thought.replace(/TREASURE/g, top_card._title);
							break;
						case "WEAPON":
							var weapon_thoughts:Array = ["Oh yeah I need me one of those", "That looks a bit like a WEAPON",
								"Is that.. WEAPON!", "Another WEAPON? Jeez", "That looks useful..", "Yeah! #LOOT",
								"Hm, is that an upgrade?", "That will look nice on my mantelpiece"];
							thought = weapon_thoughts[Math.floor(Math.random() * (weapon_thoughts.length))];
							thought = thought.replace(/WEAPON/g, top_card._title);
							break;
					}
					
				} else {
					var random_thoughts:Array = ["On we go..", "Hm.. was I already here?", "A dungeoneer's life is never dull..",
						"I think I'm lost #DUNGEONEERING", "Eyes closed this time.. #YOLO", "This looks vaguely familiar", 
						"The Guild isn't paying me enough for this", "Maybe over here", "I hope this place has a tavern"];
					thought = random_thoughts[Math.floor(Math.random() * (random_thoughts.length))];
				}
			} else if (thought_type == "idle") {
				var idle_thoughts:Array = ["Come on! Do SOMETHING!", "So.. bored", "Why can't I move now? Oh yeah you're playing those cards..",
					"...", "zzzzZZZ", "*sigh*", "How about finding me something easy.. like a rubber ducky?", 
					"I wish I was back at my nice warm room in the Guild", "*YAWN*", "Are you AFK?? Don't leave me here!"];
				thought = idle_thoughts[Math.floor(Math.random() * (idle_thoughts.length))];
			} else if (thought_type == "poked") {
				var poked_thoughts:Array = ["Ow - that hurt!", "Please stop clicking me .. there", "What if I were to poke YOU instead!?",
					"Stop that", "The rulebook clearly says that clicking me doesn't achieve anything", "Cut it out!"];
				thought = poked_thoughts[Math.floor(Math.random() * (poked_thoughts.length))];
			}
			
			_playState.floatingTexts.add(new FloatingText(x + thought_offset.x, y + thought_offset.y, thought));
		}
		
		private function checkMovement():void {
			if (moving_to_tile != null && current_tile != moving_to_tile) {
				
				var distance_x:int = moving_to_tile.x + tile_offset.x - (x + origin.x);
				var distance_y:int = moving_to_tile.y + tile_offset.y - (y + origin.y);
				
				//trace("hero at [" + this.x + "," + this.y + "], moving_to_tile at [" + (moving_to_tile.x + tile_offset_x) + "," + (moving_to_tile.y + tile_offset_y) + "]");
				//trace("hero origin is [" + this.origin.x + "," + this.origin.y + "]");
				//trace("distance: [" + distance_x + "," + distance_y + "]");
				FlxVelocity.moveTowardsPoint(this, new FlxPoint(moving_to_tile.x + tile_offset.x, moving_to_tile.y + tile_offset.y), 0, TIME_TO_MOVE_TILES);
				
				if (distance_x >= -ARRIVAL_THRESHOLD && distance_x <= ARRIVAL_THRESHOLD && distance_y >= -ARRIVAL_THRESHOLD && distance_y <= ARRIVAL_THRESHOLD) {
					moving_to_tile.has_visited = true;
					setCurrentTile(moving_to_tile);
					is_taking_turn = false;
					is_moving = false;
					velocity = new FlxPoint(0, 0);
					_playState.heroArrivedAt(moving_to_tile);
				}
			}
		}
		
		public function setCurrentTile(new_tile:Tile):void {
			current_tile = new_tile;
			//x = new_tile.x + tile_offset_x;
			//y = new_tile.y + tile_offset_y;
			//trace("** hero at target tile ** " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
		}
		
		public function processNextCard():void {
			if (current_tile.cards.length == 0) {
				is_processing_cards = false;
				if (_playState.turn_phase != PlayState.PHASE_HERO_BATTLE) {
					_playState.following_hero = false;
					_playState.turn_phase = PlayState.PHASE_NEWTURN;
				}
			} else {
				var next_card:Card = current_tile.cards.pop();
				//trace("processing card " + next_card._title);
				
				if (next_card._type == "TREASURE") {
					_playState.sndCoins.play();
					_playState.player_treasure += next_card._treasure._hope + 1;
				} else if (next_card._type == "MONSTER") {
					_playState.StartBattle(next_card._monster);
				}

				is_processing_cards = true;
				card_timer = CARD_TIME;				
			}
		}
		
		public function FightMonster(this_monster:Monster):void {
			if (_speed >= this_monster._speed) {
				trace("hero attacks first")
				HeroAttacksMonster(this_monster);
				
				if (this_monster._health > 0) {
					MonsterAttacksHero(this_monster);
				}
			} else {
				trace("monster attacks first")
				MonsterAttacksHero(this_monster);
				
				if (_health > 0) {
					HeroAttacksMonster(this_monster);
				}
			}
		}
		
		public function HeroAttacksMonster(this_monster:Monster):void {
			trace("hero attacked monster");
			if (_strength > this_monster._armour) {
				this_monster._health -= (_strength - this_monster._armour);
				_playState.sndSwordkill.play();
			}
			
			if (this_monster._health <= 0) {
				_playState.dungeon._hope_level += this_monster._dread + 1;
			}
		}
		
		public function MonsterAttacksHero(this_monster:Monster):void {
			trace("monster attacked hero");
			if (this_monster._strength > _armour) {
				_health -= (this_monster._strength - _armour);
				CheckHeroHealth();
			}
		}
		
		public function CheckHeroHealth():void {
			if (_health <= 0) {
				trace("hero dead");
				_playState.player_alive = false;
				_playState.leaveDungeon();
			}
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