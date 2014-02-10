package 
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class Hero extends FlxSprite
	{
		[Embed(source = "../assets/hero_base.png")] private var heroBasePNG:Class;
		[Embed(source = "../assets/hero_spritesheet_80px_COL.png")] private var heroPNG:Class;
		
		public static const TIME_TO_MOVE_TILES:Number = 1.0;
		public static const ARRIVAL_THRESHOLD:int = 0;
		public static const THINKING_TIME:Number = 3;
		public static const CARD_TIME:Number = 2;
		public static const TILE_SIZE:int = 80;
		
		public var tile_offset:FlxPoint = new FlxPoint(60, 60);
		private var thought_offset:FlxPoint = new FlxPoint(29, -110);
		
		public var current_tile:Tile;
		public var moving_to_tile:Tile;
		public var previous_tile:Tile;
		public var processing_card:Card;
		public var is_taking_turn:Boolean = false;
		public var is_moving:Boolean = false;
		public var is_processing_cards:Boolean = false;
		public var thinking_timer:Number = 0;
		public var card_timer:Number = 0;
		
		public var _health:int = 0;
		public var _strength:int = 0;
		public var _speed:int = 0;
		public var _armour:int = 0;
		
		public var _equipped_helmet:Treasure;
		public var _equipped_armour:Treasure;
		public var _equipped_weapon:Treasure;
		public var _equipped_shield:Treasure;
		
		public var _equippables:FlxSprite;
		
		private var _playState:PlayState;
		
		public function Hero(playState:PlayState, X:int = 0, Y:int = 0) 
		{
			//trace("adding hero at [" + X + "," + Y + "]");
			super(X + tile_offset.x, Y + tile_offset.y);
			
			_playState = playState;
			
			_health = 10;
			_strength = 2;
			_speed = 2;
			_armour = 0;
			
			_equippables = new FlxSprite(X, Y);
			_equippables.loadGraphic(heroPNG, true, false, TILE_SIZE, TILE_SIZE);
			
			RedoSprite();
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
						previous_tile = current_tile;
						TweenLite.to(this, TIME_TO_MOVE_TILES, { x:moving_to_tile.x + tile_offset.x - origin.x, y:moving_to_tile.y + tile_offset.y - origin.y, ease:Back.easeInOut.config(0.8) } );
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
		
		public function RedoSprite():void {
			loadGraphic(heroBasePNG, false, false, TILE_SIZE, TILE_SIZE, true);
			
			//expression
			_equippables.frame = 1;
			this.stamp(_equippables);
			
			if (_equipped_helmet != null) {
				_equippables.frame = _equipped_helmet._equippables_frame;
				this.stamp(_equippables);
			}
			
			if (_equipped_armour != null) {
				_equippables.frame = _equipped_armour._equippables_frame;
				this.stamp(_equippables);
			} else {
				//tunic
				_equippables.frame = 14;
				this.stamp(_equippables);
			}
			
			if (_equipped_shield != null) {
				_equippables.frame = _equipped_shield._equippables_frame;
				this.stamp(_equippables);
			}
			
			if (_equipped_weapon != null) {
				_equippables.frame = _equipped_weapon._equippables_frame;
				this.stamp(_equippables);
			}
			
			if (_playState.stats_hero_sprite != null) {
				_playState.stats_hero_sprite.pixels = this.framePixels.clone();
			}
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
		
		public function thinkSomething(thought_type:String, card_clicked:Card = null):void {
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
			} else if (thought_type == "card_afford") {
				var afford_thoughts:Array = ["No, silly, you need COST CURRENCY before you can play that!", "Playing a CARDNAME costs COST CURRENCY. Even I know that!!",
					"Don't some cards have a cost? Did you skip reading the manual?! ohgodimdoomed", "You need more CURRENCY before you can play that CARDNAME..", 
					"Maybe you need more CURRENCY for that?"];
				thought = afford_thoughts[Math.floor(Math.random() * (afford_thoughts.length))];
				thought = thought.replace(/COST/g, card_clicked._cost);
				thought = thought.replace(/CURRENCY/g, card_clicked._type == "MONSTER" ? "DREAD" : "HOPE");
				thought = thought.replace(/CARDNAME/g, card_clicked._title);
			} else if (thought_type == "card_fit") {
				var fit_thoughts:Array = ["I don't think that can fit anywhere right now..", "And just where would that CARDNAME fit?",
					"There's nowhere that can fit that CARDNAME", "That won't fit anywhere!", "There's no space for that CARDNAME!"];
				thought = fit_thoughts[Math.floor(Math.random() * (fit_thoughts.length))];
				thought = thought.replace(/CARDNAME/g, card_clicked._title);
			}
			
			TweenMax.to(this, THINKING_TIME / 20, {x:x+1, y:y-2, repeat:5, yoyo:true});
			_playState.floatingTexts.add(new FloatingText(x + thought_offset.x, y + thought_offset.y, thought));
		}
		
		private function checkMovement():void {
			if (moving_to_tile != null && current_tile != moving_to_tile) {
				
				var distance_x:int = moving_to_tile.x + tile_offset.x - (x + origin.x);
				var distance_y:int = moving_to_tile.y + tile_offset.y - (y + origin.y);
				
				//trace("hero at [" + this.x + "," + this.y + "], moving_to_tile at [" + (moving_to_tile.x + tile_offset.x - origin.x) + "," + (moving_to_tile.y + tile_offset.y - origin.y) + "]");
				//trace("hero origin is [" + this.origin.x + "," + this.origin.y + "]");
				//trace("distance: [" + distance_x + "," + distance_y + "]");
				
				if (distance_x >= -ARRIVAL_THRESHOLD && distance_x <= ARRIVAL_THRESHOLD && distance_y >= -ARRIVAL_THRESHOLD && distance_y <= ARRIVAL_THRESHOLD) {
					moving_to_tile.has_visited = true;
					setCurrentTile(moving_to_tile);
					is_taking_turn = false;
					is_moving = false;
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
				processing_card = next_card;
				//trace("processing card " + next_card._title);
				
				if (next_card._type == "TREASURE") {
					var sell_it:Boolean = true;
					switch (next_card._treasure._equippable_type) {
						case "helmet":
							if (_equipped_helmet == null || next_card._treasure._hope > _equipped_helmet._hope) {
								sell_it = false;
								_equipped_helmet = next_card._treasure;
								RedoSprite();
							}
							break;
						case "armour":
							if (_equipped_armour == null || next_card._treasure._hope > _equipped_armour._hope) {
								sell_it = false;
								_equipped_armour = next_card._treasure;
								RedoSprite();
							}
							break;
						case "shield":
							if (_equipped_shield == null || next_card._treasure._hope > _equipped_shield._hope) {
								sell_it = false;
								_equipped_shield = next_card._treasure;
								RedoSprite();
							}
							break;
						case "weapon":
							if (_equipped_weapon == null || next_card._treasure._hope > _equipped_weapon._hope) {
								sell_it = false;
								_equipped_weapon = next_card._treasure;
								RedoSprite();
							}
							break;
						default: 
							//nothing
					}
					if (sell_it) {
						_playState.sndCoins.play();
						_playState.player_treasure += next_card._treasure._hope + 1;
					}
				} else if (next_card._type == "MONSTER") {
					_playState.StartBattle(next_card._monster);
				}

				is_processing_cards = true;
				card_timer = CARD_TIME;				
			}
		}
		
		public function FightMonster(this_monster:Monster):void {
			if (EquippedSpeed() >= this_monster._speed) {
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
			if (EquippedStrength() > this_monster._armour) {
				this_monster._health -= (EquippedStrength() - this_monster._armour);
				_playState.sndSwordkill.play();
			}
			
			if (this_monster._health <= 0) {
				_playState.dungeon._hope_level += this_monster._dread + 1;
				_playState.BulgeLabel(_playState.player_hope_label);
			}
		}
		
		public function MonsterAttacksHero(this_monster:Monster):void {
			trace("monster attacked hero");
			if (this_monster._strength > EquippedArmour()) {
				_health -= (this_monster._strength - EquippedArmour());
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
		
		public function EquippedStrength():int {
			var equipped_strength_total:int = _strength;
			if (_equipped_helmet != null) {
				equipped_strength_total += _equipped_helmet._equippable_strength;
			}
			if (_equipped_shield != null) {
				equipped_strength_total += _equipped_shield._equippable_strength;
			}
			if (_equipped_armour != null) {
				equipped_strength_total += _equipped_armour._equippable_strength;
			}
			if (_equipped_weapon != null) {
				equipped_strength_total += _equipped_weapon._equippable_strength;
			}
			
			return equipped_strength_total;
		}
		
		public function EquippedSpeed():int {
			var equipped_speed_total:int = _speed;
			if (_equipped_helmet != null) {
				equipped_speed_total += _equipped_helmet._equippable_speed;
			}
			if (_equipped_shield != null) {
				equipped_speed_total += _equipped_shield._equippable_speed;
			}
			if (_equipped_armour != null) {
				equipped_speed_total += _equipped_armour._equippable_speed;
			}
			if (_equipped_weapon != null) {
				equipped_speed_total += _equipped_weapon._equippable_speed;
			}
			
			return equipped_speed_total;
		}
		
		public function EquippedArmour():int {
			var equipped_armour_total:int = _armour;
			if (_equipped_helmet != null) {
				equipped_armour_total += _equipped_helmet._equippable_armour;
			}
			if (_equipped_shield != null) {
				equipped_armour_total += _equipped_shield._equippable_armour;
			}
			if (_equipped_armour != null) {
				equipped_armour_total += _equipped_armour._equippable_armour;
			}
			if (_equipped_weapon != null) {
				equipped_armour_total += _equipped_weapon._equippable_armour;
			}
			
			return equipped_armour_total;
		}
		
		public function GetStats():String {
			var stats:String = "";
			stats += "Health: " + _health + "\n";
			stats += "Strength: " + EquippedStrength() + "\n";
			stats += "Speed: " + EquippedSpeed() + "\n";
			stats += "Armour: " + EquippedArmour() + "\n";
			return stats;
		}

	}
}