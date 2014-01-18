package 
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	public class Card extends FlxGroup
	{
		[Embed(source = "../assets/card_backgrounds.png")] private var cardBackgroundsPNG:Class;
		[Embed(source = "../assets/card_white.png")] private var cardScrollsPNG:Class;
		[Embed(source = "../assets/card_symbols.png")] private var cardSymbolsPNG:Class;
		
		public static const CARDS_WEIGHTED:Array = [
			"MONSTER", "MONSTER", "MONSTER", "TREASURE", "TREASURE"];

		private static const TITLE_OFFSET:FlxPoint = new FlxPoint(17, 111);
		private static const SCROLLS_OFFSET:FlxPoint = new FlxPoint(16, 109);
		private static const TYPE_OFFSET:FlxPoint = new FlxPoint(4, 6);
		private static const COST_ICON_OFFSET:FlxPoint = new FlxPoint(108, 6);
		private static const COST_OFFSET:FlxPoint = new FlxPoint(116, 12);
		private static const ICON_TILE_OFFSET:FlxPoint = new FlxPoint(37, 37); //new FlxPoint(50, 40);
		private static const ICON_OFFSET:FlxPoint = new FlxPoint(35, 35);
		private static const DESC_OFFSET:FlxPoint = new FlxPoint(26, 138);
		private static const DISCARD_OFFSET:FlxPoint = new FlxPoint(40, 203);
		private static const CARD_WIDTH:int = 150;
		private static const CARD_HEIGHT:int = 200;
		private static const SPEED:int = 5;
		
		public var _title:String = "";
		public var _desc:String = "";
		public var _type:String = "";
		public var _background:FlxSprite;
		public var _type_icon:FlxSprite;
		public var _scrolls:FlxSprite;
		public var _cost_icon:FlxSprite;
		private var _background_frame:int = 0;
		private var _background_frame_back:int = 0;
		private var _type_icon_frame:int = 0;
		private var _card_text_color:uint = 0xFF000000;
		private var _titleText:FlxText;
		private var _descText:FlxText;
		private var _costText:FlxText;
		private var _hoverEffect:FlxSprite;
		private var _hover_enabled:Boolean = true;
		private var _iconHolder:FlxGroup = new FlxGroup();
		public var _card_front:FlxGroup = new FlxGroup();
		public var _tile:Tile;
		public var _monster:Monster;
		public var _treasure:Treasure;
		public var _showing_back:Boolean = false;
		public var _shrunk:Boolean = false;
		public var _moving_to:FlxPoint;
		public var _is_moving:Boolean = false;
		public var _discardBtn:FlxButtonPlus;
		public var _cost:int = 0;
		
		private var _playState:PlayState;
		
		public function Card(playState:PlayState, X:int = 0, Y:int = 0, type:String = "", tile:Tile = null, monster:Monster = null, treasure:Treasure = null) 
		{
			super();
			
			_playState = playState;
			
			if (type == "") {
				type = CARDS_WEIGHTED[Math.floor(Math.random() * (CARDS_WEIGHTED.length))];
				trace("WARNING: random card type added");
			}
			_type = type;
			//trace("adding card " + type);
			
			switch (_type) {
				case "MONSTER":
					if (monster == null) {
						monster = _playState.dungeon.GetRandomMonster();
					}
					_background_frame = 0;
					_background_frame_back = 3;
					_type_icon_frame = 0;
					_card_text_color = 0xFF812222;
					_title = monster._type;
					_desc = monster._desc;
					_monster = new Monster(_playState, _title, X + ICON_OFFSET.x, Y + ICON_OFFSET.y);
					_cost = _monster._dread;
					_iconHolder.add(_monster);
					break;
				case "TREASURE":
					if (treasure == null) {
						treasure = _playState.dungeon.GetRandomTreasure();
					}
					_background_frame = 1;
					_background_frame_back = 4;
					_type_icon_frame = 1;
					_card_text_color = 0xFF003399;
					_title = treasure._type;
					_desc = treasure._desc;
					_treasure = new Treasure(_playState, _title, X + ICON_OFFSET.x, Y + ICON_OFFSET.y);
					_cost = _treasure._hope;
					_iconHolder.add(_treasure);
					break;
				case "TILE":
					if (tile == null) {
						tile = _playState.tileManager.GetRandomTile();
					}
					_title = tile.type;
					_background_frame = 2;
					_background_frame_back = 5;
					_type_icon_frame = 2;
					_card_text_color = 0xFF5C3425;
					_tile = new Tile(_playState, _title, X + ICON_TILE_OFFSET.x, Y + ICON_TILE_OFFSET.y);
					_tile.antialiasing = true;
					_tile.scale = new FlxPoint(0.5, 0.5);
					_tile.width = _tile.width * 0.5;
					_tile.height = _tile.height * 0.5;
					_tile.offset = new FlxPoint(_tile.width/2, _tile.height/2);
					_iconHolder.add(_tile);
					break;
				default:
					throw new Error("no matching card type defined for " + type);
			}

			if (_type == "TILE") {
				if (_title.indexOf("corr") == 0) {
					_title = "Corridor";
					_desc = "Where might it lead?";
				} else {
					_title = "Room";
					_desc = "What might be inside?";
				}
			} 
			
			_background = new FlxSprite(X, Y);
			_background.loadGraphic(cardBackgroundsPNG, false, false, CARD_WIDTH, CARD_HEIGHT);
			_background.frame = _background_frame;
			this.add(_background);
			
			_card_front.add(_iconHolder);
			
			_type_icon = new FlxSprite(X + TYPE_OFFSET.x, Y + TYPE_OFFSET.y);
			_type_icon.loadGraphic(cardSymbolsPNG, false, false, 38, 50);
			_type_icon.frame = _type_icon_frame;
			_card_front.add(_type_icon);
			
			_scrolls = new FlxSprite(X + SCROLLS_OFFSET.x, Y + SCROLLS_OFFSET.y, cardScrollsPNG);
			_card_front.add(_scrolls);
			
			_titleText = new FlxText(X + TITLE_OFFSET.x, Y + TITLE_OFFSET.y, 116, _title);
			_titleText.height = 22;
			_titleText.setFormat("LemonsCanFly", 30, _card_text_color, "center");
			_card_front.add(_titleText);
			
			_descText = new FlxText(X + DESC_OFFSET.x, Y + DESC_OFFSET.y, 100, _desc);
			_descText.height = 48;
			_descText.setFormat("LemonsCanFly", 20, _card_text_color, "center");
			_card_front.add(_descText);
			
			_cost_icon = new FlxSprite(X + COST_ICON_OFFSET.x, Y + COST_ICON_OFFSET.y);
			_cost_icon.loadGraphic(cardSymbolsPNG, false, false, 38, 50);
			_cost_icon.frame = 3;
			_card_front.add(_cost_icon);
			
			_costText = new FlxText(X + COST_OFFSET.x, Y + COST_OFFSET.y, 20, _desc.toUpperCase());
			_costText.height = 18;
			_costText.setFormat("LemonsCanFly", 30, _card_text_color, "center");
			_costText.text = _cost.toString();
			if (_cost > 0) {
				_card_front.add(_costText);
			}
			
			this.add(_card_front);
			
			_hoverEffect = new FlxSprite(X, Y);
			_hoverEffect.makeGraphic(CARD_WIDTH, CARD_HEIGHT, _card_text_color);
			_hoverEffect.alpha = 0.3;
			_hoverEffect.visible = false;
			this.add(_hoverEffect);
			
			_discardBtn = new FlxButtonPlus(X + DISCARD_OFFSET.x, Y + DISCARD_OFFSET.y, discardThisCard, null, "Discard", 70, 30);
			_discardBtn.textNormal.setFormat("LemonsCanFly", 30, 0xFFEAE2AC, "center", 0xFF6E533F);
			_discardBtn.textHighlight.setFormat("LemonsCanFly", 30, 0xFFEAE2AC, "center", 0xFF6E533F);
			_discardBtn.borderColor = 0xFFEAE2AC;
			_discardBtn.updateInactiveButtonColors([0xFFA38C69, 0xFFA38C69]);
			_discardBtn.updateActiveButtonColors([0xFF6E533F, 0xFF6E533F]);   
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
				if (_tile != null) {
					_tile.x += change_x;
					_tile.y += change_y;
				}
				if (_monster != null) {
					_monster.x += change_x;
					_monster.y += change_y;
				}
				if (_treasure != null) {
					_treasure.x += change_x;
					_treasure.y += change_y;
				}
				_titleText.x += change_x;
				_titleText.y += change_y;
				_descText.x += change_x;
				_descText.y += change_y;
				_costText.x += change_x;
				_costText.y += change_y;
				_scrolls.x += change_x;
				_scrolls.y += change_y;
				_cost_icon.x += change_x;
				_cost_icon.y += change_y;
				_type_icon.x += change_x;
				_type_icon.y += change_y;
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