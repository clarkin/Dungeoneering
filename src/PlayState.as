package
{
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.*;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import org.as3wavsound.*;
	import flash.utils.ByteArray;
 
	public class PlayState extends FlxState
	{
		[Embed(source = "../assets/question_marks.png")] private var ARTquestionMarks:Class;
		[Embed(source = "../assets/gui_overlay.png")] private var ARTguiOverlay:Class;
		[Embed(source = "../assets/crown_coin.png")] private var ARTcrownCoin:Class;
		[Embed(source = "../assets/spectre.png")] private var ARTspectre:Class;
		
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
		public var tiles:FlxGroup = new FlxGroup();
		public var highlights:FlxGroup = new FlxGroup();
		public var explorationChoice:FlxGroup = new FlxGroup();
		public var guiGroup:FlxGroup = new FlxGroup();
		public var questionMarks:FlxSprite;
		public var explorationTiles:FlxGroup = new FlxGroup();
		public var cardsInHand:FlxGroup = new FlxGroup();
		public var placingSprite:FlxGroup = new FlxGroup();
		public var floatingTexts:FlxGroup = new FlxGroup();
		
		public static const starting_point:Point = new Point(358, 578);
		
		public static const PHASE_NEWTURN:int = 0; 
		public static const PHASE_CARDS:int = 1;
		public static const PHASE_HERO_THINK:int = 2;
		public static const PHASE_HERO_MOVING:int = 3;
		public static const PHASE_HERO_CARDS:int = 4;
		public var turn_phase:int = PHASE_HERO_THINK;
		
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
		
		public var treasure_tile:Tile;
		public var treasure_tile_linked:Boolean = false;
		
		public var hero:Hero;
		
		override public function create():void {
			//FlxG.visualDebug = true;
			FlxG.camera.setBounds(0, 0, 800, 600);
			FlxG.worldBounds = new FlxRect(0, 0, 800, 600);
			
			tileManager = new TileManager();
			
			hero = new Hero(this, starting_point.x, starting_point.y - Tile.TILESIZE);
			//hero.is_taking_turn = true;
			
			treasure_tile = new Tile("hint_treasure_room");
			var rand_x:int = Math.floor(Math.random() * 8) - 3;
			var rand_y:int = Math.floor(Math.random() * 4) + 8;
			addTileAt(treasure_tile, starting_point.x + (Tile.TILESIZE * rand_x), starting_point.y - (Tile.TILESIZE * rand_y));
			
			var starting_tile:Tile;
			starting_tile = new Tile("empty", starting_point.x, starting_point.y);
			tiles.add(starting_tile);
			starting_tile = new Tile("corr_dead1", starting_point.x, starting_point.y - Tile.TILESIZE);
			tiles.add(starting_tile);
			hero.setCurrentTile(starting_tile);
			starting_tile = new Tile("corr_fourway");
			addTileAt(starting_tile, starting_point.x, starting_point.y - Tile.TILESIZE - Tile.TILESIZE);
			//hero.setMovingToTile(starting_tile);
			
			var blank_tile:Tile;
			var i:int;
			var new_x:int = starting_point.x;
			var new_y:int = starting_point.y;
			for (i = 1; i <= 10; i++) {
				blank_tile = new Tile("empty");
				new_x += Tile.TILESIZE;
				addTileAt(blank_tile, new_x, new_y);
			}
			for (i = 1; i <= 12; i++) {
				blank_tile = new Tile("empty");
				new_y -= Tile.TILESIZE;
				addTileAt(blank_tile, new_x, new_y);
			}
			for (i = 1; i <= 19; i++) {
				blank_tile = new Tile("empty");
				new_x -= Tile.TILESIZE;
				addTileAt(blank_tile, new_x, new_y);
			}
			for (i = 1; i <= 12; i++) {
				blank_tile = new Tile("empty");
				new_y += Tile.TILESIZE;
				addTileAt(blank_tile, new_x, new_y);
			}
			for (i = 1; i <= 8; i++) {
				blank_tile = new Tile("empty");
				new_x += Tile.TILESIZE;
				addTileAt(blank_tile, new_x, new_y);
			}
			
			var guiOverlay:FlxSprite = new FlxSprite(0, 0, ARTguiOverlay);
			guiGroup.add(guiOverlay);
			player_treasure_label = new FlxText(6, 6, 300, "Treasure: 0");
			player_treasure_label.setFormat("Popup", 30, 0x5C3425, "left", 0x000000);
			guiGroup.add(player_treasure_label);
			var leaveBtn:FlxButtonPlus = new FlxButtonPlus(330, 10, leaveDungeon, null, "Leave The Dungeon", 220, 24);
			leaveBtn.textNormal.setFormat("Popup", 16, 0x5C3425, "center", 0);
			leaveBtn.textHighlight.setFormat("Popup", 16, 0x5C3425, "center", 0);
			leaveBtn.borderColor = 0xFF5C3425;
			leaveBtn.updateInactiveButtonColors([0xFFC2A988, 0xFFFFFFCC]);
			leaveBtn.updateActiveButtonColors([0xFFD54DFF, 0xFFF9E6FF]);	
			leaveBtn.screenCenter();
			guiGroup.add(leaveBtn);
			player_life_label = new FlxText(494, 6, 300, "Life: 5");
			player_life_label.setFormat("Popup", 30, 0x5C3425, "right", 0x000000);
			guiGroup.add(player_life_label);
						
			sndCheer = new WavSound(new WAVcheer() as ByteArray);
			sndCoins = new WavSound(new WAVcoins() as ByteArray);
			sndDeathscream = new WavSound(new WAVdeathscream() as ByteArray);
			sndDoorcreak = new WavSound(new WAVdoorcreak() as ByteArray);
			sndFootsteps = new WavSound(new WAVfootsteps() as ByteArray);
			sndLotsofcoins = new WavSound(new WAVlotsofcoins() as ByteArray);
			sndSwordkill = new WavSound(new WAVswordkill() as ByteArray);

			add(tiles);
			add(hero);
			add(highlights);
			add(floatingTexts);
			add(guiGroup);
			add(cardsInHand);
			add(placingSprite);
			//add(explorationChoice);
		}
		
		override public function update():void {
			checkControls();
			
			player_treasure_label.text = "Treasure: " + player_treasure;
			player_life_label.text = "Life: " + player_life;
			
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
			if (turn_phase == PHASE_CARDS && placing_card != null) {
				placingSprite.setAll("x", FlxG.mouse.x - 24 / 2);
				placingSprite.setAll("y", FlxG.mouse.y - 24 / 2);
			}
		}
		
		public function checkNewTurn():void {
			if (turn_phase == PHASE_NEWTURN) {
				dealCards();
				turn_phase = PHASE_CARDS;
				cardsInHand.visible = true;
			} 
		}
		
		public function checkMouseHover():void {
			
		}
		
		public function checkMouseClick():void {
			if (FlxG.mouse.justReleased()) {
				var clicked_at:FlxPoint = FlxG.mouse.getWorldPosition();
				if (turn_phase == PHASE_CARDS) {
					if (!is_placing_card) {
						for each (var card_in_hand:Card in cardsInHand.members) {
							if (card_in_hand != null && card_in_hand.alive) {
								if (card_in_hand._background.overlapsPoint(clicked_at)) {
									//trace("clicked on card " + card_in_hand._title);
									placing_card = card_in_hand;
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
									} else {
										placing_card._sprite.alpha = 0.6;
										placingSprite.add(placing_card._sprite);
									}
								}
							}
						}
					} else {
						//trace("placing card " + placing_card._title);
						if (placing_card._type == "TILE") {
							for each (var highlight:Tile in highlights.members) {
								if (highlight.alive && highlight.overlapsPoint(clicked_at) && placing_card._tile.checkExit(highlight.highlight_entrance)) {
									var new_tile:Tile = new Tile(placing_card._tile.type);
									var justAdded:Tile = addTileAt(new_tile, highlight.x, highlight.y);
									highlight.kill()
									placing_card.kill();
									is_placing_card = false;
								} 
							}
						} else {
							for each (var tile:Tile in tiles.members) {
								if (tile.overlapsPoint(clicked_at)) {
									//trace("clicked on tile " + tile.type + " at [" + tile.x + "," + tile.y + "]");
									tile.addCard(placing_card);
									placing_card.kill();
									is_placing_card = false;
								} 
							}
						}
						
						if (!is_placing_card) {
							if (cardsInHand.countLiving() > 0) {
								cardsInHand.visible = true;
							} else {
								clearCards();
								cardsInHand.visible = false;
								turn_phase = PHASE_HERO_THINK;
							}
						}
					}
				}
			}
			
			/*
			if (!hero.is_taking_turn && FlxG.mouse.justReleased()) {
				var clicked_at:FlxPoint = FlxG.mouse.getWorldPosition();
				
				if (choosingTile) {
					for each (var explorationTile:Tile in explorationTiles.members) {
						//trace("checking tile at " + explorationTile.x + ", " + explorationTile.y);
						if (explorationTile.overlapsPoint(clicked_at)) {
							chooseTile(explorationTile);
						}
					}
				} else {
					var found_highlight:Boolean = false;
					for each (var highlight:Tile in highlights.members) {
						//trace("checking highlight at " + highlight.x + ", " + highlight.y);
						if (highlight.alive && highlight.overlapsPoint(clicked_at)) {
							//trace("click at " + clicked_at.x + ", " + clicked_at.y);
							//trace("highlight at " + highlight.x + ", " + highlight.y);
							found_highlight = true;
							choosingHighlight = highlight;
							showTileChoice();					
						} 
					}
					if (treasure_tile_linked && treasure_tile.alive && !found_highlight && treasure_tile.overlapsPoint(clicked_at)) {
						//trace("exploring treasure room!");
						player_treasure += 10;
						sndLotsofcoins.play();
						
						var treasure_room_tile:Tile = new Tile("room_treasure")
						addTileAt(treasure_room_tile, treasure_tile.x, treasure_tile.y);
						treasure_tile_linked = false;
						treasure_tile.kill();
					}
				}
			}
			*/
		}
		
		public function checkKeyboard():void {
			if (FlxG.keys.justReleased("SPACE")) {
				trace("*** RESET ***");
				FlxG.switchState(new MenuState);
			} else if (FlxG.keys.justReleased("D")) {
				trace("*** Toggle Debug ***");
				FlxG.visualDebug = !FlxG.visualDebug;
			} else if (FlxG.keys.justReleased("X")) {
				if (turn_phase == PHASE_CARDS) {
					clearCards();
					cardsInHand.visible = false;
					if (placing_card != null) {
						placing_card.kill();
					}
					is_placing_card = false;
					turn_phase = PHASE_HERO_THINK;
				}
			}
		}
		
		public function dealCards():void {
			clearCards();
			
			var valid_entrances:Array = new Array();
			for each (var h:Tile in highlights.members) {
				if (h.alive) {
					//trace("adding entrances for highlight at [" + Math.floor(h.x / Tile.TILESIZE) + "," + Math.floor(h.y / Tile.TILESIZE) + "]: " + Tile.directionName(h.highlight_entrance) );
					valid_entrances.push(h.highlight_entrance);
				}
			}
			
			var card:Card;
			for (var cc:int = 0; cc < 5; cc++) {
				if (cc < 2) {
					//trace("valid entrances are: " + valid_entrances);
					var possible_tile:Tile = tileManager.GetRandomTile(valid_entrances);
					card = new Card(cc * 155 + 15, 50, "TILE", "", possible_tile);
				} else {
					card = new Card(cc * 155 + 15, 50);
				}
				
				cardsInHand.add(card);
			}
		}
		
		public function clearCards():void {
			//trace("cardsInHand.members.length: " + cardsInHand.members.length);
			for each (var card:Card in cardsInHand.members) {
				if (card != null && card.alive) {
					cardsInHand.remove(card, true);
					card.kill();
				}
			}
			//trace("post trim, cardsInHand.members.length: " + cardsInHand.members.length);
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
								if (this_tile.type == "hint_treasure_room") {
									treasure_tile_linked = true;
								}
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
			var new_highlight:Tile = new Tile("highlight", X, Y);
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