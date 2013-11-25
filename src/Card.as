package 
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	public class Card extends FlxGroup
	{
		[Embed(source = "../assets/ass_char_tran.png")] private var charactersPNG:Class;
		[Embed(source = "../assets/ass_item_tran.png")] private var itemsPNG:Class;
		[Embed(source = "../assets/card_backgrounds.png")] private var cardBackgroundsPNG:Class;
		[Embed(source = "../assets/Crushed.ttf", fontFamily = "Crushed", embedAsCFF = "false")] public	var	FONTCrushed:String;
		
		public static const CARDS_WEIGHTED:Array = [
			"MONSTER", "MONSTER", "MONSTER", "TREASURE", "TREASURE"];
		public static const ALL_MONSTERS:Array = [
			"Runty Goblin", "Goblin Leader", "Giant Bat", "Chicken", "Filthy Rat", "Skeleton"];
		public static const ALL_TREASURE:Array = [
			"Silver Coins", "Small Chest", "Gold Coins", "Sapphire Ring", "Short Sword", 
			"Magic Axe", "Long Sword", "Wooden Shield", "Leather Vest"];

		private static const TITLE_OFFSET:FlxPoint = new FlxPoint(1, 1);
		private static const ICON_TILE_OFFSET:FlxPoint = new FlxPoint(50, 40);
		private static const ICON_OFFSET:FlxPoint = new FlxPoint(63, 54);
		private static const DESC_OFFSET:FlxPoint = new FlxPoint(1, 95);
		private static const DISCARD_OFFSET:FlxPoint = new FlxPoint(40, 203);
		private static const CARD_WIDTH:int = 150;
		private static const CARD_HEIGHT:int = 200;
		private static const SPEED:int = 5;
		
		public var _title:String = "";
		public var _desc:String = "";
		public var _type:String = "";
		public var _background:FlxSprite;
		private var _background_frame:int = 0;
		private var _background_frame_back:int = 0;
		private var _card_text_color:uint = 0xFF000000;
		private var _titleText:FlxText;
		private var _descText:FlxText;
		private var _hoverEffect:FlxSprite;
		private var _hover_enabled:Boolean = true;
		private var _iconHolder:FlxGroup = new FlxGroup();
		public var _card_front:FlxGroup = new FlxGroup();
		public var _tile:Tile;
		public var _monster:Monster;
		public var _sprite:FlxSprite;
		public var _showing_back:Boolean = false;
		public var _shrunk:Boolean = false;
		public var _moving_to:FlxPoint;
		public var _is_moving:Boolean = false;
		public var _discardBtn:FlxButtonPlus;
		
		private var _playState:PlayState;
		
		public function Card(playState:PlayState, X:int = 0, Y:int = 0, type:String = "", title:String = "", tile:Tile = null, monster:Monster = null) 
		{
			super();
			
			_playState = playState;
			
			if (type == "") {
				type = CARDS_WEIGHTED[Math.floor(Math.random() * (CARDS_WEIGHTED.length))];
				trace("WARNING: random card type added");
			}
			_type = type;
			
			switch (_type) {
				case "MONSTER":
					if (monster == null) {
						monster = _playState.dungeon.GetRandomMonster();
					}
					_background_frame = 0;
					_background_frame_back = 4;
					_card_text_color = 0xFF812222;
					title = monster._type;
					_desc = monster._desc;
					_monster = new Monster(_playState, title, X + ICON_OFFSET.x, Y + ICON_OFFSET.y);
					_iconHolder.add(_monster);
					break;
				case "TREASURE":
					if (title == "") {
						title = ALL_TREASURE[Math.floor(Math.random() * (ALL_TREASURE.length))]
					}
					_background_frame = 2;
					_background_frame_back = 6;
					_card_text_color = 0xFF003399;
					_sprite = new FlxSprite(X + ICON_OFFSET.x, Y + ICON_OFFSET.y);
					_sprite.loadGraphic(itemsPNG, false, true, 24, 24);
					_iconHolder.add(_sprite);
					break;
				case "TILE":
					if (tile == null) {
						tile = _playState.tileManager.GetRandomTile();
					}
					title = tile.type;
					_background_frame = 1;
					_background_frame_back = 5;
					_card_text_color = 0xFF5C3425;
					_tile = new Tile(_playState, title, X + ICON_TILE_OFFSET.x, Y + ICON_TILE_OFFSET.y);
					_tile.scale = new FlxPoint(0.33, 0.33);
					_tile.width = _tile.width * 0.33;
					_tile.height = _tile.height * 0.33;
					_tile.offset = new FlxPoint(_tile.width, _tile.height);
					_iconHolder.add(_tile);
					break;
				default:
					throw new Error("no matching card type defined for " + type);
			}
			
			_title = title;
			switch (_title) {
				case "Runty Goblin":
					
					break;
				case "Goblin Leader":
					
					break;
				case "Giant Bat":
					
					break;
				case "Chicken":
					
					break;
				case "Filthy Rat":
					
					break;
				case "Skeleton":
					
					break;
				case "Silver Coins":
					_desc = "A handful of silver, strewn carelessly on the ground.";	
					_sprite.frame = 84;
					break;
				case "Small Chest":
					_desc = "An ornate wooden chest. What might be inside?";	
					_sprite.frame = 81;
					break;
				case "Gold Coins":
					_desc = "A small pile of coins, gleaming temptfully.";	
					_sprite.frame = 83;
					break;
				case "Sapphire Ring":
					_desc = "A ring mounted with a huge sapphire, fit for a princess.";	
					_sprite.frame = 74;
					break;
				case "Short Sword":
					_desc = "A dull sword about a foot long. Easy to use but without much reach.";
					_sprite.frame = 6;
					break;
				case "Magic Axe":
					_desc = "This axe gleams and shines in the darkness with an inner fire.";
					_sprite.frame = 17;
					break;
				case "Long Sword":
					_desc = "The classic, versatile weapon. Perhaps a little boring.";
					_sprite.frame = 0;
					break;
				case "Wooden Shield":
					_desc = "A solid weight of wood to fend off a few blows.";
					_sprite.frame = 41;
					break;
				case "Leather Vest":
					_desc = "Tight fitted leather for your midriff, not great but better than nothing.";
					_sprite.frame = 48;
					break;
				default:
					if (_type == "TILE") {
						if (_title.indexOf("corr") == 0) {
							_title = "Corridor";
							_desc = "Where might it lead?";
						} else {
							_title = "Room";
							_desc = "What might be inside?";
						}
					} else {
						throw new Error("no matching card defined for " + _title);
					}
			}
			
			_background = new FlxSprite(X, Y);
			_background.loadGraphic(cardBackgroundsPNG, false, false, CARD_WIDTH, CARD_HEIGHT);
			_background.frame = _background_frame;
			this.add(_background);
			
			_titleText = new FlxText(X + TITLE_OFFSET.x, Y + TITLE_OFFSET.y, 148, _title.toUpperCase());
			_titleText.height = 32;
			_titleText.setFormat("Crushed", 26, _card_text_color, "center");
			_card_front.add(_titleText);
			
			_descText = new FlxText(X + DESC_OFFSET.x, Y + DESC_OFFSET.y, 148, _desc.toUpperCase());
			_descText.height = 104;
			_descText.setFormat("Crushed", 18, _card_text_color, "center");
			_card_front.add(_descText);
			
			_card_front.add(_iconHolder);
			this.add(_card_front);
			
			_hoverEffect = new FlxSprite(X, Y);
			_hoverEffect.makeGraphic(CARD_WIDTH, CARD_HEIGHT, _card_text_color);
			_hoverEffect.alpha = 0.3;
			_hoverEffect.visible = false;
			this.add(_hoverEffect);
			
			_discardBtn = new FlxButtonPlus(X + DISCARD_OFFSET.x, Y + DISCARD_OFFSET.y, discardThisCard, null, "Discard", 70, 30);
			_discardBtn.textNormal.setFormat("Crushed", 18, 0xFFEAE2AC, "center", 0xFF6E533F);
			_discardBtn.textHighlight.setFormat("Crushed", 18, 0xFFEAE2AC, "center", 0xFF6E533F);
			_discardBtn.borderColor = 0xFFEAE2AC;
			_discardBtn.updateInactiveButtonColors([0xFFA38C69, 0xFFA38C69]);
			_discardBtn.updateActiveButtonColors([0xFF6E533F, 0xFF6E533F]);   
			//_discardBtn.visible = false;
			//_discardBtn._status = FlxButtonPlus.PRESSED;
			_card_front.add(_discardBtn);
			
			this.showBack();
		}
		
		override public function update():void {	
			//trace("current tile: " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
			//trace("moving to tile: " + moving_to_tile.type + " at [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			//trace("currently at : [" + x + "," + y + "], moving to [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			
			
			checkMovement();
			checkHover();
			
			super.update();
		}
		
		private function checkMovement():void {
			if (_is_moving) {
				var distance_x:int = _moving_to.x - _background.x;
				var distance_y:int = _moving_to.y - _background.y;
				
				var change_x:Number = FlxG.elapsed * (SPEED * distance_x);
				var change_y:Number = FlxG.elapsed * (SPEED * distance_y);
				//trace("change_x: " + change_x);
				
				_background.x += change_x;
				_background.y += change_y;
				if (_sprite != null) {
					_sprite.x += change_x;
					_sprite.y += change_y;
				}
				if (_tile != null) {
					_tile.x += change_x;
					_tile.y += change_y;
				}
				if (_monster != null) {
					_monster.x += change_x;
					_monster.y += change_y;
				}
				_titleText.x += change_x;
				_titleText.y += change_y;
				_descText.x += change_x;
				_descText.y += change_y;
				_hoverEffect.x += change_x;
				_hoverEffect.y += change_y;
				_discardBtn.x += change_x;
				_discardBtn.y += change_y;
				
				if (distance_x >= -1 && distance_x <= 1 && distance_y >= -1 && distance_y <= 1) {
					_is_moving = false;
				}
			}
		}
		
		public function checkHover():void {
			if (_hover_enabled && !_showing_back && _background.overlapsPoint(FlxG.mouse.getScreenPosition())) {
				_hoverEffect.visible = true;
			} else {
				_hoverEffect.visible = false;
			}
			//trace("mouse at [" + FlxG.mouse.x + "," + FlxG.mouse.y + "], visible: " + _hoverEffect.visible);
		}
		
		public function discardThisCard():void {
			if (!_playState.is_placing_card) {
				_playState.discardCard(this);
			}
		}
		
		public function flipCard():void {
			_showing_back = !_showing_back;
			//trace("now _showing_back: " + _showing_back);
			
			if (_showing_back) {
				_background.frame = _background_frame_back;
			} else {
				_background.frame = _background_frame;
			}
			
			_card_front.setAll("visible", !_showing_back);
		}
		
		public function showBack():void {
			_showing_back = true;
			_background.frame = _background_frame_back;
			_card_front.setAll("visible", false);
		}
		
		public function showFront():void {
			_showing_back = false;
			_background.frame = _background_frame;
			_card_front.setAll("visible", true);
			_discardBtn.resetToNormal();
		}
		
		public function toggleSize():void {
			_shrunk = !_shrunk;
			
			if (_shrunk) {
				_background.scale = new FlxPoint(0.5, 0.5);
				_hover_enabled = false;
			} else {
				_background.scale = new FlxPoint(1.0, 1.0);
				_hover_enabled = true;
			}
		}

	}
}