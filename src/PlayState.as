package
{
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.*;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import org.as3wavsound.*;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
 
	public class PlayState extends FlxState
	{
		[Embed(source = "../assets/gui_overlay.png")] private var ARTguiOverlay:Class;
		[Embed(source = "../assets/skull_bolt_t.png")] private var ARTskullBolt:Class;
		
		[Embed(source = "../assets/cheer.wav", mimeType = "application/octet-stream")] private const WAVcheer:Class;
		[Embed(source = "../assets/coins.wav", mimeType = "application/octet-stream")] private const WAVcoins:Class;
		[Embed(source = "../assets/deathscream.wav", mimeType = "application/octet-stream")] private const WAVdeathscream:Class;
		[Embed(source = "../assets/doorcreak.wav", mimeType = "application/octet-stream")] private const WAVdoorcreak:Class;
		[Embed(source = "../assets/footsteps.wav", mimeType = "application/octet-stream")] private const WAVfootsteps:Class;
		[Embed(source = "../assets/lots_of_coins.wav", mimeType = "application/octet-stream")] private const WAVlotsofcoins:Class;
		[Embed(source = "../assets/sword_kill.wav", mimeType = "application/octet-stream")] private const WAVswordkill:Class;
		public var sndCheer:WavSound;
		public var sndCoins:WavSound;
		public var sndDeathscream:WavSound;
		public var sndDoorcreak:WavSound;
		public var sndFootsteps:WavSound;
		public var sndLotsofcoins:WavSound;
		public var sndSwordkill:WavSound;
		
		public var tileManager:TileManager;
		public var dungeon:Dungeon;
		public var tiles:FlxGroup = new FlxGroup();
		public var highlights:FlxGroup = new FlxGroup();
		public var guiGroup:FlxGroup = new FlxGroup();
		public var questionMarks:FlxSprite;
		public var cardDecks:FlxGroup = new FlxGroup();
		public var cardsInHand:FlxGroup = new FlxGroup();
		public var placingSprite:FlxGroup = new FlxGroup();
		public var floatingTexts:FlxGroup = new FlxGroup();
		public var dread_icons:Array = [];
		
		public static const starting_point:Point = new Point(358, 578);
		
		public static const PHASE_NEWTURN:int      = 0; 
		public static const PHASE_CARDS_PICK:int   = 1;
		public static const PHASE_CARDS_PLAY:int   = 2;
		public static const PHASE_HERO_THINK:int   = 3;
		public static const PHASE_HERO_MOVING:int  = 4;
		public static const PHASE_HERO_CARDS:int   = 5;
		public var turn_phase:int = PHASE_HERO_THINK;
		
		public static const SCROLL_MAXVELOCITY:Number = 800;
		public static const SCROLL_ACCELERATION:Number = 800;
		public static const PLACING_OFFSET:FlxPoint = new FlxPoint(20, 20);
		
		public static const HAND_START:FlxPoint = new FlxPoint(225, 50);
		public static const HAND_CARD_OFFSET:int = 250;
		public static const SHRUNK_HAND_START:FlxPoint = new FlxPoint(350, 220);
		public static const SHRUNK_HAND_CARD_OFFSET:int = 100;
		public static const DREAD_ICON_START:FlxPoint = new FlxPoint(479, 262);
		public static const DREAD_ICON_OFFSET:int = 29;
		
		public var placing_card:Card;
		public var is_placing_card:Boolean = false;
		
		public var choosingHighlight:Tile;
		public var choosingTile:Boolean = false;
		
		public var treasure_icon_left:FlxSprite, monster_icon_left:FlxSprite, treasure_icon_right:FlxSprite, monster_icon_right:FlxSprite;
		public var treasure_icon_label_left:FlxText, monster_icon_label_left:FlxText, treasure_icon_label_right:FlxText, monster_icon_label_right:FlxText; 
		
		public var player_alive:Boolean = true;
		public var player_treasure:int = 0;
		public var player_life:int = 5;
		public var player_treasure_label:FlxText, player_life_label:FlxText;
				
		public var hero:Hero;
		public var camera_target:FlxSprite;
		public var following_hero:Boolean = false;
		public var possible_spots:int = 0;
		public var turn_number:int = 0;
		public var dread_cards_chosen:int = 0;
		
		override public function create():void {
			//FlxG.visualDebug = true;
			//FlxG.camera.setBounds(0, 0, 800, 600);
			//FlxG.worldBounds = new FlxRect(0, 0, 800, 600);
			
			tileManager = new TileManager(this);
			dungeon = new Dungeon(this);
			
			hero = new Hero(this, starting_point.x, starting_point.y - Tile.TILESIZE);
			camera_target = new FlxSprite(hero.x, hero.y);
			//TODO: fix this being a few pixels off at the start
			//camera_target = new FlxSprite(hero.x + hero.origin.x, hero.y + hero.origin.y);
			camera_target.width = camera_target.height = 0;
			camera_target.maxVelocity = new FlxPoint(SCROLL_MAXVELOCITY, SCROLL_MAXVELOCITY);
			camera_target.drag = new FlxPoint(SCROLL_ACCELERATION, SCROLL_ACCELERATION);
			camera_target.visible = false;
			FlxG.camera.follow(camera_target);

			var starting_tile:Tile;
			starting_tile = new Tile(this, "corr_grate_n", starting_point.x, starting_point.y - Tile.TILESIZE);
			tiles.add(starting_tile);
			hero.setCurrentTile(starting_tile);
			starting_tile = new Tile(this, "corr_thin_nesw");
			addTileAt(starting_tile, starting_point.x, starting_point.y - Tile.TILESIZE - Tile.TILESIZE);
			
			var guiOverlay:FlxSprite = new FlxSprite(0, 0, ARTguiOverlay);
			//guiGroup.add(guiOverlay);
			player_treasure_label = new FlxText(6, 6, 300, "Treasure: 0");
			player_treasure_label.setFormat("Crushed", 30, 0xFFFF8A8A, "left", 0x000000);
			player_treasure_label.scrollFactor = new FlxPoint(0, 0);
			guiGroup.add(player_treasure_label);
			var leaveBtn:FlxButtonPlus = new FlxButtonPlus(330, 10, leaveDungeon, null, "Leave The Dungeon", 220, 28);
			leaveBtn.textNormal.setFormat("Crushed", 16, 0xFF812222, "center", 0);
			leaveBtn.textHighlight.setFormat("Crushed", 16, 0xFF812222, "center", 0);
			leaveBtn.borderColor = 0xFF5C3425;
			leaveBtn.updateInactiveButtonColors([0xFFFFCCCC, 0xFFFF8A8A]);
			leaveBtn.updateActiveButtonColors([0xFFFF8A8A, 0xFFFFCCCC]);	
			leaveBtn.screenCenter();
			//leaveBtn.scrollFactor = new FlxPoint(0, 0);
			guiGroup.add(leaveBtn);
			player_life_label = new FlxText(FlxG.width - 300 - 6, 6, 300, "Life: 5");
			player_life_label.setFormat("Crushed", 30, 0xFFFF8A8A, "right", 0x000000);
			player_life_label.scrollFactor = new FlxPoint(0, 0);
			guiGroup.add(player_life_label);
			var dread_icon:FlxSprite;
			for (var d:int = 0; d < 5; d++) {
				 dread_icon = new FlxSprite(DREAD_ICON_START.x + (d * DREAD_ICON_OFFSET), DREAD_ICON_START.y, ARTskullBolt);
				 dread_icon.visible = false;
				 dread_icon.alpha = 0.8;
				 dread_icon.scrollFactor = new FlxPoint(0, 0);
				 guiGroup.add(dread_icon);
				 dread_icons.push(dread_icon);
			}
			
			highlights.visible = false;
			placingSprite.visible = true;
			
			var card_deck:Card;
			card_deck = new Card(this, HAND_START.x + 0 * HAND_CARD_OFFSET, HAND_START.y, "TILE");
			card_deck.setAll("scrollFactor", new FlxPoint(0, 0));
			cardDecks.add(card_deck);
			card_deck = new Card(this, HAND_START.x + 1 * HAND_CARD_OFFSET, HAND_START.y, "MONSTER");
			card_deck.setAll("scrollFactor", new FlxPoint(0, 0));
			cardDecks.add(card_deck);
			card_deck = new Card(this, HAND_START.x + 2 * HAND_CARD_OFFSET, HAND_START.y, "TREASURE");
			card_deck.setAll("scrollFactor", new FlxPoint(0, 0));
			card_deck.visible = false;
			cardDecks.add(card_deck);
			cardDecks.visible = false;
						
			sndCheer = new WavSound(new WAVcheer() as ByteArray);
			sndCoins = new WavSound(new WAVcoins() as ByteArray);
			sndDeathscream = new WavSound(new WAVdeathscream() as ByteArray);
			sndDoorcreak = new WavSound(new WAVdoorcreak() as ByteArray);
			sndFootsteps = new WavSound(new WAVfootsteps() as ByteArray);
			sndLotsofcoins = new WavSound(new WAVlotsofcoins() as ByteArray);
			sndSwordkill = new WavSound(new WAVswordkill() as ByteArray);

			add(tiles);
			add(camera_target);
			add(hero);
			add(highlights);
			add(floatingTexts);
			add(guiGroup);
			add(cardsInHand);
			add(cardDecks);
			add(placingSprite);
		}
		
		override public function update():void {
			checkControls();
			
			player_treasure_label.text = "Treasure: " + player_treasure;
			player_life_label.text = "Life: " + player_life;
			
			//trace("camera_target [" + camera_target.x + ", " + camera_target.y + "], hero [" + hero.x + ", " + hero.y + "]");
			
			super.update();
		}
		
		private function checkControls():void {
			checkNewTurn();
			checkHero();
			checkPlacing();
			checkMouseHover();
			checkMouseClick();
			checkKeyboard();
		}
		
		public function checkHero():void {
			if (turn_phase == PHASE_HERO_THINK && !hero.is_taking_turn) {
				//trace("starting hero turn");
				hero.startTurn();
			} else if (turn_phase == PHASE_HERO_CARDS && !hero.is_processing_cards) {
				hero.processNextCard();
			}
		}
				
		public function heroArrivedAt(tile:Tile):void {
			//trace("heroArrivedAt, changing to PHASE_HERO_CARDS");
			turn_phase = PlayState.PHASE_HERO_CARDS;
		}
		
		public function checkPlacing():void {
			if (turn_phase == PHASE_CARDS_PLAY && is_placing_card) {
				placingSprite.setAll("x", FlxG.mouse.screenX + PLACING_OFFSET.x);
				placingSprite.setAll("y", FlxG.mouse.screenY + PLACING_OFFSET.y);
			}
		}
		
		public function checkNewTurn():void {
			if (turn_phase == PHASE_NEWTURN) {
				trace("newturn");
				turn_number++;
				dungeon.IncreaseDread();
				chooseCards();
				turn_phase = PHASE_CARDS_PICK;
				cardsInHand.visible = true;
			} 
		}
		
		public function updateDreadLevel():void {
			for (var d:int = 0; d < 5; d++) {
				dread_icons[d].visible = false;
				if (dungeon._dread_level > d) {
					dread_icons[d].visible = true;
				}
			}
		}
		
		public function hideDreadLevel():void {
			for (var d:int = 0; d < 5; d++) {
				dread_icons[d].visible = false;
			}
		}
		
		public function checkMouseHover():void {
			
		}
		
		public function checkMouseClick():void {
			if (FlxG.mouse.justReleased()) {
				var clicked_at:FlxPoint = FlxG.mouse.getWorldPosition();
				if (turn_phase == PHASE_CARDS_PICK) {
					clicked_at = FlxG.mouse.getScreenPosition();
					for each (var card_deck:Card in cardDecks.members) {
						if (card_deck != null && card_deck.alive && card_deck.visible) {
							if (card_deck._background.overlapsPoint(clicked_at)) {
								addCardFromDeck(card_deck._type);
								if (card_deck._type == "MONSTER") {
									dread_cards_chosen++;
									if (dread_cards_chosen > dungeon._dread_level) {
										dread_cards_chosen = -5;
										dungeon.ReduceDread();
									}
								} else if (card_deck._type == "TREASURE") {
									dungeon._hope_level -= 1;
									checkHope();
								}
							}
						}
					}
				} else if (turn_phase == PHASE_CARDS_PLAY) {
					if (!is_placing_card) {
						clicked_at = FlxG.mouse.getScreenPosition();
						for each (var card_in_hand:Card in cardsInHand.members) {
							if (card_in_hand != null && card_in_hand.alive) {
								if (card_in_hand._background.overlapsPoint(clicked_at)) {
									//trace("clicked on card " + card_in_hand._title);
									placing_card = card_in_hand;
									placing_card.flipCard();
									is_placing_card = true;
									cardsInHand.remove(card_in_hand);
									cardsInHand.visible = false;
									for each (var object:* in placingSprite.members) {
										placingSprite.remove(object, true);
										object.kill();
									}
									if (placing_card._type == "TILE") {
										placing_card._tile.alpha = 0.6;
										placingSprite.add(placing_card._tile);
										highlights.visible = true;
										highlights.setAll("visible", false);
										highlights.setAll("alpha", 1);
										possible_spots = 0;
										for each (var possible_highlight:Tile in highlights.members) {
											if (possible_highlight.alive && placing_card._tile.checkExit(possible_highlight.highlight_entrance)) {
												possible_highlight.visible = true;
												possible_spots++;
											}
										}
										if (possible_spots == 0) {
											discardAndContinue();
										}
									} else {
										if (placing_card._type == "MONSTER") {
											placing_card._monster.alpha = 0.6;
											placingSprite.add(placing_card._monster);
										} else {
											placing_card._sprite.alpha = 0.6;
											placingSprite.add(placing_card._sprite);
										}
										possible_spots = 0;
										for each (var possible_tile:Tile in tiles.members) {
											if (possible_tile != hero.current_tile && possible_tile.validForCard(placing_card)) {
												possible_tile.flashing = true;
												possible_spots++;
											}
										}
										if (possible_spots == 0) {
											discardAndContinue();
										}
									}
									placingSprite.setAll("visible", true);
									placingSprite.setAll("scrollFactor", new FlxPoint(0, 0));
									//trace("placingSprite.countLiving(): " + placingSprite.countLiving());
								}
							}
						}
					} else {
						//trace("placing card " + placing_card._title);
						if (placing_card._type == "TILE") {
							for each (var highlight:Tile in highlights.members) {
								if (highlight.alive && highlight.overlapsPoint(clicked_at) && placing_card._tile.checkExit(highlight.highlight_entrance)) {
									var new_tile:Tile = new Tile(this, placing_card._tile.type);
									var justAdded:Tile = addTileAt(new_tile, highlight.x, highlight.y);
									highlight.kill()
									placing_card.kill();
									is_placing_card = false;
									highlights.visible = false;
								} 
							}
						} else {
							for each (var tile:Tile in tiles.members) {
								if (tile != hero.current_tile && tile.validForCard(placing_card) && tile.overlapsPoint(clicked_at)) {
									//trace("clicked on tile " + tile.type + " at [" + tile.x + "," + tile.y + "]");
									tile.addCard(placing_card);
									placing_card.kill();
									is_placing_card = false;
									tiles.setAll("alpha", 1);
									tiles.setAll("flashing", false);
								} 
							}
						}
						
						if (!is_placing_card) {
							if (cardsInHand.countLiving() > 0) {
								cardsInHand.visible = true;
							} else {
								clearCards();
								hideDreadLevel();
								cardsInHand.visible = false;
								turn_phase = PHASE_HERO_THINK;
							}
						}
					}
				}
			}
			
		}
		
		public function checkKeyboard():void {
			if (FlxG.keys.justReleased("SPACE")) {
				trace("*** RESET ***");
				FlxG.switchState(new MenuState);
			} else if (FlxG.keys.justReleased("D")) {
				trace("*** Toggle Debug ***");
				FlxG.visualDebug = !FlxG.visualDebug;
			} else if (FlxG.keys.justReleased("X")) {
				if (turn_phase == PHASE_CARDS_PLAY) {
					discardAndContinue();
				}
			}
			
			//camera movement
			camera_target.acceleration.x = camera_target.acceleration.y = 0;
			if (following_hero) {
				FlxVelocity.moveTowardsObject(camera_target, hero, 0, 300);
			} else {
				if (FlxG.keys.UP) {
					camera_target.acceleration.y -= SCROLL_ACCELERATION;
				}
				if (FlxG.keys.DOWN) {
					camera_target.acceleration.y += SCROLL_ACCELERATION;
				}
				if (FlxG.keys.LEFT) {
					camera_target.acceleration.x -= SCROLL_ACCELERATION;
				}
				if (FlxG.keys.RIGHT) {
					camera_target.acceleration.x += SCROLL_ACCELERATION;
				}
			}
		}
		
		public function discardAndContinue():void {
			clearCards();
			cardsInHand.visible = false;
			if (placing_card != null) {
				placing_card.kill();
			}
			is_placing_card = false;
			highlights.visible = false;
			tiles.setAll("alpha", 1);
			tiles.setAll("flashing", false);
			turn_phase = PHASE_HERO_THINK;
		}
		
		public function chooseCards():void {
			clearCards();
			
			dread_cards_chosen = 0;
			checkHope();
			cardDecks.visible = true;
			updateDreadLevel();
			cardsInHand.visible = true;
		}
		
		public function checkHope():void {
			for each (var card_deck:Card in cardDecks.members) {
				if (card_deck._type == "TREASURE") {
					if (dungeon._hope_level > 0) {
						card_deck.visible = true;
					} else {
						card_deck.visible = false;
					}
				}
			}
		}
		
		public function addCardFromDeck(type:String):void {
			//trace("adding card from deck " + type);
			//trace("cardsInHand.countLiving(): " + cardsInHand.countLiving());
			
			var cards_so_far:int = cardsInHand.countLiving();
			if (cards_so_far < 0) {
				cards_so_far = 0;
			}
			var possible_card:Card;
			var card_point:FlxPoint = new FlxPoint(SHRUNK_HAND_START.x + cards_so_far * SHRUNK_HAND_CARD_OFFSET, SHRUNK_HAND_START.y);
			switch (type) {
				case "TILE":
					var valid_entrances:Array = new Array();
					for each (var h:Tile in highlights.members) {
						if (h.alive) {
							//trace("adding entrances for highlight at [" + Math.floor(h.x / Tile.TILESIZE) + "," + Math.floor(h.y / Tile.TILESIZE) + "]: " + Tile.directionName(h.highlight_entrance) );
							valid_entrances.push(h.highlight_entrance);
						}
					}
					var possible_tile:Tile = tileManager.GetRandomTile(valid_entrances);
					possible_card = new Card(this, card_point.x, card_point.y, "TILE", "", possible_tile);
					break;
				case "MONSTER":
					var possible_monster:Monster = dungeon.GetRandomMonster();
					possible_card = new Card(this, card_point.x, card_point.y, "MONSTER", possible_monster._type, null, possible_monster);
					break;
				case "TREASURE":
					possible_card = new Card(this, card_point.x, card_point.y, "TREASURE");
					break;
				default:
					throw new Error("no matching card type defined for " + type);
			}
			
			possible_card.toggleSize();
			possible_card.setAll("scrollFactor", new FlxPoint(0, 0));
			cardsInHand.add(possible_card);
			
			if (cards_so_far >= 2) {
				//trace("full hand");
				playCards();
			}
		}
		
		public function playCards():void {
			turn_phase = PHASE_CARDS_PLAY;
			cardDecks.visible = false;
			hideDreadLevel();
			
			//cardsInHand.callAll("toggleSize", false);
			//cardsInHand.callAll("flipCard", false);
			
			var card_no:int = 0;
			for each (var card_in_hand:Card in cardsInHand.members) {
				card_in_hand.toggleSize();
				card_in_hand.flipCard();
				card_in_hand._moving_to = new FlxPoint(HAND_START.x + card_no * HAND_CARD_OFFSET, HAND_START.y); 
				card_in_hand._is_moving = true;
				card_no++;
			}
		}
		
		public function clearCards():void {
			//trace("cardsInHand..countLiving(): " + cardsInHand.countLiving());
			for each (var clear_card:Card in cardsInHand.members) {
				if (clear_card != null && clear_card.alive) {
					//trace(" - clearing card " + clear_card._title);
					cardsInHand.remove(clear_card, true);
					clear_card.kill();
				}
			}
			cardsInHand.clear();  //TODO, this is a possible memory leak
		}
		
		public function getTileAt(point:FlxPoint):Tile {
			for each (var t:Tile in tiles.members) {
				//trace("checking tile " + t.type + " at [" + t.x + "," + t.y + "]");
				if (t.x == point.x && t.y == point.y) {
					return t;
				}
			}
			
			return null;
		}
		
		public function addTileAt(tile:Tile, X:int, Y:int):Tile {
			tile.x = X;
			tile.y = Y;
			tiles.add(tile);
			//trace("adding tile at " + X + "," + Y);
			
			if (tile.type.indexOf("corr") == 0 || tile.type.indexOf("room") == 0) { 
				for each (var direction:int in tileManager.all_directions) {
					//trace ("checking " + direction + " for tile of type " + tile.type);
					if (tile.checkExit(direction)) {
						//trace("adding new highlight to " + direction);
						var new_x:int = X;
						var new_y:int = Y;
						if (direction == TileManager.NORTH)
							new_y -= Tile.TILESIZE;
						else if (direction == TileManager.EAST)
							new_x += Tile.TILESIZE;
						else if (direction == TileManager.SOUTH)
							new_y += Tile.TILESIZE;
						else if (direction == TileManager.WEST)
							new_x -= Tile.TILESIZE;
						
						//don't add highlight if that tile is already filled 
						var filled:Boolean = false;
						for each (var this_highlight:Tile in highlights.members) {
							if (this_highlight.x == new_x && this_highlight.y == new_y) {
								filled = true;
								break;
							}
						}
						for each (var this_tile:Tile in tiles.members) {
							if (this_tile.x == new_x && this_tile.y == new_y) {
								//trace("direction " + direction + " filled by " + this_tile.type);
								filled = true;
								break;
							}
						}
						
						if (!filled) { 
							addHighlight(new_x, new_y, direction);
						}
					}
					
				}
			}
			return tile;
		}
		
		public function addHighlight(X:int, Y:int, from_direction:int):void {
			var new_highlight:Tile = new Tile(this, "highlight", X, Y);
			//trace("adding highlight at [" + X + "," + Y + "] with entrance " + from_direction);
			new_highlight.highlight_entrance = Tile.oppositeDirection(from_direction);
			highlights.add(new_highlight);
		}
		
		public function leaveDungeon():void {
			if (player_alive) {
				sndCheer.play();
			} else {
				sndDeathscream.play();
			}
			FlxG.switchState(new MenuState(true, player_alive, player_treasure));
		}
	}
}