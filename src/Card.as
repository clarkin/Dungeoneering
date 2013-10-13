package 
{
	import org.flixel.*;
	
	public class Card extends FlxGroup
	{
		[Embed(source = "../assets/ass_char_tran.png")] private var charactersPNG:Class;
		[Embed(source = "../assets/card_backgrounds.png")] private var cardBackgroundsPNG:Class;
		[Embed(source = "../assets/Crushed.ttf", fontFamily = "Crushed", embedAsCFF = "false")] public	var	FONTCrushed:String;
		
		public static const CARDS_WEIGHTED:Array = [
			"MONSTER", "MONSTER", "MONSTER", "WEAPON", "WEAPON", "TREASURE"];
		public static const ALL_MONSTERS:Array = [
			"Runty Goblin", "Goblin Leader"];
		public static const ALL_TREASURE:Array = [
			"Silver Coins", "Small Chest", "Coin Pouch"];
		public static const ALL_WEAPONS:Array = [
			"Short Sword", "Magic Axe"];

		public var title:String = "";
		public var desc:String = "";
		public var card_type:String = "";

		private static const TITLE_OFFSET:FlxPoint = new FlxPoint(1,1);
		private static const ICON_OFFSET:FlxPoint = new FlxPoint(54, 45);
		private static const DESC_OFFSET:FlxPoint = new FlxPoint(1, 95);
		private static const CARD_WIDTH:int = 150;
		private static const CARD_HEIGHT:int = 200;
		
		public var _background:FlxSprite;
		private var _background_frame:int = 0;
		private var _card_text_color:uint = 0xFF000000;
		private var _titleText:FlxText;
		private var _descText:FlxText;
		private var _hoverEffect:FlxSprite;
		private var _iconHolder:FlxGroup = new FlxGroup();
		public var _tile:Tile;
		
		public function Card(X:int = 0, Y:int = 0, type:String = "") 
		{
			super();
			
			if (type == "") {
				type = CARDS_WEIGHTED[Math.floor(Math.random() * (CARDS_WEIGHTED.length))];
			}
			this.card_type = type;
			
			var card:String = "";
			switch (type) {
				case "MONSTER":
					card = ALL_MONSTERS[Math.floor(Math.random() * (ALL_MONSTERS.length))]
					_background_frame = 0;
					_card_text_color = 0xFF812222;
					break;
				case "TREASURE":
					card = ALL_TREASURE[Math.floor(Math.random() * (ALL_TREASURE.length))]
					_background_frame = 2;
					_card_text_color = 0xFF003399;
					break;
				case "WEAPON":
					card = ALL_WEAPONS[Math.floor(Math.random() * (ALL_WEAPONS.length))]
					_background_frame = 3;
					_card_text_color = 0xFF36632D;
					break;
				case "TILE":
					card = Tile.ALL_TILES[Math.floor(Math.random() * (Tile.ALL_TILES.length))]
					_background_frame = 1;
					_card_text_color = 0xFF5C3425;
					_tile = new Tile(card, X + ICON_OFFSET.x, Y + ICON_OFFSET.y);
					_iconHolder.add(_tile);
					break;
				default:
					throw new Error("no matching card type defined for " + type);
			}
			
			this.title = card;
			switch (card) {
				case "Runty Goblin":
					this.desc = "A small goblin. Shouldn't be much of a threat for a competent adventurer..";
					break;
				case "Goblin Leader":
					this.desc = "Bigger and meaner than the usual runt.";
					break;
				case "Silver Coins":
					this.desc = "A handful of silver, strewn carelessly on the ground.";	
					break;
				case "Small Chest":
					this.desc = "An ornate wooden chest. What might be inside?";	
					break;
				case "Coin Pouch":
					this.desc = "Looks full. Could be a fortune in gold coins..";	
					break;
				case "Short Sword":
					this.desc = "A dull sword about a foot long. Easy to use but without much reach.";	
					break;
				case "Magic Axe":
					this.desc = "This axe gleams and shines in the darkness with an inner fire.";
					break;
				default:
					if (card_type == "TILE") {
						if (card.indexOf("corr") == 0) {
							this.title = "Corridor";
							this.desc = "Where might it lead?";
						} else {
							this.title = "Room";
							this.desc = "What might be inside?";
						}
					} else {
						throw new Error("no matching card defined for " + card);
					}
			}
			
			_background = new FlxSprite(X, Y);
			_background.loadGraphic(cardBackgroundsPNG, false, false, CARD_WIDTH, CARD_HEIGHT);
			_background.frame = _background_frame;
			this.add(_background);
			
			_titleText = new FlxText(X + TITLE_OFFSET.x, Y + TITLE_OFFSET.y, 148, title.toUpperCase());
			_titleText.height = 32;
			_titleText.setFormat("Crushed", 26, _card_text_color, "center");
			this.add(_titleText);
			
			_descText = new FlxText(X + DESC_OFFSET.x, Y + DESC_OFFSET.y, 148, desc.toUpperCase());
			_descText.height = 104;
			_descText.setFormat("Crushed", 16, _card_text_color, "center");
			this.add(_descText);
			
			this.add(_iconHolder);
			
			_hoverEffect = new FlxSprite(X, Y);
			_hoverEffect.makeGraphic(CARD_WIDTH, CARD_HEIGHT, _card_text_color);
			_hoverEffect.alpha = 0.3;
			_hoverEffect.visible = false;
			this.add(_hoverEffect);
			
			//trace("card: " + this.title + " of type " + this.card_type);
		}
		
		override public function update():void {	
			//trace("current tile: " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
			//trace("moving to tile: " + moving_to_tile.type + " at [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			//trace("currently at : [" + x + "," + y + "], moving to [" + moving_to_tile.x + "," + moving_to_tile.y + "]");

			checkHover();
			
			super.update();
		}
		
		public function checkHover():void {
			if (_background.overlapsPoint(FlxG.mouse.getWorldPosition())) {
				_hoverEffect.visible = true;
			} else {
				_hoverEffect.visible = false;
			}
			//trace("mouse at [" + FlxG.mouse.x + "," + FlxG.mouse.y + "], visible: " + _hoverEffect.visible);
		}

	}
}