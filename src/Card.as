package 
{
	import flash.geom.*;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class Card extends FlxGroup
	{
		[Embed(source = "../assets/card_backgrounds_colour.png")] private var cardBackgroundsPNG:Class;
		[Embed(source = "../assets/card_scroll.png")] private var cardScrollPNG:Class;
		[Embed(source = "../assets/card_textbox.png")] private var cardTextboxPNG:Class;
		[Embed(source = "../assets/card_tile_outline.png")] private var cardTileOutlinePNG:Class;
		[Embed(source = "../assets/card_symbols.png")] private var cardSymbolsPNG:Class;
		[Embed(source = "../assets/cancel_off.png")] private var cardCancelOffPNG:Class;
		[Embed(source = "../assets/cancel_on.png")] private var cardCancelOnPNG:Class;
		
		public static const CARDS_WEIGHTED:Array = [
			"MONSTER", "MONSTER", "MONSTER", "TREASURE", "TREASURE"];

		private static const SCROLL_TOP_OFFSET:FlxPoint = new FlxPoint(16, 26);
		private static const SCROLL_BOTTOM_OFFSET:FlxPoint = new FlxPoint(16, 135);
		private static const SCROLL_TITLE_OFFSET:FlxPoint = new FlxPoint(2, 15);
		private static const TYPE_OFFSET:FlxPoint = new FlxPoint(6, 8);
		private static const COST_ICON_OFFSET:FlxPoint = new FlxPoint(110, 8);
		private static const COST_OFFSET:FlxPoint = new FlxPoint(118, 14);
		private static const ICON_OFFSET:FlxPoint = new FlxPoint(18, 30);
		private static const ICON_TILE_OFFSET:FlxPoint = new FlxPoint(38, 50); 
		private static const DESC_OFFSET:FlxPoint = new FlxPoint(28, 140);
		private static const DISCARD_OFFSET:FlxPoint = new FlxPoint(105, 180);
		private static const CARD_WIDTH:int = 154;
		private static const CARD_HEIGHT:int = 204;
		public static const TIME_TO_MOVE:Number = 1.0;
		public static const TIME_TO_APPEAR:Number = 0.2;
		public static const TIME_TO_DISAPPEAR:Number = 0.3;
		
		public var _title:String = "";
		public var _desc:String = "";
		public var _type:String = "";
		public var _type_icon:FlxSprite;
		public var _scroll:FlxSprite;
		public var _textbox:FlxSprite;
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
		public var _card_front:FlxSprite;
		public var _card_back:FlxSprite;
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
				tr("WARNING: random card type added");
			}
			_type = type;
			//tr("adding card " + type);
			
			_card_front = new FlxSprite(X, Y);
			_card_front.makeGraphic(CARD_WIDTH, CARD_HEIGHT, 0x00FFFFFF, true);
			_card_front.antialiasing = true;
			_card_back = new FlxSprite(X, Y);
			_card_back.makeGraphic(CARD_WIDTH, CARD_HEIGHT, 0x00FFFFFF, true);
			var _card_stamper:FlxSprite = new FlxSprite(X, Y);
			_card_stamper.makeGraphic(CARD_WIDTH, CARD_HEIGHT, 0x00FFFFFF, true);
			var _card_backgrounds:FlxSprite = new FlxSprite(X, Y);
			_card_backgrounds.loadGraphic(cardBackgroundsPNG, true, false, CARD_WIDTH, CARD_HEIGHT);
			//TODO _card_backgrounds could be static/preloaded somewhere
			
			switch (_type) {
				case "MONSTER":
					if (monster == null) {
						monster = _playState.dungeon.GetRandomMonster();
					}
					_card_backgrounds.frame = 3;
					_card_backgrounds.drawFrame(true);
					_card_back.stamp(_card_backgrounds);
					
					_card_backgrounds.frame = 0;
					_card_backgrounds.drawFrame(true);
					_card_stamper.stamp(_card_backgrounds);

					_type_icon_frame = 0;
					_card_text_color = 0xFF333333;
					_title = monster._type;
					_desc = monster._desc;
					_monster = new Monster(_playState, _title, false, true);
					_card_stamper.stamp(_monster, ICON_OFFSET.x, ICON_OFFSET.y);
					_cost = _monster._dread;
					break;
				case "TREASURE":
					if (treasure == null) {
						treasure = _playState.dungeon.GetRandomTreasure();
					}
					_card_backgrounds.frame = 4;
					_card_backgrounds.drawFrame(true);
					_card_back.stamp(_card_backgrounds);
					
					_card_backgrounds.frame = 1;
					_card_backgrounds.drawFrame(true);
					_card_stamper.stamp(_card_backgrounds);
					
					_type_icon_frame = 1;
					_card_text_color = 0xFF333333;
					_title = treasure._type;
					_desc = treasure._desc;
					_treasure = new Treasure(_playState, _title, false, true);
					_card_stamper.stamp(_treasure, ICON_OFFSET.x, ICON_OFFSET.y);
					_cost = _treasure._hope;
					break;
				case "TILE":
					if (tile == null) {
						tile = _playState.tileManager.GetRandomTile();
					}
					_card_backgrounds.frame = 5;
					_card_backgrounds.drawFrame(true);
					_card_back.stamp(_card_backgrounds);
					
					_card_backgrounds.frame = 2;
					_card_backgrounds.drawFrame(true);
					_card_stamper.stamp(_card_backgrounds);
					
					_type_icon_frame = 2;
					_card_text_color = 0xFF333333;
					_title = tile.type;
					
					var tile_outline:FlxSprite = new FlxSprite(X, Y, cardTileOutlinePNG);
					_card_stamper.stamp(tile_outline, ICON_TILE_OFFSET.x - 3, ICON_TILE_OFFSET.y - 3);
					
					_tile = new Tile(_playState, _title, false);
					_card_stamper.stamp(_tile, ICON_TILE_OFFSET.x, ICON_TILE_OFFSET.y);
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
			
			_type_icon = new FlxSprite(X, Y);
			_type_icon.loadGraphic(cardSymbolsPNG, false, false, 38, 50);
			_type_icon.frame = _type_icon_frame;
			_card_stamper.stamp(_type_icon, TYPE_OFFSET.x, TYPE_OFFSET.y);
			
			_descText = new FlxText(X, Y, 100, _desc);
			_descText.height = 48;
			_descText.setFormat("LemonsCanFly", 20, _card_text_color, "center");
			//_card_stamper.stamp(_descText, DESC_OFFSET.x, DESC_OFFSET.y);
			
			_cost_icon = new FlxSprite(X, Y);
			_cost_icon.loadGraphic(cardSymbolsPNG, false, false, 38, 50);
			_cost_icon.frame = 3;
			_card_stamper.stamp(_cost_icon, COST_ICON_OFFSET.x, COST_ICON_OFFSET.y);
			
			_costText = new FlxText(X, Y, 20);
			_costText.height = 18;
			_costText.setFormat("LemonsCanFly", 30, _card_text_color, "center");
			_costText.text = _cost.toString();
			if (_cost > 0) {
				_card_stamper.stamp(_costText, COST_OFFSET.x, COST_OFFSET.y);
			}
			
			_scroll = new FlxSprite(X, Y, cardScrollPNG);
			_card_stamper.stamp(_scroll, SCROLL_BOTTOM_OFFSET.x, SCROLL_BOTTOM_OFFSET.y);
			
			_titleText = new FlxText(X, Y, 118, _title);
			_titleText.height = 22;
			_titleText.setFormat("LemonsCanFly", 30, _card_text_color, "center");
			_card_stamper.stamp(_titleText, SCROLL_BOTTOM_OFFSET.x + SCROLL_TITLE_OFFSET.x, SCROLL_BOTTOM_OFFSET.y + SCROLL_TITLE_OFFSET.y);
			
			_card_front.stamp(_card_stamper, 0, 0);
			_card_front.scrollFactor = new FlxPoint(0, 0);
			this.add(_card_front);
			
			_hoverEffect = new FlxSprite(X, Y);
			_hoverEffect.makeGraphic(CARD_WIDTH, CARD_HEIGHT, _card_text_color);
			_hoverEffect.alpha = 0.6;
			_hoverEffect.visible = false;
			_hoverEffect.antialiasing = true;
			_hoverEffect.scrollFactor = new FlxPoint(0, 0);
			_hoverEffect.blend = "overlay";
			this.add(_hoverEffect);
			
			_discardBtn = new FlxButtonPlus(X + DISCARD_OFFSET.x, Y + DISCARD_OFFSET.y, discardThisCard, null, "", 30, 30);
			_discardBtn.loadGraphic(new FlxSprite(0, 0, cardCancelOffPNG), new FlxSprite(0, 0, cardCancelOnPNG));
			_discardBtn.setAll("scrollFactor", new FlxPoint(0, 0));
			this.add(_discardBtn);
			
			_card_back.visible = false;
			_card_back.antialiasing = true;
			_card_back.scrollFactor = new FlxPoint(0, 0);
			this.add(_card_back);
			
			this.showBack();
		}
		
		override public function update():void {	
			//tr("current tile: " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
			//tr("moving to tile: " + moving_to_tile.type + " at [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			//tr("currently at : [" + x + "," + y + "], moving to [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			
			
			//checkMovement();
			checkHover();
			
			super.update();
		}
		
		public function MoveTo(move_to_point:FlxPoint, new_angle:Number = 0, new_scale:Number = 1.0):void {
			TweenLite.to(this, TIME_TO_MOVE, { x:move_to_point.x, y:move_to_point.y, angle:new_angle, bothScale:new_scale, ease:Back.easeInOut.config(0.8) } );
			//card_in_hand._is_moving = true;
		}
		
		public function Appear(delay:Number = 0):void {
			var final_scale:Number = bothScale;
			bothScale = 0.0;
			TweenLite.to(this, TIME_TO_APPEAR, { bothScale:final_scale, delay:delay, ease:Back.easeInOut.config(0.8) } );
		}
		
		public function Disappear():void {
			_discardBtn.visible = false;
			TweenLite.to(this, TIME_TO_DISAPPEAR, { bothScale:0.0, ease:Back.easeInOut.config(0.8) } );
			TweenLite.delayedCall(TIME_TO_DISAPPEAR, FinishedDisappear);
		}
		
		public function FinishedDisappear():void {
			_playState.discardCard(this);
			kill();
		}
		
		public function discardThisCard():void {
			if (!_playState.is_placing_card) {
				Disappear();
				
			}
		}
		
		public function get x():Number {
			return _card_front.x;
		}
		
		public function set x(new_x:Number):void {
			var change_x:Number = new_x - x;
			_card_front.x += change_x;
			_card_back.x += change_x;
			_hoverEffect.x += change_x;
			_discardBtn.x += change_x;
		}
		
		public function get y():Number {
			return _card_front.y;
		}
		
		public function set y(new_y:Number):void {
			var change_y:Number = new_y - y;
			_card_front.y += change_y;
			_card_back.y += change_y;
			_hoverEffect.y += change_y;
			_discardBtn.y += change_y;
		}
		
		public function get angle():Number {
			return _card_front.angle;
		}
		
		public function set angle(new_angle:Number):void {
			_card_front.angle = new_angle;
			_card_back.angle = new_angle;
			_hoverEffect.angle = new_angle;
			//_discardBtn.angle = new_angle;
		}
		
		public function get bothScale():Number {
			return _card_front.scale.x;
		}
		
		public function set bothScale(newScale:Number):void {
			_card_front.scale.x = _card_front.scale.y = newScale;
			_card_back.scale.x = _card_back.scale.y = newScale;
		}
		
		public function checkHover():void {
			if (_hover_enabled && !_showing_back && bothScale == 1.0 && clickableAt(FlxG.mouse.getScreenPosition())) {
				_hoverEffect.visible = true;
			} else {
				_hoverEffect.visible = false;
			}
			//tr("mouse at [" + FlxG.mouse.x + "," + FlxG.mouse.y + "], visible: " + _hoverEffect.visible);
		}
		
		public function clickableAt(point:FlxPoint):Boolean {
			return (_card_front.overlapsPoint(point) && !_discardBtn.buttonNormal.overlapsPoint(point));
		}
		
		public function showBack():void {
			_showing_back = true;
			_discardBtn.visible = false;
			_card_front.visible = false;
			_card_back.visible = true;
		}
		
		public function showFront():void {
			_showing_back = false;
			_discardBtn.visible = true;
			_card_front.visible = true;
			_card_back.visible = false;
		}

	}
}