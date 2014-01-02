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
		[Embed(source = "../assets/grid_tile.png")] private var gridTilePNG:Class;
		[Embed(source = "../assets/UI_frame.png")] private var UIFramePNG:Class;
		
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
		public var cardsInHand:FlxGroup = new FlxGroup();
		public var placingSprite:FlxGroup = new FlxGroup();
		public var floatingTexts:FlxGroup = new FlxGroup();
		
		public static const starting_point:Point = new Point(0, 0);
		
		public static const PHASE_NEWTURN:int         = 0; 
		public static const PHASE_CARDS_DEAL:int      = 1;
		public static const PHASE_CARDS_PLAY:int      = 2;
		public static const PHASE_HERO_THINK:int      = 3;
		public static const PHASE_HERO_MOVING:int     = 4;
		public static const PHASE_HERO_CARDS:int      = 5;
		public var turn_phase:int = PHASE_HERO_THINK;
		
		public static const SCROLL_MAXVELOCITY:Number = 800;
		public static const SCROLL_ACCELERATION:Number = 800;
		public static const PLACING_OFFSET:FlxPoint = new FlxPoint(20, 20);
		
		//public static const HAND_START:FlxPoint = new FlxPoint(36, 532);
		//public static const HAND_CARD_OFFSET:int = 200;
		public static const HAND_START:FlxPoint = new FlxPoint(235, 532);
		public static const HAND_CARD_OFFSET:int = 155;
		public static const SHRUNK_HAND_START:FlxPoint = new FlxPoint(235, 682);
		public static const SHRUNK_HAND_CARD_OFFSET:int = 155;
		
		public static const CARDS_PER_TURN:int = 3;
		
		public var placing_card:Card;
		public var is_placing_card:Boolean = false;
		
		public var choosingHighlight:Tile;
		public var choosingTile:Boolean = false;
		
		public var player_alive:Boolean = true;
		public var player_treasure:int = 0;
		public var player_stats_label:FlxText;
		public var player_dread_label:FlxText;
		public var player_hope_label:FlxText;
		public var player_cards_label:FlxText;
		public var endTurnBtn:FlxButtonPlus;
		public var cancelPlacingBtn:FlxButtonPlus;
				
		public var hero:Hero;
		public var camera_target:FlxSprite;
		public var following_hero:Boolean = false;
		public var is_dragging:Boolean = false;
		public var click_start:FlxPoint; //needs to be null at start
		public var dragging_from:FlxPoint = new FlxPoint();
		public var possible_spots:int = 0;
		public var turn_number:int = 0;
		public var cards_played:int = 0;
		
		override public function create():void {
			//FlxG.visualDebug = true;
			//FlxG.camera.setBounds(0, 0, 800, 600);
			//FlxG.worldBounds = new FlxRect(0, 0, 800, 600);
			
			tileManager = new TileManager(this);
			dungeon = new Dungeon(this);
			
			hero = new Hero(this, starting_point.x, starting_point.y - Tile.TILESIZE);
			camera_target = new FlxSprite(hero.x, hero.y);
			camera_target.width = camera_target.height = 0;
			camera_target.maxVelocity = new FlxPoint(SCROLL_MAXVELOCITY, SCROLL_MAXVELOCITY);
			camera_target.drag = new FlxPoint(SCROLL_ACCELERATION, SCROLL_ACCELERATION);
			camera_target.visible = false;
			FlxG.camera.follow(camera_target);

			var starting_tile:Tile;
			starting_tile = new Tile(this, "corr_grate_n", starting_point.x, starting_point.y - Tile.TILESIZE);
			tiles.add(starting_tile);
			hero.setCurrentTile(starting_tile);
			hero.x = starting_tile.x + hero.tile_offset.x - hero.origin.x;
			hero.y = starting_tile.y + hero.tile_offset.y - hero.origin.y;
			starting_tile = new Tile(this, "corr_thin_nesw");
			//starting_tile = new Tile(this, "room_cages_ns");
			addTileAt(starting_tile, starting_point.x, starting_point.y - Tile.TILESIZE - Tile.TILESIZE);
			
			var UIFrame:FlxSprite = new FlxSprite(0, 0, UIFramePNG);
			UIFrame.scrollFactor = new FlxPoint(0, 0);
			
			player_stats_label = new FlxText(45, 15, 150, "stats");
			player_stats_label.setFormat("Crushed", 30, 0xFFEAE2AC, "left", 0xFF6E533F);
			player_stats_label.scrollFactor = new FlxPoint(0, 0);
			guiGroup.add(player_stats_label);
			player_dread_label = new FlxText(FlxG.width - 150 - 45, 15, 150, "Dread: 0");
			player_dread_label.setFormat("Crushed", 30, 0xFFFF8A8A, "right", 0xFFA82C2C);
			player_dread_label.scrollFactor = new FlxPoint(0, 0);
			guiGroup.add(player_dread_label);
			player_hope_label = new FlxText(FlxG.width - 150 - 165, 15, 150, "Hope: 0");
			player_hope_label.setFormat("Crushed", 30, 0xFF8DCDF0, "right", 0xFF025E8F);
			player_hope_label.scrollFactor = new FlxPoint(0, 0);
			guiGroup.add(player_hope_label);
			
			player_cards_label = new FlxText(36, 489, 350, "Play or discard up to 3 more cards");
			player_cards_label.setFormat("Crushed", 24, 0xFFEAE2AC, "left", 0xFF6E533F);
			player_cards_label.scrollFactor = new FlxPoint(0, 0);
			player_cards_label.visible = false;
			guiGroup.add(player_cards_label);
			cancelPlacingBtn = new FlxButtonPlus(893, 474, cancelPlacement, null, "Cancel", 92, 38);
			cancelPlacingBtn.textNormal.setFormat("Crushed", 24, 0xFFEAE2AC, "center", 0xFF6E533F);
			cancelPlacingBtn.textHighlight.setFormat("Crushed", 24, 0xFFEAE2AC, "center", 0xFF6E533F);
			cancelPlacingBtn.borderColor = 0xFFEAE2AC;
			cancelPlacingBtn.updateInactiveButtonColors([0xFFA38C69, 0xFFA38C69]);
			cancelPlacingBtn.updateActiveButtonColors([0xFF6E533F, 0xFF6E533F]);   
			cancelPlacingBtn.visible = false;
			guiGroup.add(cancelPlacingBtn);
			
			highlights.visible = false;
			placingSprite.visible = true;
			
			addCardFromDeck("TILE");
			addCardFromDeck("TILE");
			addCardFromDeck("TILE");
			addCardFromDeck("MONSTER");
			addCardFromDeck("MONSTER");
						
			sndCheer = new WavSound(new WAVcheer() as ByteArray);
			sndCoins = new WavSound(new WAVcoins() as ByteArray);
			sndDeathscream = new WavSound(new WAVdeathscream() as ByteArray);
			sndDoorcreak = new WavSound(new WAVdoorcreak() as ByteArray);
			sndFootsteps = new WavSound(new WAVfootsteps() as ByteArray);
			sndLotsofcoins = new WavSound(new WAVlotsofcoins() as ByteArray);
			sndSwordkill = new WavSound(new WAVswordkill() as ByteArray);
			
			var grid_backdrop:FlxBackdrop = new FlxBackdrop(gridTilePNG, 1.0, 1.0, true, true);
			
			add(grid_backdrop);
			add(tiles);
			add(camera_target);
			add(hero);
			add(highlights);
			add(floatingTexts);
			add(UIFrame);
			add(guiGroup);
			add(cardsInHand);
			add(placingSprite);
		}
		
		override public function update():void {
			
			checkNewTurn();
			checkHero();
			checkPlacing();
			checkMouseClick();
			checkKeyboard();
			
			updateLabels();
			
			//trace("camera_target [" + camera_target.x + ", " + camera_target.y + "], hero [" + hero.x + ", " + hero.y + "]");
			
			super.update();
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
				//trace("newturn");
				turn_number++;
				dungeon.IncreaseDread();
				fillHand(); //todo use PHASE_CARDS_FILLING to animate (and show deck backs)
				showCards();
				cards_played = 0;
				player_cards_label.text = "Play or discard up to 3 more cards";
				cardsInHand.visible = true;
				turn_phase = PHASE_CARDS_PLAY;
			} 
		}
		
		public function updateLabels():void {
			//TODO only update these if any change instead of every frame
			player_stats_label.text = "Treasure: " + player_treasure + "\n"
			                        + "Health: " + hero._health + "\n"
			                        + "Strength: " + hero._strength + "\n"
			                        + "Speed: " + hero._speed + "\n"
			                        + "Armour: " + hero._armour + "\n";
			player_dread_label.text = "Dread: " + dungeon._dread_level;
			player_hope_label.text = "Hope: " + dungeon._hope_level;
		}
		
		public function checkMouseClick():void {
			if (FlxG.mouse.justPressed()) {
				if (checkMouseOverlapsGroup(guiGroup) == null && checkMouseOverlapsGroup(cardsInHand) == null) {
					if (click_start == null) {
						click_start = FlxG.mouse.getScreenPosition();
						//trace("marking click start, waiting for movement from: [" + click_start.x + "," + click_start.y + "]");
					}
				} 
			}
			
			if (click_start != null && !is_dragging) {
				var mouse_now_at:FlxPoint = FlxG.mouse.getScreenPosition();
				var diff_x:int = click_start.x - mouse_now_at.x;
				if (diff_x < 0) {
					diff_x = -diff_x;
				}
				var diff_y:int = click_start.y - mouse_now_at.y;
				if (diff_y < 0) {
					diff_y = -diff_y;
				}
				if (diff_x > 10 || diff_y > 10) {
					is_dragging = true;
					dragging_from = FlxG.mouse.getScreenPosition();
					//trace("dragging_from: [" + dragging_from.x + "," + dragging_from.y + "]");
				}
			}
			
			if (is_dragging && FlxG.mouse.pressed()) {
				var new_position:FlxPoint = FlxG.mouse.getScreenPosition();
				camera_target.x -= new_position.x - dragging_from.x;
				camera_target.y -= new_position.y - dragging_from.y;
				dragging_from = new_position;
			}
			
			if (FlxG.mouse.justReleased()) {
				click_start = null;
			}
			
			if (FlxG.mouse.justReleased() && is_dragging) {
				is_dragging = false;
				dragging_from = null;
			} else if (FlxG.mouse.justReleased() && !is_dragging) {
				var clicked_at:FlxPoint = FlxG.mouse.getWorldPosition();
				if (turn_phase == PHASE_CARDS_PLAY) {
					if (!is_placing_card) {
						clicked_at = FlxG.mouse.getScreenPosition();
						for each (var card_in_hand:Card in cardsInHand.members) {
							if (card_in_hand != null && card_in_hand.alive) {
								if (card_in_hand._background.overlapsPoint(clicked_at) && canAfford(card_in_hand)) {
									
									//trace("clicked on card " + card_in_hand._title);
									possible_spots = 0;
									if (card_in_hand._type == "TILE") {
										for each (var possible_highlight:Tile in highlights.members) {
											if (possible_highlight.alive && card_in_hand._tile.validForHighlight(possible_highlight)) {
												possible_spots++;
											}
										}
									} else {
										for each (var possible_tile:Tile in tiles.members) {
											if (possible_tile != hero.current_tile && possible_tile.validForCard(card_in_hand)) {
												possible_spots++;
											}
										}
									}
									
									if (possible_spots > 0) {
										placing_card = card_in_hand;
										is_placing_card = true;
										card_in_hand.visible = false;
										cleanUpPlacingSprite();
										
										if (placing_card._type == "TILE") {
											var new_placing_card_tile:Card = new Card(this, -1000, -1000, placing_card._type, placing_card._tile);
											new_placing_card_tile._tile.alpha = 0.6;
											placingSprite.add(new_placing_card_tile._tile);
											highlights.visible = true;
											highlights.setAll("visible", false);
											highlights.setAll("alpha", 1);
											for each (var possible_highlight2:Tile in highlights.members) {
												if (possible_highlight2.alive && placing_card._tile.validForHighlight(possible_highlight2)) {
													possible_highlight2.visible = true;
												}
											}											
										} else {
											if (placing_card._type == "MONSTER") {
												var new_placing_card_monster:Card = new Card(this, -1000, -1000, placing_card._type, null, placing_card._monster);
												new_placing_card_monster._monster.alpha = 0.6;
												placingSprite.add(new_placing_card_monster._monster);
											} else {
												var new_placing_card_treasure:Card = new Card(this, -1000, -1000, placing_card._type, null, null, placing_card._treasure);
												new_placing_card_treasure._treasure.alpha = 0.6;
												placingSprite.add(new_placing_card_treasure._treasure);
											}
											for each (var possible_tile2:Tile in tiles.members) {
												if (possible_tile2 != hero.current_tile && possible_tile2.validForCard(placing_card)) {
													possible_tile2.flashing = true;
												}
											}
										}
										
										selectedCard();
										//trace("placingSprite.countLiving(): " + placingSprite.countLiving());
									}
								}
							}
						}
					} else {
						//trace("placing card " + placing_card._title);
						if (placing_card._type == "TILE") {
							for each (var highlight:Tile in highlights.members) {
								if (highlight.alive && highlight.overlapsPoint(clicked_at) && placing_card._tile.validForHighlight(highlight)) {
									var new_tile:Tile = new Tile(this, placing_card._tile.type);
									var justAdded:Tile = addTileAt(new_tile, highlight.x, highlight.y);
									highlight.kill()
									is_placing_card = false;
									highlights.visible = false;
								} 
							}
						} else {
							for each (var tile:Tile in tiles.members) {
								if (tile != hero.current_tile && tile.validForCard(placing_card) && tile.overlapsPoint(clicked_at)) {
									//trace("clicked on tile " + tile.type + " at [" + tile.x + "," + tile.y + "]");
									tile.addCard(placing_card);
									is_placing_card = false;
									tiles.setAll("alpha", 1);
									tiles.setAll("flashing", false);
								} 
							}
						}
						
						if (!is_placing_card) {
							cancelPlacingBtn.visible = false;
							payForCard(placing_card);
							cardsInHand.remove(placing_card, true);
							cleanUpPlacingSprite();
							incrementCardsPlayed();
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
					//discardAndContinue();
				}
			}
			
			//camera movement
			camera_target.acceleration.x = camera_target.acceleration.y = 0;
			if (following_hero && !is_dragging) {
				FlxVelocity.moveTowardsPoint(camera_target, new FlxPoint(hero.x, hero.y + 130), 0, 300);
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
		
		public function checkMouseOverlapsGroup(object:*):FlxObject {
			if (object == null) {
				return null;
			} else if (object is FlxGroup) {
				//trace("flxgroup found, recursing. " + object);
				for each (var member:* in object.members) {
					var this_one:FlxObject = checkMouseOverlapsGroup(member);
					if (this_one != null) {
						//trace("found one");
						return this_one;
					}
				}
			} else {
				//trace("object found, checking. " + object);
				if (object.overlapsPoint(FlxG.mouse.getScreenPosition())) {
					return object;
				}
			}

			//trace ("returning null");
			return null;
		}
		
		public function canAfford(card:Card):Boolean {
			//trace("canAfford " + card._type + " : " + card._title + " for cost " + card._cost + "?");
			if (card._type == "MONSTER") {
				return (dungeon._dread_level >= card._cost);
			} else if (card._type == "TREASURE") {
				return (dungeon._hope_level >= card._cost);
			} else {
				return true;
			}
		}
		
		public function payForCard(card:Card):void {
			if (card._type == "MONSTER") {
				dungeon._dread_level -= card._cost;
			} else if (card._type == "TREASURE") {
				dungeon._hope_level -= card._cost;
			} 
		}
		
		
		public function fillHand():void {
			var cards_in_hand:int = cardsInHand.countLiving();
			if (cards_in_hand < 0) {
				cards_in_hand = 0;
			}
			
			var cards_to_add:int = 5 - cards_in_hand;
			for (var i:int = 0; i < cards_to_add; i++) {
				addCardFromDeck(); //TODO recycle members of flxgroup instead
			}

			//todo fill hand
			cardsInHand.visible = true;
		}
		
		public function sortHand():void {
			var cards_so_far:int = 0;
			for each (var card_in_hand:Card in cardsInHand.members) {
				if (card_in_hand != null && card_in_hand.alive) {
					card_in_hand._moving_to = new FlxPoint(HAND_START.x + cards_so_far * HAND_CARD_OFFSET, HAND_START.y);
					card_in_hand._is_moving = true;
					//trace("moving card " + card_in_hand._title + " from x: " + card_in_hand._background.x + " to x: " + card_in_hand._moving_to.x + " for card slot " + cards_so_far);
					//TODO occasional sorting issue
					cards_so_far++;
				}
			}
		}
		
		public function addCardFromDeck(type:String = ""):void {
			//trace("adding card from deck " + type);
			//trace("cardsInHand.countLiving(): " + cardsInHand.countLiving());
			
			var total_tile:int = 0;
			var total_monster:int = 0;
			var total_treasure:int = 0;
			for each (var card_in_hand:Card in cardsInHand.members) {
				if (card_in_hand != null && card_in_hand.alive) {
					if (card_in_hand._type == "TILE") {
						total_tile++;
					} else if (card_in_hand._type == "MONSTER") {
						total_monster++;
					} else {
						total_treasure++;
					}
				}
			}
			//trace("total_tile: " + total_tile + ", total_monster: " + total_monster + ", total_treasure: " + total_treasure);
			if (type == "") {
				var possible_types:Array = ["TILE", "TILE", "TILE", "MONSTER", "MONSTER", "TREASURE"];
				if (total_tile == 0) {
					possible_types.push("TILE");
					possible_types.push("TILE");
					possible_types.push("TILE");
				}
				if (total_monster == 0) {
					possible_types.push("MONSTER");
					possible_types.push("MONSTER");
				}
				if (total_treasure == 0) {
					possible_types.push("TREASURE");
				}
				
				type = possible_types[Math.floor(Math.random() * (possible_types.length))]
			}
			
			var cards_so_far:int = cardsInHand.countLiving();
			if (cards_so_far < 0) {
				cards_so_far = 0;
			}
			var possible_card:Card;
			var card_point:FlxPoint = new FlxPoint(HAND_START.x + cards_so_far * HAND_CARD_OFFSET, HAND_START.y);
			switch (type) {
				case "TILE":
					var valid_entrances:Array = new Array();
					for each (var h:Tile in highlights.members) {
						if (h.alive) {
							//trace("adding entrances for highlight at [" + Math.floor(h.x / Tile.TILESIZE) + "," + Math.floor(h.y / Tile.TILESIZE) + "] with validHighlightEntrances(): " + h.validHighlightEntrances() );
							valid_entrances = valid_entrances.concat(h.validHighlightEntrances());
							//trace("after concat valid_entrances: " + valid_entrances);
						}
					}
					var possible_tile:Tile = tileManager.GetRandomTile(valid_entrances);
					possible_card = new Card(this, card_point.x, card_point.y, "TILE", possible_tile);
					break;
				case "MONSTER":
					var possible_monster:Monster = dungeon.GetRandomMonster();
					possible_card = new Card(this, card_point.x, card_point.y, "MONSTER", null, possible_monster);
					break;
				case "TREASURE":
					var possible_treasure:Treasure = dungeon.GetRandomTreasure();
					possible_card = new Card(this, card_point.x, card_point.y, "TREASURE", null, null, possible_treasure);
					break;
				default:
					throw new Error("no matching card type defined for " + type);
			}
			
			//possible_card.toggleSize();
			possible_card.setAll("scrollFactor", new FlxPoint(0, 0));
			cardsInHand.add(possible_card);
			
		}
		
		public function selectedCard():void {
			placingSprite.setAll("visible", true);
			placingSprite.setAll("scrollFactor", new FlxPoint(0, 0));
			cancelPlacingBtn.visible = true;
		}
		
		public function cancelPlacement():void {
			if (is_placing_card) {
				//trace("cancel placement");
				is_placing_card = false;
				cancelPlacingBtn.visible = false;
				highlights.visible = false;
				tiles.setAll("alpha", 1);
				tiles.setAll("flashing", false);
				placing_card.visible = true;
				
				cleanUpPlacingSprite()
			}
		}
		
		public function cleanUpPlacingSprite():void {
			for each (var object:* in placingSprite.members) {
				placingSprite.remove(object, true);
				object.kill();
			}
		}
		
		public function discardCard(card_to_discard:Card):void {
			//trace("discarding card " + card_to_discard._title);
			card_to_discard.kill();
			cardsInHand.remove(card_to_discard, true);
			incrementCardsPlayed();
		}
		
		public function endCardPlaying():void {
			hideCards();
			sortHand();
			turn_phase = PHASE_HERO_THINK;
		}
		
		public function hideCards():void {
			cardsInHand.callAll("showBack", false);
			cancelPlacingBtn.visible = false;
			player_cards_label.visible = false;
		}
		
		public function showCards():void {
			cardsInHand.callAll("showFront", false);
			player_cards_label.visible = true;
		}
		
		public function incrementCardsPlayed():void {
			cards_played += 1;
			var cards_left:int = CARDS_PER_TURN - cards_played;
			player_cards_label.text = "Play or discard up to " + cards_left + " more cards";
			if (cards_left <= 1) {
				player_cards_label.text = "Play or discard " + cards_left + " more card";
			}
			
			if (cards_played >= CARDS_PER_TURN) {
				endCardPlaying();
			}
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
					//trace ("(in addTileAt) checking " + direction + " for tile of type " + tile.type);
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
						
						//don't add highlight if that tile is already filled with a tile
						var filled:Boolean = false;
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
			//don't add highlight new highlight tile if one already exists for that space
			var filled:Boolean = false;
			for each (var this_highlight:Tile in highlights.members) {
				if (this_highlight.x == X && this_highlight.y == Y) {
					//trace("setting additional entrance for highlight at [" + Math.floor(X / Tile.TILESIZE) + "," + Math.floor(Y / Tile.TILESIZE) + "] with entrance " + from_direction + " " + Tile.directionName(from_direction));
					this_highlight.setHighlightEntrance(Tile.oppositeDirection(from_direction));
					filled = true;
					break;
				}
			}
			
			if (!filled) {
				var new_highlight:Tile = new Tile(this, "highlight", X, Y);
				//trace("adding highlight at [" + Math.floor(X / Tile.TILESIZE) + "," + Math.floor(Y / Tile.TILESIZE) + "] with entrance " + from_direction + " " + Tile.directionName(from_direction));
				new_highlight.setHighlightEntrance(Tile.oppositeDirection(from_direction));
				highlights.add(new_highlight);
			}
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