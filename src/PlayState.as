package
{
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.*;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import flash.utils.getQualifiedClassName;
	import com.greensock.*;
	import com.greensock.easing.*;
 
	public class PlayState extends FlxState
	{
		[Embed(source = "../assets/grid_tile.png")] private var gridTilePNG:Class;
		[Embed(source = "../assets/UI_frame.png")] private var UIFramePNG:Class;
		[Embed(source = "../assets/small_paper.png")] private var UIPaperPNG:Class;
		[Embed(source = "../assets/battle_scroll.png")] private var UIBattleScrollPNG:Class;
		
		public var assetManager:AssetManager;
		public var tileManager:TileManager;
		public var dungeon:Dungeon;
		public var tiles:FlxGroup = new FlxGroup();
		public var highlights:FlxGroup = new FlxGroup();
		public var guiGroup:FlxGroup = new FlxGroup();
		public var questionMarks:FlxSprite;
		public var cardsInHand:FlxGroup = new FlxGroup();
		public var placingSprite:FlxGroup = new FlxGroup();
		public var floatingTexts:FlxGroup = new FlxGroup();
		public var battleScreen:FlxGroup = new FlxGroup();
		
		public static const starting_point:Point = new Point(0, 0);
		
		public static const PHASE_FADING_IN:int       = 0; 
		public static const PHASE_NEWTURN:int         = 1;
		public static const PHASE_BOSS_CHAT:int       = 2;
		public static const PHASE_CARDS_PLAY:int      = 3;
		public static const PHASE_CARDS_DEAL:int      = 4;
		public static const PHASE_HERO_THINK:int      = 5;
		public static const PHASE_HERO_MOVING:int     = 6;
		public static const PHASE_HERO_CARDS:int      = 7;
		public static const PHASE_HERO_BATTLE:int     = 8;
		public static const PHASE_BOSS_MOVE:int       = 9;
		public var turn_phase:int = PHASE_FADING_IN;
		
		public static const SCROLL_MAXVELOCITY:Number = 800;
		public static const SCROLL_ACCELERATION:Number = 800;
		public static const PLACING_OFFSET:FlxPoint = new FlxPoint(10, 10);
		
		public static const HAND_START:FlxPoint = new FlxPoint(10, 532);
		public static const HAND_CARD_OFFSET:int = 150;
		public static const SHRUNK_HAND_START:FlxPoint = new FlxPoint(210, 600);
		public static const SHRUNK_HAND_CARD_OFFSET:int = 60;
		
		public static const CARDS_PER_TURN:int = 3;
		public static const BATTLE_TIME:Number = 2;
		public static const IDLE_TIME:Number = 20;
		public static const APPEAR_DELAY:Number = 0.4;
		
		public var placing_card:Card;
		public var is_placing_card:Boolean = false;
		public var battling_monster:Monster;
		public var boss_monster:BossMonster;
		
		public var choosingHighlight:Tile;
		public var choosingTile:Boolean = false;
		
		public var player_alive:Boolean = true;
		public var player_glory:int = 0;
		public var player_glory_label:FlxText;
		public var player_stats_label:FlxText;
		public var player_dread_label:FlxText;
		public var player_hope_label:FlxText;
		public var player_cards_label:FlxText;
		public var endTurnBtn:FlxButtonPlus;
		public var cancelPlacingBtn:FlxButtonPlus;
		public var battle_scroll:FlxSprite;
		public var battle_title:FlxText;
		public var battle_stat_names:FlxText;
		public var battle_hero_stats:FlxText;
		public var battle_monster_stats:FlxText;
		public var battle_hero_sprite:FlxSprite;
		public var battle_monster_sprite:FlxSprite;
		public var stats_hero_sprite:FlxSprite;
		public var UIFrame:FlxSprite;
				
		public var hero:Hero;
		public var camera_target:FlxSprite;
		public var camera_following:FlxObject = null;
		public var is_dragging:Boolean = false;
		public var hand_shrunk:Boolean = true;
		public var click_start:FlxPoint; //needs to be null at start
		public var dragging_from:FlxPoint = new FlxPoint();
		public var possible_spots:int = 0;
		public var turn_number:int = 0;
		public var cards_played:int = 0;
		public var monsters_killed:int = 0;
		public var battle_timer:Number = 0;
		public var battle_turn:Number = 0;
		public var idle_timer:Number = 0;
		public var appearDelay:Number = APPEAR_DELAY;
		public var whiteFade:FlxSprite;
		public var greyOut:FlxSprite;
		public var particleEmitter:FlxEmitter;
		
		override public function create():void {
			//FlxG.visualDebug = true;
			//FlxG.camera.setBounds(0, 0, 800, 600);
			//FlxG.worldBounds = new FlxRect(0, 0, 800, 600);
			
			whiteFade = new FlxSprite(0, 0);
			whiteFade.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
			whiteFade.scrollFactor = new FlxPoint(0, 0);
			whiteFade.DisappearAlpha(appearDelay, false);
			appearDelay += APPEAR_DELAY;
			
			assetManager = new AssetManager(this);
			tileManager = new TileManager(this);
			dungeon = new Dungeon(this);
			
			UIFrame = new FlxSprite(0, 0, UIFramePNG);
			UIFrame.scrollFactor = new FlxPoint(0, 0);
			UIFrame.AppearAlpha(appearDelay);
			appearDelay += APPEAR_DELAY;
			
			hero = new Hero(this, starting_point.x, starting_point.y - Tile.TILESIZE);
			camera_target = new FlxSprite(hero.x, hero.y);
			camera_target.width = camera_target.height = 0;
			camera_target.maxVelocity = new FlxPoint(SCROLL_MAXVELOCITY, SCROLL_MAXVELOCITY);
			camera_target.drag = new FlxPoint(SCROLL_ACCELERATION, SCROLL_ACCELERATION);
			camera_target.visible = false;
			FlxG.camera.follow(camera_target);
			
			greyOut = new FlxSprite(0, 0);
			greyOut.makeGraphic(FlxG.width, FlxG.height, 0x99000000);
			greyOut.scrollFactor = new FlxPoint(0, 0);
			battleScreen.add(greyOut);
			battle_scroll = new FlxSprite(79, 95, UIBattleScrollPNG);
			battle_scroll.scrollFactor = new FlxPoint(0, 0);
			battleScreen.add(battle_scroll);
			battle_title = new FlxText(170, 235, 680, "Hero vs Goblin");
			battle_title.setFormat("LemonsCanFly", 100, 0xFF000000, "center");
			battle_title.scrollFactor = new FlxPoint(0, 0);
			battle_title.antialiasing = true;
			battleScreen.add(battle_title);
			battle_stat_names = new FlxText(432, 327, 160, "Health\nStrength\nSpeed\nArmour");
			battle_stat_names.setFormat("LemonsCanFly", 60, 0xFF000000, "center");
			battle_stat_names.scrollFactor = new FlxPoint(0, 0);
			battle_stat_names.antialiasing = true;
			battleScreen.add(battle_stat_names);
			battle_hero_stats = new FlxText(382, 327, 50, "10\n8\n-1\n0");
			battle_hero_stats.setFormat("LemonsCanFly", 60, 0xFF000000, "center");
			battle_hero_stats.scrollFactor = new FlxPoint(0, 0);
			battle_hero_stats.antialiasing = true;
			battleScreen.add(battle_hero_stats);
			battle_hero_sprite = new FlxSprite(230, 373);
			battle_hero_sprite.scrollFactor = new FlxPoint(0, 0);
			battle_hero_sprite.pixels = hero.framePixels.clone();
			battle_hero_sprite.antialiasing = true;
			battleScreen.add(battle_hero_sprite);
			battle_monster_stats = new FlxText(592, 327, 50, "10\n8\n-1\n0");
			battle_monster_stats.setFormat("LemonsCanFly", 60, 0xFF000000, "center");
			battle_monster_stats.scrollFactor = new FlxPoint(0, 0);
			battle_monster_stats.antialiasing = true;
			battleScreen.add(battle_monster_stats);
			battle_monster_sprite = new FlxSprite(714, 373);
			battle_monster_sprite.scrollFactor = new FlxPoint(0, 0);
			battle_monster_sprite.pixels = hero.framePixels.clone();
			battle_monster_sprite.antialiasing = true;
			battleScreen.add(battle_monster_sprite);
			battleScreen.visible = false;

			var starting_tile:Tile = new Tile(this, "corr_grate_n");
			addTileAt(starting_tile, starting_point.x, starting_point.y, false);
			starting_tile.AppearAlpha(appearDelay);
			starting_tile.has_visited = true;
			appearDelay += APPEAR_DELAY;
			hero.setCurrentTile(starting_tile);
			hero.x = starting_tile.x + hero.tile_offset.x - hero.origin.x;
			hero.y = starting_tile.y + hero.tile_offset.y - hero.origin.y;
			var second_tile:Tile = new Tile(this, "corr_thin_nesw");
			addTileAt(second_tile, starting_point.x, starting_point.y - Tile.TILESIZE);
			second_tile.AppearAlpha(appearDelay);
			second_tile.has_visited = true;
			appearDelay += APPEAR_DELAY;
			hero.Appear(appearDelay);
			appearDelay += APPEAR_DELAY;
			
			var paper_background:FlxSprite = new FlxSprite(775, 600, UIPaperPNG);
			paper_background.scrollFactor = new FlxPoint(0, 0);
			paper_background.Appear(appearDelay);
			appearDelay += APPEAR_DELAY;
			guiGroup.add(paper_background);
			player_stats_label = new FlxText(805, 650, 200, "Strength: 2");
			player_stats_label.setFormat("LemonsCanFly", 28, 0xFF000000, "left");
			player_stats_label.scrollFactor = new FlxPoint(0, 0);
			player_stats_label.angle = 4;
			player_stats_label.antialiasing = true;
			player_stats_label.Appear(appearDelay);
			appearDelay += APPEAR_DELAY;
			guiGroup.add(player_stats_label);
			stats_hero_sprite = new FlxSprite(910, 660);
			stats_hero_sprite.pixels = hero.framePixels.clone();
			stats_hero_sprite.scrollFactor = new FlxPoint(0, 0);
			stats_hero_sprite.angle = 4;
			stats_hero_sprite.antialiasing = true;
			stats_hero_sprite.Appear(appearDelay);
			appearDelay += APPEAR_DELAY;
			guiGroup.add(stats_hero_sprite);
			player_glory_label = new FlxText(FlxG.width - 150 - 45, 15, 120, "Glory: 0");
			player_glory_label.setFormat("LemonsCanFly", 40, 0xFF95B5D6, "right", 0xFF2A72BB);
			player_glory_label.scrollFactor = new FlxPoint(0, 0);
			player_glory_label.antialiasing = true;
			player_glory_label.Appear(appearDelay);
			appearDelay += APPEAR_DELAY;
			guiGroup.add(player_glory_label);
			player_dread_label = new FlxText(FlxG.width - 150 - 165, 15, 120, "Dread: 0");
			player_dread_label.setFormat("LemonsCanFly", 40, 0xFFFF8A8A, "right", 0xFFA82C2C);
			player_dread_label.scrollFactor = new FlxPoint(0, 0);
			player_dread_label.antialiasing = true;
			player_dread_label.Appear(appearDelay);
			appearDelay += APPEAR_DELAY;
			guiGroup.add(player_dread_label);
			player_hope_label = new FlxText(FlxG.width - 150 - 285, 15, 120, "Hope: 0");
			player_hope_label.setFormat("LemonsCanFly", 40, 0xFFEAE2AC, "right", 0xFF999966);
			player_hope_label.scrollFactor = new FlxPoint(0, 0);
			player_hope_label.antialiasing = true;
			player_hope_label.Appear(appearDelay);
			appearDelay += APPEAR_DELAY;
			guiGroup.add(player_hope_label);
			
			player_cards_label = new FlxText(15, 507, 350, "Play or discard up to 3 more cards");
			player_cards_label.setFormat("LemonsCanFly", 30, 0xFFEAE2AC, "left", 0xFF6E533F);
			player_cards_label.scrollFactor = new FlxPoint(0, 0);
			player_cards_label.visible = false;
			guiGroup.add(player_cards_label);
			cancelPlacingBtn = new FlxButtonPlus(693, 500, cancelPlacement, null, "Cancel", 70, 30);
			cancelPlacingBtn.textNormal.setFormat("LemonsCanFly", 30, 0xFFEAE2AC, "center", 0xFF6E533F);
			cancelPlacingBtn.textHighlight.setFormat("LemonsCanFly", 30, 0xFFEAE2AC, "center", 0xFF6E533F);
			cancelPlacingBtn.borderColor = 0xFFEAE2AC;
			cancelPlacingBtn.updateInactiveButtonColors([0xFFA38C69, 0xFFA38C69]);
			cancelPlacingBtn.updateActiveButtonColors([0xFF6E533F, 0xFF6E533F]);   
			cancelPlacingBtn.visible = false;
			guiGroup.add(cancelPlacingBtn);
			
			boss_monster = new BossMonster(this, "Fire Demon", BossMonster.OFFSCREEN_POINT.x, BossMonster.OFFSCREEN_POINT.y);
			boss_monster.scrollFactor = new FlxPoint(0, 0);
			
			highlights.visible = false;
			placingSprite.visible = true;
			
			particleEmitter = new FlxEmitter(0, 0, 300);
			particleEmitter.setXSpeed( -5, 5);
			particleEmitter.setYSpeed( -5, 5);
			for (var i:int = 0; i < particleEmitter.maxSize; i++) {
				particleEmitter.add(new SmallParticle(new FlxPoint(player_glory_label.x + player_glory_label.width / 2, player_glory_label.y + player_glory_label.height / 2)));
			}
			guiGroup.add(particleEmitter);
			
			addCardFromDeck("TILE", 0);
			addCardFromDeck("TILE", 1);
			addCardFromDeck("TILE", 2);
			//addCardFromDeck("TREASURE", 2);
			addCardFromDeck("MONSTER", 3);
			addCardFromDeck("MONSTER", 4);
			
			
			/*
			addCardFromDeck("TREASURE", 0);
			addCardFromDeck("TREASURE", 1);
			addCardFromDeck("TREASURE", 2);
			addCardFromDeck("MONSTER", 3);
			addCardFromDeck("MONSTER", 4);
			*/
			
			/*
			addCardFromDeck("TREASURE", 0);
			addCardFromDeck("TREASURE", 1);
			addCardFromDeck("TREASURE", 2);
			addCardFromDeck("TREASURE", 3);
			addCardFromDeck("TREASURE", 4);
			*/
			
			/*
			addCardFromDeck("MONSTER", 0);
			addCardFromDeck("MONSTER", 1);
			addCardFromDeck("MONSTER", 2);
			addCardFromDeck("MONSTER", 3);
			addCardFromDeck("MONSTER", 4);
			*/
			
			var grid_backdrop:FlxBackdrop = new FlxBackdrop(gridTilePNG, 1.0, 1.0, true, true);
			
			add(grid_backdrop);
			add(tiles);
			add(camera_target);
			add(highlights);
			add(hero);
			add(boss_monster);
			add(floatingTexts);
			add(UIFrame);
			add(guiGroup);
			add(cardsInHand);
			add(battleScreen);
			add(placingSprite);
			add(whiteFade);
			
			TweenLite.delayedCall(appearDelay, endFadeIn);
			appearDelay = 0;
		}
		
		override public function update():void {
			
			checkNewTurn();
			checkHero();
			checkBoss();
			checkPlacing();
			checkMouseClick();
			checkKeyboard();
			
			updateLabels();
			
			//tr("camera_target [" + camera_target.x + ", " + camera_target.y + "], hero [" + hero.x + ", " + hero.y + "]");
			
			super.update();
		}
		
		public function checkHero():void {
			if (turn_phase == PHASE_HERO_THINK && !hero.is_taking_turn) {
				//tr("starting hero turn");
				hero.startTurn();
			} else if (turn_phase == PHASE_HERO_CARDS && !hero.is_processing_cards) {
				hero.processNextCard();
			} else if (turn_phase == PHASE_HERO_BATTLE) {
				if (battle_timer > 0) {
					battle_timer -= FlxG.elapsed;
				} else {
					battle_timer = BATTLE_TIME;
					battle_turn++;
					//tr("battle turn " + battle_turn);
					if (battling_monster._health > 0 && hero._health > 0) {
						if (battle_turn > 5) {
							//run away
							battleScreen.visible = false;
							hero.moving_to_tile = hero.previous_tile;
							hero.current_tile.addCard(hero.processing_card);
							//hero.thinkSomething("movement"); //TODO think something cowardly 
							setCameraFollowing(hero);
							hero.is_taking_turn = true;
							turn_phase = PlayState.PHASE_HERO_MOVING;
						} else {
							hero.FightMonster(battling_monster);
							battle_hero_stats.text = hero.GetStatsNumbers();
							battle_monster_stats.text = battling_monster.GetStatsNumbers();
						}
					} else {
						//battling_monster = null;
						monsters_killed += 1;
						
						appearDelay = 0;
						battle_hero_sprite.Disappear(appearDelay, false);
						battle_monster_sprite.Disappear(appearDelay, false);
						appearDelay += APPEAR_DELAY / 2;
						battle_stat_names.Disappear(appearDelay, false);
						battle_hero_stats.Disappear(appearDelay, false);
						battle_monster_stats.Disappear(appearDelay, false);
						appearDelay += APPEAR_DELAY / 2;
						battle_title.Disappear(appearDelay, false);
						appearDelay += APPEAR_DELAY / 2;
						battle_scroll.Disappear(appearDelay, false);
						appearDelay += APPEAR_DELAY / 2;
						greyOut.DisappearAlpha(appearDelay, false);
						appearDelay += APPEAR_DELAY;
						
						TweenLite.delayedCall(appearDelay, EndFighting);
					}
				}
			} else if (turn_phase == PHASE_CARDS_PLAY) {
				if (idle_timer > 0) {
					idle_timer -= FlxG.elapsed;
				} else {
					idle_timer = IDLE_TIME;
					hero.thinkSomething("idle");
				}
			}
		}
		
		public function checkBoss():void {
			if (turn_phase == PHASE_BOSS_MOVE) {
				if (boss_monster._onBoard) {
					if (!boss_monster._is_taking_turn) {
						//tr('starting boss turn')
						boss_monster.StartTurn();
					}
				} else {
					//tr('skipping boss turn');
					turn_phase = PHASE_NEWTURN;
				}
			}
		}
				
		public function heroArrivedAt(tile:Tile):void {
			//tr("heroArrivedAt, changing to PHASE_HERO_CARDS");
			turn_phase = PlayState.PHASE_HERO_CARDS;
			idle_timer = IDLE_TIME;
		}
		
		public function StartBattle(this_monster:Monster):void {
			battle_timer = BATTLE_TIME;
			battle_turn = 0;
			battling_monster = this_monster;

			battle_title.text = "Hero vs " + battling_monster._type;
			
			battle_hero_stats.text = hero.GetStatsNumbers();
			battle_monster_stats.text = battling_monster.GetStatsNumbers();
			
			battle_hero_sprite.pixels = hero.framePixels.clone();
			battling_monster.drawFrame(true); //necessary for boss_monster as it has never been visible so frame was never set
			battle_monster_sprite.pixels = battling_monster.framePixels.clone();
			
			battleScreen.visible = true;
			
			appearDelay = 0;
			greyOut.AppearAlpha(appearDelay);
			appearDelay += APPEAR_DELAY;
			battle_scroll.bothScale = 1.0;
			battle_scroll.Appear(appearDelay);
			appearDelay += APPEAR_DELAY;
			battle_title.bothScale = 1.0;
			battle_title.Appear(appearDelay);
			appearDelay += APPEAR_DELAY;
			battle_stat_names.bothScale = 1.0;
			battle_hero_stats.bothScale = 1.0;
			battle_monster_stats.bothScale = 1.0;
			battle_stat_names.Appear(appearDelay);
			battle_hero_stats.Appear(appearDelay);
			battle_monster_stats.Appear(appearDelay);
			appearDelay += APPEAR_DELAY;
			battle_hero_sprite.bothScale = 1.0;
			battle_monster_sprite.bothScale = 1.0;
			battle_hero_sprite.Appear(appearDelay);
			battle_monster_sprite.Appear(appearDelay);
			
			TweenLite.delayedCall(appearDelay, StartFighting);
		}
		
		public function StartFighting():void {
			turn_phase = PlayState.PHASE_HERO_BATTLE;
		}
		
		public function EndFighting():void {
			battleScreen.visible = false;
			setCameraFollowing(null);
			if (battling_monster._type == boss_monster._type) {
				tr('** beaten boss **');
				hero.current_tile.GainGlory(250);
				TweenLite.delayedCall(0.6, leaveDungeon);
			} else {
				turn_phase = PlayState.PHASE_BOSS_MOVE;
			}
		}
		
		public function checkPlacing():void {
			if (turn_phase == PHASE_CARDS_PLAY && is_placing_card) {
				placingSprite.setAll("x", FlxG.mouse.screenX + PLACING_OFFSET.x);
				placingSprite.setAll("y", FlxG.mouse.screenY + PLACING_OFFSET.y);
			}
		}
		
		public function checkNewTurn():void {
			if (turn_phase == PHASE_NEWTURN) {
				turn_number++;
				tr("** new turn: " + turn_number + " **");
				dungeon.IncreaseDread();
				turn_phase = PHASE_BOSS_CHAT;
				boss_monster.CheckChat();
			} 
		} 
		
		public function CardsDealOver():void {
			//tr("CardsDealOver");
			turn_phase = PHASE_HERO_THINK;
		}
		
		public function BossChatOver():void {
			TimeToPlayCards();
		}
		
		public function TimeToPlayCards():void {
			showCards();
			hand_shrunk = false;
			SortAndMoveCards();
			cards_played = 0;
			player_cards_label.text = "Play or discard up to 3 more cards";
			turn_phase = PHASE_CARDS_PLAY;
		}
		
		public function updateLabels():void {
			//TODO only update these if any change instead of every frame
			player_stats_label.text = hero.GetStats();
			player_glory_label.text = "Glory: " + player_glory;
			player_dread_label.text = "Dread: " + dungeon._dread_level;
			player_hope_label.text = "Hope: " + dungeon._hope_level;
		}
		
		public function checkMouseClick():void {
			if (FlxG.mouse.justPressed()) {
				//checkTileClick();
				//tr('mouse clicked at world [' + FlxG.mouse.getWorldPosition().x + ',' + FlxG.mouse.getWorldPosition().y + '], screen [' + FlxG.mouse.getScreenPosition().x + ',' + FlxG.mouse.getScreenPosition().y + '], camera.scroll = [' + FlxG.camera.scroll.x + ',' + FlxG.camera.scroll.y + ']')
				idle_timer = IDLE_TIME;
				if (checkMouseOverlapsGroup(guiGroup) == null && checkMouseOverlapsGroup(cardsInHand) == null) {
					if (click_start == null) {
						click_start = FlxG.mouse.getScreenPosition();
						//tr("marking click start, waiting for movement from: [" + click_start.x + "," + click_start.y + "]");
					}
				} 
				
				if (hero.overlapsPoint(FlxG.mouse.getWorldPosition())) {
					if (!TweenMax.isTweening(hero)) {
						hero.thinkSomething("poked");
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
					//tr("dragging_from: [" + dragging_from.x + "," + dragging_from.y + "]");
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
								if (card_in_hand.bothScale == 1.0 && card_in_hand._card_front.overlapsPoint(clicked_at)) {
									if (!canAfford(card_in_hand)) {
										hero.thinkSomething("card_afford", card_in_hand);
										if (card_in_hand._type == "MONSTER") {
											BulgeLabel(player_dread_label);
										} else {
											BulgeLabel(player_hope_label);
										}
									} else {
										//tr("clicked on card " + card_in_hand._title);
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
										
										if (possible_spots <= 0) {
											hero.thinkSomething("card_fit", card_in_hand);
										} else {
											placing_card = card_in_hand;
											is_placing_card = true;
											card_in_hand.visible = false;
											cleanUpPlacingSprite();
											
											if (placing_card._type == "TILE") {
												//tr("* placing tile *");
												var new_placing_card_tile:Card = new Card(this, -1000, -1000, placing_card._type, placing_card._tile);
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
													var new_placing_card_monster:Monster = new Monster(this, placing_card._monster._type, true);
													placingSprite.add(new_placing_card_monster);
												} else {
													var new_placing_card_treasure:Treasure = new Treasure(this,placing_card._treasure._type, true);
													placingSprite.add(new_placing_card_treasure);
												}
												placingSprite.setAll("x", FlxG.mouse.screenX + PLACING_OFFSET.x);
												placingSprite.setAll("y", FlxG.mouse.screenY + PLACING_OFFSET.y);
												for each (var possible_tile2:Tile in tiles.members) {
													if (possible_tile2 != hero.current_tile && possible_tile2.validForCard(placing_card)) {
														possible_tile2.flashing = true;
													}
												}
											}
											
											selectedCard();
											//tr("placingSprite.countLiving(): " + placingSprite.countLiving());
										}
									}
								}
							}
						}
					} else {
						//tr("placing card " + placing_card._title);
						if (placing_card._type == "TILE") {
							for each (var highlight:Tile in highlights.members) {
								if (highlight.alive && highlight.overlapsPoint(clicked_at) && placing_card._tile.validForHighlight(highlight)) {
									var new_tile:Tile = new Tile(this, placing_card._tile.type);
									var justAdded:Tile = addTileAt(new_tile, highlight.x, highlight.y);
									justAdded.GainGlory();
									justAdded.AppearAlpha();
									highlight.kill()
									is_placing_card = false;
									highlights.visible = false;
								} 
							}
						} else {
							for each (var tile:Tile in tiles.members) {
								if (tile != hero.current_tile && tile.validForCard(placing_card) && tile.overlapsPoint(clicked_at)) {
									//tr("clicked on tile " + tile.type + " at [" + tile.x + "," + tile.y + "]");
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
			if (FlxG.keys.justReleased("R")) {
				tr("*** RESET ***");
				TweenMax.killAll();
				FlxG.switchState(new MenuState);
			} else if (FlxG.keys.justReleased("D")) {
				FlxG.visualDebug = !FlxG.visualDebug;
				tr("*** Toggle Debug, visualDebug now " + FlxG.visualDebug + " ***");
			} else if (FlxG.keys.justReleased("S")) {
				FlxG.mute = !FlxG.mute;
				tr("*** Toggle Sound, mute now " + FlxG.mute + " ***");
			} else if (FlxG.keys.justReleased("C")) {
				UIFrame.visible = !UIFrame.visible;
				cardsInHand.visible = !cardsInHand.visible;
				guiGroup.visible = !guiGroup.visible;
				tr("*** Toggle CLEARSCREEN, frame visible now " + UIFrame.visible + " ***");
			}
			
			//camera movement
			camera_target.acceleration.x = camera_target.acceleration.y = 0;
			if (camera_following != null && !is_dragging) {
				//TODO change this to use TweenLite, perhaps?
				FlxVelocity.moveTowardsPoint(camera_target, new FlxPoint(camera_following.x, camera_following.y + 130), 0, 300); //130 is to raise the viewport slightly because of the hand of cards
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
			if (object == null || !object.visible) {
				return null;
			} else if (object is FlxGroup) {
				//tr("flxgroup found, recursing. " + object);
				for each (var member:* in object.members) {
					var this_one:FlxObject = checkMouseOverlapsGroup(member);
					if (this_one != null) {
						//tr("found one");
						return this_one;
					}
				}
			} else {
				//tr("object checking. " + object + " at [" + object.x + "," + object.y + "]");
				//tr("mouse at [" + FlxG.mouse.getScreenPosition().x + "," + FlxG.mouse.getScreenPosition().y + "]");
				if (object.overlapsPoint(FlxG.mouse.getScreenPosition())) {
					//tr("object overlaps. " + object + " at [" + object.x + "," + object.y + "]");
					return object;
				}
			}

			//trace ("returning null");
			return null;
		}
		
		public function canAfford(card:Card):Boolean {
			//tr("canAfford " + card._type + " : " + card._title + " for cost " + card._cost + "?");
			if (card._type == "MONSTER") {
				//return (dungeon._dread_level >= card._cost);
				return true; //always allowed play a monster
			} else if (card._type == "TREASURE") {
				return (dungeon._hope_level >= card._cost);
			} else {
				return true;
			}
		}
		
		public function payForCard(card:Card):void {
			if (card._type == "MONSTER") {
				dungeon._dread_level -= card._cost;
				if (dungeon._dread_level < 0) {
					dungeon._dread_level = 0;
				}
				BulgeLabel(player_dread_label);
			} else if (card._type == "TREASURE") {
				dungeon._hope_level -= card._cost;
				BulgeLabel(player_hope_label);
			} 
		}
		
		
		public function fillHand():void {
			//tr("now in fillHand");
			var cards_in_hand:int = cardsInHand.countLiving();
			if (cards_in_hand < 0) {
				cards_in_hand = 0;
			}
			
			var cards_to_add:int = 5 - cards_in_hand;
			for (var i:int = 0; i < cards_to_add; i++) {
				addCardFromDeck("", i); //TODO recycle members of flxgroup instead
			}
		}
		
		public function SortAndMoveCards():void {
			//tr("now in SortAndMoveCards");
			var cards_so_far:int = 0;
			for each (var card_in_hand:Card in cardsInHand.members) {
				if (card_in_hand != null && card_in_hand.alive) {
					if (hand_shrunk) {
						var y_offset:Number = -12 + Math.abs(cards_so_far - 2) * 6;
						if ( -10.0 + cards_so_far * 5 == 0) {
							y_offset += 3;
						}
						card_in_hand.MoveTo(new FlxPoint(SHRUNK_HAND_START.x + cards_so_far * SHRUNK_HAND_CARD_OFFSET, SHRUNK_HAND_START.y + y_offset), -10.0 + cards_so_far * 5, 0.5);
					} else {
						card_in_hand.MoveTo(new FlxPoint(HAND_START.x + cards_so_far * HAND_CARD_OFFSET, HAND_START.y), 0, 1.0);
					}
					
					//tr("moving card " + card_in_hand._title + " from x: " + card_in_hand._background.x + " to x: " + card_in_hand._moving_to.x + " for card slot " + cards_so_far);
					//TODO occasional sorting issue
					cards_so_far++;
				}
			}
		}
		
		public function addCardFromDeck(type:String = "", sequence:int = 0):void {
			//tr("adding card from deck " + type);
			//tr("cardsInHand.countLiving(): " + cardsInHand.countLiving());
			
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
			//tr("total_tile: " + total_tile + ", total_monster: " + total_monster + ", total_treasure: " + total_treasure);
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
			
			//tr("  adding card of type " + type);
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
							//tr("adding entrances for highlight at [" + Math.floor(h.x / Tile.TILESIZE) + "," + Math.floor(h.y / Tile.TILESIZE) + "] with validHighlightEntrances(): " + h.validHighlightEntrances() );
							valid_entrances = valid_entrances.concat(h.validHighlightEntrances());
							//tr("after concat valid_entrances: " + valid_entrances);
						}
					}
					var possible_tile:Tile = tileManager.GetRandomTile(valid_entrances);
					possible_card = new Card(this, card_point.x, card_point.y, "TILE", possible_tile);
					break;
				case "MONSTER":
					var possible_monster:Monster = dungeon.GetRandomMonster();
					//tr("generating possible monster card " + possible_monster._type);
					possible_card = new Card(this, card_point.x, card_point.y, "MONSTER", null, possible_monster);
					break;
				case "TREASURE":
					var possible_treasure:Treasure = dungeon.GetRandomTreasure();
					possible_card = new Card(this, card_point.x, card_point.y, "TREASURE", null, null, possible_treasure);
					break;
				default:
					throw new Error("no matching card type defined for " + type);
			}
			
			if (hand_shrunk) {
				possible_card.angle = -10.0 + cards_so_far * 5;
				possible_card.x = SHRUNK_HAND_START.x + cards_so_far * SHRUNK_HAND_CARD_OFFSET;
				possible_card.y = SHRUNK_HAND_START.y - 12 + Math.abs(cards_so_far - 2) * 6;
				if (possible_card.angle == 0) {
					possible_card.y += 3;
				}
				possible_card.bothScale = 0.5;	
			}
			cardsInHand.add(possible_card);
			possible_card.Appear(sequence * Card.TIME_TO_APPEAR + appearDelay);
			//tr("finished adding card to hand " + possible_card._title);
		}
		
		public function selectedCard():void {
			placingSprite.setAll("visible", true);
			placingSprite.setAll("scrollFactor", new FlxPoint(0, 0));
			cancelPlacingBtn.visible = true;
		}
		
		public function cancelPlacement():void {
			if (is_placing_card) {
				//tr("cancel placement");
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
		
		public function setCameraFollowing(follow_object:FlxObject):void {
			camera_following = follow_object;
		}

		public function discardCard(card_to_discard:Card):void {
			//tr("discarding card " + card_to_discard._title);
			cardsInHand.remove(card_to_discard, true);
			incrementCardsPlayed();
		}
		
		public function endCardPlaying():void {
			//tr("in endCardPlaying");
			hideCards();
			hand_shrunk = true;
			SortAndMoveCards();
			turn_phase = PHASE_CARDS_DEAL;
			var missing_cards:Number = 5 - cardsInHand.countLiving();
			//tr(" missing_cards = " + missing_cards);
			//tr("  calling fillHand with delay of " + Card.TIME_TO_MOVE);
			TweenLite.delayedCall(Card.TIME_TO_MOVE, fillHand);
			//tr("  calling CardsDealOver with delay of " + (Card.TIME_TO_MOVE + Card.TIME_TO_APPEAR * missing_cards));
			TweenLite.delayedCall(Card.TIME_TO_MOVE + Card.TIME_TO_APPEAR * missing_cards, CardsDealOver);
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
		
		public function endFadeIn():void {
			turn_phase = PHASE_HERO_THINK;
		}
		
		public function addTileAt(tile:Tile, X:int, Y:int, checkExits:Boolean = true):Tile {
			tile.x = X;
			tile.y = Y;
			tiles.add(tile);
			//tr("adding tile at " + X + "," + Y);
			
			if (checkExits && (tile.type.indexOf("corr") == 0 || tile.type.indexOf("room") == 0)) { 
				tile.has_visited = false;
				for each (var direction:int in tileManager.all_directions) {
					//trace ("(in addTileAt) checking " + direction + " for tile of type " + tile.type);
					if (tile.checkExit(direction)) {
						//tr("adding new highlight to " + direction);
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
								//tr("direction " + direction + " filled by " + this_tile.type);
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
			//don't add new highlight tile if one already exists for that space
			var filled:Boolean = false;
			for each (var this_highlight:Tile in highlights.members) {
				if (this_highlight.x == X && this_highlight.y == Y) {
					//tr("setting additional entrance for highlight at [" + Math.floor(X / Tile.TILESIZE) + "," + Math.floor(Y / Tile.TILESIZE) + "] with entrance " + from_direction + " " + Tile.directionName(from_direction));
					this_highlight.setHighlightEntrance(Tile.oppositeDirection(from_direction));
					filled = true;
					break;
				}
			}
			
			if (!filled) {
				var new_highlight:Tile = new Tile(this, "highlight", X, Y);
				//tr("adding highlight at [" + Math.floor(X / Tile.TILESIZE) + "," + Math.floor(Y / Tile.TILESIZE) + "] with entrance " + from_direction + " " + Tile.directionName(from_direction));
				new_highlight.setHighlightEntrance(Tile.oppositeDirection(from_direction));
				highlights.add(new_highlight);
			}
		}
		
		public function leaveDungeon():void {
			if (player_alive) {
				assetManager.PlaySound("cheer");
			} else {
				assetManager.PlaySound("deathscream");
			}
			FlxG.switchState(new MenuState(true, player_alive, player_glory));
		}
		
		public function BulgeLabel(label:FlxText):void {
			var delay:Number = 0.3;
			TweenLite.to(label, delay, { y:"-5", bothScale: 1.5 } );
			TweenLite.to(label, delay, { y:"5", bothScale: 1.0, delay: delay } );
		}
		
		public function GetTileAtXY(x:int, y:int):Tile {
			var point:FlxPoint = new FlxPoint(x, y);
			for each (var tile:Tile in tiles.members) {
				//tr("checking tile " + tile.type + " at [" + tile.x + "," + tile.y + "]");
				if (tile.overlapsPoint(point) || (tile.x == point.x && tile.y == point.y)) {
					//tr("tile overlaps point:  " + tile.type);
					return tile;
				}
			}
			
			return null;
		}
		
		public function GetTileAt(point:FlxPoint):Tile {
			return GetTileAtXY(point.x, point.y);
		}
		
		public function checkTileClick():void {
			var clicked_at:FlxPoint = FlxG.mouse.getWorldPosition();
			var clicked_at_tile_coords:FlxPoint = Tile.getCoordinatesFromXY(clicked_at.x, clicked_at.y);
			var hero_tile_coords:FlxPoint = Tile.getCoordinatesFromXY(hero.current_tile.x, hero.current_tile.y);
			//tr("hero on tile (" + hero_tile_coords.x + "," + hero_tile_coords.y + ")");
			//tr("mouse clicked at tile (" + clicked_at_tile_coords.x + "," + clicked_at_tile_coords.y + "), exact [" + clicked_at.x + "," + clicked_at.y + "]");
			var clicked_tile:Tile = GetTileAtXY(clicked_at.x, clicked_at.y);
			if (clicked_tile) {
				//tr("tile found: " + clicked_tile.type);
				var found_path:Array = tileManager.findPath(hero.current_tile, clicked_tile);
				//tr("** PATHING **");
				for each (var tile:Tile in found_path) {
					var tile_coords:FlxPoint = Tile.getCoordinatesFromXY(tile.x, tile.y);
					//tr(tile.type + " at (" + tile_coords.x + "," + tile_coords.y + ") ->");
				}
			}
			
		}
	}
}