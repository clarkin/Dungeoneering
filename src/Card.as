package 
{
	import org.flixel.*;
	
	public class Card extends FlxGroup
	{
		[Embed(source = "../assets/ass_char_tran.png")] private var charactersPNG:Class;
		[Embed(source = "../assets/card2.png")] private var cardPNG:Class;
		[Embed(source = "../assets/Crushed.ttf", fontFamily = "Crushed", embedAsCFF = "false")] public	var	FONTCrushed:String;
		
		public static const CARDS_WEIGHTED:Array = [
			"MONSTER", "MONSTER", "TREASURE"];
		public static const ALL_MONSTERS:Array = [
			"Runty Goblin", "Goblin Leader"];
		public static const ALL_TREASURE:Array = [
			"Silver Coins", "Small Chest", "Coin Pouch"];
		public static const ALL_WEAPONS:Array = [
			"Short Sword", "Magic Axe"];
		
		public var title:String = "";
		public var desc:String = "";
		public var card_type:String = "";

		private var _background:FlxSprite;
		private var _titleText:FlxText;
		private var _descText:FlxText;
		
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
					break;
				case "TREASURE":
					card = ALL_TREASURE[Math.floor(Math.random() * (ALL_TREASURE.length))]
					break;
				case "WEAPON":
					card = ALL_WEAPONS[Math.floor(Math.random() * (ALL_WEAPONS.length))]
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
					throw new Error("no matching card defined for " + card);
			}
			
			_background = new FlxSprite(X, Y);
			_background.loadGraphic(cardPNG, false, false, 150, 200);
			this.add(_background);
			
			_titleText = new FlxText(X + 1, Y + 1, 148, title.toUpperCase());
			_titleText.height = 32;
			_titleText.setFormat("Crushed", 24, 0xFF5C3425, "center");
			this.add(_titleText);
			
			_descText = new FlxText(X + 1, Y + 55, 148, desc.toUpperCase());
			_descText.height = 124;
			_descText.setFormat("Crushed", 18, 0xFF5C3425, "center");
			this.add(_descText);
			
			trace("card: " + this.title + " of type " + this.card_type);
		}
		
		override public function update():void {	
			//trace("current tile: " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
			//trace("moving to tile: " + moving_to_tile.type + " at [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			//trace("currently at : [" + x + "," + y + "], moving to [" + moving_to_tile.x + "," + moving_to_tile.y + "]");

			
			super.update();
		}
		
		override public function draw():void {	
			_titleText.draw();
			
			super.draw();
		}

	}
}