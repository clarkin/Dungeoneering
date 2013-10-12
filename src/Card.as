package 
{
	import org.flixel.*;
	
	public class Card extends FlxGroup
	{
		[Embed(source = "../assets/ass_char_tran.png")] private var charactersPNG:Class;
		[Embed(source = "../assets/card.png")] private var cardPNG:Class;
		[Embed(source = "../assets/Crushed.ttf", fontFamily = "Crushed", embedAsCFF = "false")] public	var	FONTCrushed:String;
		
		public static const ALL_CARDS:Array = [
			"Runty Goblin", "Goblin Leader", 
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
				type = ALL_CARDS[Math.floor(Math.random() * (ALL_CARDS.length))];
				trace("choosing random type for card: " + type);
			}
			
			this.title = type;
			switch (type) {
				case "Runty Goblin":
					this.desc = "A small goblin. Shouldn't be much of a threat for a competent adventurer..";
					break;
				case "Goblin Leader":
					this.desc = "Bigger and meaner than the usual runt.";
					break;
				case "Short Sword":
					this.desc = "A dull sword about a foot long. Easy to use but without much reach.";	
					break;
				case "Magic Axe":
					this.desc = "This axe gleams and shines in the darkness with an inner fire.";
					break;
				default:
					throw new Error("no matching card type defined for " + type);
			}
			
			_background = new FlxSprite(X, Y);
			_background.loadGraphic(cardPNG, false, false, 100, 140);
			this.add(_background);
			
			_titleText = new FlxText(X + 2, Y + 2, 96, title);
			_titleText.height = 23;
			_titleText.setFormat("Crushed", 18, 0x5C3425, "center", 0x000000);
			this.add(_titleText);
			
			_descText = new FlxText(X + 2, Y + 58, 96, desc);
			_descText.height = 80;
			_descText.setFormat("Crushed", 14, 0x5C3425, "center", 0x000000);
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