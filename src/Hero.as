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
		public static const THINKING_TIME:Number = FloatingText.FADE_IN_TIME + FloatingText.DISPLAY_TIME + FloatingText.FADE_OUT_TIME;
		public static const TIME_TREASURE:Number = 1.0;
		public static const TILE_SIZE:int = 80;
		
		public static const EXPRESSION_HAPPY:int = 1;
		public static const EXPRESSION_ANGRY:int = 2;
		public static const EXPRESSION_WORRIED:int = 3;
		public static const EXPRESSION_SCARED:int = 4;
		
		public var tile_offset:FlxPoint = new FlxPoint(60, 60);
		public var thought_offset:FlxPoint = new FlxPoint(29, -110);
		
		public var current_tile:Tile;
		public var moving_to_tile:Tile;
		public var previous_tile:Tile;
		public var processing_card:Card;
		public var is_taking_turn:Boolean = false;
		public var is_moving:Boolean = false;
		public var is_processing_cards:Boolean = false;
		public var is_female:Boolean = false;
		public var expression:int = EXPRESSION_HAPPY;
		
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
			//tr("adding hero at [" + X + "," + Y + "]");
			super(X + tile_offset.x, Y + tile_offset.y);
			
			_playState = playState;
			
			_health = 10;
			_strength = 2;
			_speed = 2;
			_armour = 0;
			
			is_female = (Math.random() < 0.5);
			//tr("new hero, is_female? " + is_female);
			
			_equippables = new FlxSprite(X, Y);
			_equippables.loadGraphic(heroPNG, true, false, TILE_SIZE, TILE_SIZE);
			
			antialiasing = true;
			
			RedoSprite();
		}
		
		override public function update():void {	
			//tr("current tile: " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
			//tr("moving to tile: " + moving_to_tile.type + " at [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			//tr("currently at : [" + x + "," + y + "], moving to [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			
			super.update();
		}
		
		public function RedoSprite():void {
			loadGraphic(heroBasePNG, false, false, TILE_SIZE, TILE_SIZE, true);
			
			//expression
			var expression_frame:int = expression;
			if (is_female) {
				expression_frame += 5;
			} 
			_equippables.frame = expression_frame;
			this.stamp(_equippables);
			
			if (_equipped_helmet != null) {
				_equippables.frame = _equipped_helmet._equippables_frame;
				this.stamp(_equippables);
			} else if (is_female) {
				//female hair
				_equippables.frame = 10;
				this.stamp(_equippables);
			}
			
			if (_equipped_armour != null) {
				_equippables.frame = _equipped_armour._equippables_frame;
				this.stamp(_equippables);
			} else {
				//tunic
				if (is_female) {
					_equippables.frame = 26;
				} else {
					_equippables.frame = 14;
				}
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
			is_taking_turn = true;
			setExpression(EXPRESSION_WORRIED);
			
			var valid_tiles:Array = new Array();
			for each (var tile:Tile in _playState.tiles.members) {
				tile.resetPathingVars();
				tile.setDebugText();

				if (tile != current_tile) {	
					var found_path:Array = _playState.tileManager.findPath(current_tile, tile);
					tile.pathToThis = found_path;
					tile.distance_to_hero = tile.f;
					tile.treasure_value = tile.countCardValue("TREASURE") * 2;
					tile.monsters_between = 0;
					for each (var path_tile:Tile in found_path) {
						tile.monsters_between += path_tile.countCardValue("MONSTER");
					}
					tile.unexplored_area_value = tile.has_visited? 0 : 3;
					for each (var neighbouring_tile:Tile in tile.getConnectedTiles()) {
						tile.unexplored_area_value += neighbouring_tile.has_visited? 0 : 1;
					}
					tile.weighted_value = tile.unexplored_area_value + tile.treasure_value - tile.distance_to_hero - tile.monsters_between;
					
					tile.debug_text_holder.text += "\nVALUE: " + tile.weighted_value;
					tile.debug_text_holder.text += "\n  Explored: +" + tile.unexplored_area_value;
					tile.debug_text_holder.text += "\n  Treasure: +" + tile.treasure_value;
					tile.debug_text_holder.text += "\n  Distance: -" + tile.distance_to_hero;
					tile.debug_text_holder.text += "\n  Monsters: -" + tile.monsters_between;
					
					valid_tiles.push(tile);
				}
			}
			valid_tiles.sortOn("weighted_value", Array.DESCENDING | Array.NUMERIC);
			var best_tile:Tile = valid_tiles.shift();
			best_tile.debug_text_holder.text += "\n\nHEADING OVER HERE";
			var path_to_best_tile:Array = _playState.tileManager.findPath(current_tile, best_tile);
			moving_to_tile = path_to_best_tile[1];
			if (moving_to_tile.x < current_tile.x) {
				facing = LEFT;
			} else if (moving_to_tile.x > current_tile.x) {
				facing = RIGHT;
			}
			
			//show tile search effect
			var delay:Number = 0;
			var flashTime:Number = 0.15;
			for (var i:int = valid_tiles.length - 1; i >= 0; i--) {
				var this_tile:Tile = valid_tiles[i];
				//TweenMax.to(this_tile, flashTime, { alpha:0.7, delay:delay, repeat:1, yoyo:true } );
				TweenMax.delayedCall(delay, drawPath, [this_tile.pathToThis]);
				delay += flashTime;
			}
			TweenMax.to(best_tile, flashTime, { alpha:0.7, delay:delay, repeat:5, yoyo:true } );
			TweenMax.delayedCall(delay, drawPath, [path_to_best_tile]);
			delay += flashTime * 4;
			
			TweenMax.delayedCall(delay, clearPath);
			TweenMax.delayedCall(delay, thinkSomething, ["movement"]);
			TweenMax.delayedCall(delay, followHero);
			TweenMax.delayedCall(THINKING_TIME + delay, startMoving);
		}
		
		public function thinkSomething(thought_type:String, card_clicked:Card = null):void {
			if (TweenMax.isTweening(this)) {
				return;
			}
			
			var thought:String = "";
			if (thought_type == "movement") {
				if (moving_to_tile.cards.length > 0) {
					var top_card:Card = moving_to_tile.cards[moving_to_tile.cards.length - 1];
					switch (top_card._type) {
						case "MONSTER":
							setExpression(EXPRESSION_ANGRY);
							var monster_thoughts:Array = ["Grrr! I hate MONSTERs!!", "That MONSTER is going to get it",
								"Yeah, I THINK I can take it..", "Oh god not a MONSTER", "Well lets get this over with",
								"BANZAAAAAIIIIII", "MONSTERs drop loot, right?"];
							thought = monster_thoughts[Math.floor(Math.random() * (monster_thoughts.length))];
							thought = thought.replace(/MONSTER/g, top_card._title);
							break;
						case "TREASURE":
							setExpression(EXPRESSION_HAPPY);
							var treasure_thoughts:Array = ["SHINY", "That looks a bit like a TREASURE",
								"Is that.. TREASURE!", "THIS is why I'm a dungeoneer!", "Om nyom nyom",
								"Ooh gimme", "TREASURE? TREASURE!", "Cha-CHING!"];
							thought = treasure_thoughts[Math.floor(Math.random() * (treasure_thoughts.length))];
							thought = thought.replace(/TREASURE/g, top_card._title);
							break;
						case "WEAPON":
							setExpression(EXPRESSION_HAPPY);
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
				setExpression(EXPRESSION_ANGRY);
				var poked_thoughts:Array = ["Ow - that hurt!", "Please stop clicking me", "What if I were to poke YOU instead!?",
					"Stop that", "The rulebook clearly says that clicking me doesn't achieve anything", "Cut it out!"];
				thought = poked_thoughts[Math.floor(Math.random() * (poked_thoughts.length))];
			} else if (thought_type == "card_afford") {
				setExpression(EXPRESSION_WORRIED);
				var afford_thoughts:Array = ["No, silly, you need COST CURRENCY before you can play that!", "Playing a CARDNAME costs COST CURRENCY. Even I know that!!",
					"Don't some cards have a cost? Did you skip reading the manual?! ohgodimdoomed", "You need more CURRENCY before you can play that CARDNAME..", 
					"Maybe you need more CURRENCY for that?"];
				thought = afford_thoughts[Math.floor(Math.random() * (afford_thoughts.length))];
				thought = thought.replace(/COST/g, card_clicked._cost);
				thought = thought.replace(/CURRENCY/g, card_clicked._type == "MONSTER" ? "DREAD" : "HOPE");
				thought = thought.replace(/CARDNAME/g, card_clicked._title);
			} else if (thought_type == "card_fit") {
				setExpression(EXPRESSION_SCARED);
				var fit_thoughts:Array = ["I don't think that can fit anywhere right now..", "And just where would that CARDNAME fit?",
					"There's nowhere that can fit that CARDNAME", "That won't fit anywhere!", "There's no space for that CARDNAME!"];
				thought = fit_thoughts[Math.floor(Math.random() * (fit_thoughts.length))];
				thought = thought.replace(/CARDNAME/g, card_clicked._title);
			}
			
			TweenMax.delayedCall(THINKING_TIME, setExpression, [EXPRESSION_HAPPY]);
			TweenMax.to(this, 0.15, { x:x + 1, y:y - 2, bothScale:bothScale + 0.1, repeat:5, yoyo:true } );
			if (thought_type != "idle") {
				_playState.assetManager.PlaySound("dungeoneertalk1");
			}
			_playState.floatingTexts.add(new FloatingText(x + thought_offset.x, y + thought_offset.y, thought));
		}
		
		public function setExpression(newExpression:int):void {
			expression = newExpression;
			RedoSprite();
		}
		
		private function followHero():void {
			_playState.setCameraFollowing(this);
		}
		
		private function drawPath(path:Array):void {
			_playState.pathOverlay.fill(0x00000000);
			Gamb.drawPathAsLine(_playState.pathOverlay, path, 0x991C65AE, 2, 0x995C9CD1);
		}
		
		private function clearPath():void {
			_playState.pathOverlay.fill(0x00000000);
		}
		
		public function startMoving():void {
			_playState.turn_phase = PlayState.PHASE_HERO_MOVING;
			if (current_tile.type.indexOf("room") == 0) {
				_playState.assetManager.PlaySound("doorcreak");
			} else if (current_tile.type.indexOf("corr") == 0) {
				_playState.assetManager.PlaySound("footsteps");
			}
			is_moving = true;
			previous_tile = current_tile;
			TweenLite.to(this, TIME_TO_MOVE_TILES, { x:moving_to_tile.x + tile_offset.x - origin.x, y:moving_to_tile.y + tile_offset.y - origin.y, ease:Back.easeInOut.config(0.8) } );
			TweenMax.delayedCall(TIME_TO_MOVE_TILES, finishedMoving);
		}
		
		private function finishedMoving():void {
			if (!moving_to_tile.has_visited) {
				moving_to_tile.GainGlory();
				moving_to_tile.has_visited = true;
			}
			setCurrentTile(moving_to_tile);
			is_taking_turn = false;
			is_moving = false;
			_playState.heroArrivedAt(moving_to_tile);
			setExpression(EXPRESSION_HAPPY);
		}
		
		public function setCurrentTile(new_tile:Tile):void {
			current_tile = new_tile;
			//x = new_tile.x + tile_offset_x;
			//y = new_tile.y + tile_offset_y;
			//tr("** hero at target tile ** " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
		}
		
		public function processNextCard():void {
			if (current_tile.cards.length == 0) {
				is_processing_cards = false;
				_playState.setCameraFollowing(null);
				_playState.turn_phase = PlayState.PHASE_BOSS_MOVE;
			} else {
				var next_card:Card = current_tile.cards.pop();
				processing_card = next_card;
				//tr("processing card " + next_card._title);
				
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
						_playState.assetManager.PlaySound("coins");
						this.current_tile.GainGlory(next_card._treasure._hope + 1);
					}
					TweenLite.delayedCall(TIME_TREASURE, processNextCard);
				} else if (next_card._type == "MONSTER") {
					//tr("starting battle with monster " + next_card._monster._type + ", frame at " + next_card._monster.frame);
					_playState.StartBattle(next_card._monster);
					setExpression(EXPRESSION_ANGRY);
				}
				is_processing_cards = true;	
			}
		}
		
		public function FightMonster(this_monster:Monster):void {
			if (EquippedSpeed() >= this_monster._speed) {
				//tr("hero attacks first")
				HeroAttacksMonster(this_monster);
				
				if (this_monster._health > 0) {
					MonsterAttacksHero(this_monster);
				}
			} else {
				//tr("monster attacks first")
				MonsterAttacksHero(this_monster);
				
				if (_health > 0) {
					HeroAttacksMonster(this_monster);
				}
			}
		}
		
		public function HeroAttacksMonster(this_monster:Monster):void {
			//tr("hero attacked monster");
			if (EquippedStrength() > this_monster._armour) {
				this_monster._health -= (EquippedStrength() - this_monster._armour);
				_playState.assetManager.PlaySound("swordkill");
			}
			
			if (this_monster._health <= 0) {
				var appearDelay:Number = PlayState.APPEAR_DELAY * 3 + PlayState.BATTLE_TIME;
				//tr("triggering glory etc with delay " + appearDelay);
				TweenLite.delayedCall(appearDelay, MonsterKilledResults, [this_monster]);
			}
		}
		
		public function MonsterAttacksHero(this_monster:Monster):void {
			//tr("monster attacked hero");
			if (this_monster._strength > EquippedArmour()) {
				_health -= (this_monster._strength - EquippedArmour());
				CheckHeroHealth();
			}
		}
		
		public function CheckHeroHealth():void {
			if (_health <= 0) {
				//tr("hero dead");
				_playState.player_alive = false;
				_playState.leaveDungeon();
			}
		}
		
		public function MonsterKilledResults(this_monster:Monster):void {
			_playState.dungeon._hope_level += this_monster._dread + 1;
			_playState.BulgeLabel(_playState.player_hope_label);
			this.current_tile.GainGlory(this_monster._dread * this_monster._dread);
			setExpression(EXPRESSION_HAPPY);
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
		
		public function GetStatsNumbers():String {
			var stats:String = "";
			stats += _health + "\n";
			stats += EquippedStrength() + "\n";
			stats += EquippedSpeed() + "\n";
			stats += EquippedArmour() + "\n";
			return stats;
		}

	}
}