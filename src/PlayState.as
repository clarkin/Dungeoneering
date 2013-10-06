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
		
		public static const starting_point:Point = new Point(358, 578);
		
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
		
		override public function create():void {
			//FlxG.visualDebug = true;
			FlxG.camera.setBounds(0, 0, 800, 600);
			FlxG.worldBounds = new FlxRect(0, 0, 800, 600);
			
			tileManager = new TileManager();
			
			treasure_tile = new Tile("hint_treasure_room");
			var rand_x:int = Math.floor(Math.random() * 8) - 3;
			var rand_y:int = Math.floor(Math.random() * 4) + 8;
			addTileAt(treasure_tile, starting_point.x + (Tile.TILESIZE * rand_x), starting_point.y - (Tile.TILESIZE * rand_y));
			
			var starting_tile:Tile = new Tile("corr_dead1", starting_point.x, starting_point.y);
			tiles.add(starting_tile);
			starting_tile = new Tile("corr_straight1", starting_point.x, starting_point.y - Tile.TILESIZE);
			tiles.add(starting_tile);
			starting_tile = new Tile("corr_fourway");
			addTileAt(starting_tile, starting_point.x, starting_point.y - Tile.TILESIZE - Tile.TILESIZE);
			
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
			
			questionMarks = new FlxSprite(6, 98, ARTquestionMarks);
			explorationChoice.add(questionMarks);
			var title:FlxText = new FlxText(0, 160, 800, "CHOOSE A TILE");
			title.setFormat("Popup", 36, 0x5C3425, "center", 0);
			explorationChoice.add(title);
			var leftButton:FlxButtonPlus = new FlxButtonPlus(236, 389, chooseLeftTile, null, "CHOOSE", 80, 20);
			leftButton.textNormal.setFormat("Popup", 12, 0x5C3425, "center", 0);
			leftButton.textHighlight.setFormat("Popup", 12, 0x5C3425, "center", 0);
			leftButton.borderColor = 0xFF5C3425;
			leftButton.updateInactiveButtonColors([0xFFC2A988, 0xFFFFFFCC]);
			leftButton.updateActiveButtonColors([0xFFD54DFF, 0xFFF9E6FF]);
			explorationChoice.add(leftButton);
			var rightButton:FlxButtonPlus = new FlxButtonPlus(489, 389, chooseRightTile, null, "CHOOSE", 80, 20);
			rightButton.textNormal.setFormat("Popup", 12, 0x5C3425, "center", 0);
			rightButton.textHighlight.setFormat("Popup", 12, 0x5C3425, "center", 0);
			rightButton.borderColor = 0xFF5C3425;
			rightButton.updateInactiveButtonColors([0xFFC2A988, 0xFFFFFFCC]);
			rightButton.updateActiveButtonColors([0xFFD54DFF, 0xFFF9E6FF]);
			explorationChoice.add(rightButton);
			treasure_icon_left = new FlxSprite(236, 340, ARTcrownCoin);
			explorationChoice.add(treasure_icon_left);
			treasure_icon_label_left = new FlxText(236, 340, 26, "1");
			treasure_icon_label_left.setFormat(null, 8, 0xFFFFFF, "left", 0x666666);
			explorationChoice.add(treasure_icon_label_left);
			monster_icon_left = new FlxSprite(280, 340, ARTspectre);
			explorationChoice.add(monster_icon_left);
			monster_icon_label_left = new FlxText(280, 340, 26, "1");
			monster_icon_label_left.setFormat(null, 8, 0xFFFFFF, "left", 0x666666);
			explorationChoice.add(monster_icon_label_left);
			treasure_icon_right = new FlxSprite(488, 340, ARTcrownCoin);
			explorationChoice.add(treasure_icon_right);
			treasure_icon_label_right = new FlxText(488, 340, 26, "1");
			treasure_icon_label_right.setFormat(null, 8, 0xFFFFFF, "left", 0x666666);
			explorationChoice.add(treasure_icon_label_right);
			monster_icon_right = new FlxSprite(532, 340, ARTspectre);
			explorationChoice.add(monster_icon_right);
			monster_icon_label_right = new FlxText(532, 340, 26, "1");
			monster_icon_label_right.setFormat(null, 8, 0xFFFFFF, "left", 0x666666);
			explorationChoice.add(monster_icon_label_right);
			explorationChoice.add(explorationTiles);
			explorationChoice.visible = false;
			
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
			add(highlights);
			add(guiGroup);
			add(explorationChoice);
		}
		
		override public function update():void {
			checkControls();
			
			player_treasure_label.text = "Treasure: " + player_treasure;
			player_life_label.text = "Life: " + player_life;
			
			super.update();
		}
		
		private function checkControls():void {
			checkMouseHover();
			checkMouseClick();
			checkKeyboard();
		}
		
		public function checkMouseHover():void {
			
		}
		
		public function checkMouseClick():void {
			if (FlxG.mouse.justReleased()) {
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
		}
		
		public function checkKeyboard():void {
			if (FlxG.keys.justReleased("SPACE")) {
				trace("*** RESET ***");
				FlxG.switchState(new MenuState);
			} 
		}
		
		public function chooseLeftTile():void {
			if (choosingTile) {
				chooseTile(explorationTiles.members[0]);
			}
		}
		
		public function chooseRightTile():void {
			if (choosingTile) {
				chooseTile(explorationTiles.members[1]);
			}
		}
		
		public function chooseTile(tile:Tile):void {
			choosingTile = false;
			explorationChoice.visible = false;
			player_treasure += tile.treasure_cards;
			player_life -= tile.monster_cards;
			if (player_life <= 0) {
				player_alive = false;
				leaveDungeon();
			}
			
			if (tile.monster_cards > 0) {
				sndSwordkill.play();
			} else if (tile.treasure_cards > 0) {
				sndCoins.play();
			} else if (tile.type.indexOf("room") == 0) {
				sndDoorcreak.play();
			} else if (tile.type.indexOf("corr") == 0) {
				sndFootsteps.play();
			}
			
			addTileAt(tile, choosingHighlight.x, choosingHighlight.y);
			choosingHighlight.kill();
		}
		
		public function showTileChoice():void {
			choosingTile = true;
			explorationTiles.clear();  //possible mem leak
			var _new_tile:Tile = tileManager.GetRandomTile(choosingHighlight.higlight_entrance);
			_new_tile.x = 252;
			_new_tile.y = 283;
			explorationTiles.add(_new_tile);
			if (_new_tile.treasure_cards > 0) {
				treasure_icon_label_left.text = _new_tile.treasure_cards.toString();
				treasure_icon_label_left.visible = true;
				treasure_icon_left.visible = true;
			} else {
				treasure_icon_label_left.visible = false;
				treasure_icon_left.visible = false;
			}
			if (_new_tile.monster_cards > 0) {
				monster_icon_label_left.text = _new_tile.monster_cards.toString();
				monster_icon_label_left.visible = true;
				monster_icon_left.visible = true;
			} else {
				monster_icon_label_left.visible = false;
				monster_icon_left.visible = false;
			}
			_new_tile = tileManager.GetRandomTile(choosingHighlight.higlight_entrance);
			_new_tile.x = 504;
			_new_tile.y = 283;
			if (_new_tile.treasure_cards > 0) {
				treasure_icon_label_right.text = _new_tile.treasure_cards.toString();
				treasure_icon_label_right.visible = true;
				treasure_icon_right.visible = true;
			} else {
				treasure_icon_label_right.visible = false;
				treasure_icon_right.visible = false;
			}
			if (_new_tile.monster_cards > 0) {
				monster_icon_label_right.text = _new_tile.monster_cards.toString();
				monster_icon_label_right.visible = true;
				monster_icon_right.visible = true;
			} else {
				monster_icon_label_right.visible = false;
				monster_icon_right.visible = false;
			}
			explorationTiles.add(_new_tile);							
			explorationChoice.visible = true;		
		}
		
		public function addTileAt(tile:Tile, X:int, Y:int):void {
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
			
		}
		
		public function addHighlight(X:int, Y:int, from_direction:int):void {
			var new_highlight:Tile = new Tile("highlight", X, Y);
			new_highlight.higlight_entrance = Tile.oppositeDirection(from_direction);
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