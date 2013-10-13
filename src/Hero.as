package 
{
	import org.flixel.*;
	
	public class Hero extends FlxSprite
	{
		[Embed(source = "../assets/ass_char_tran.png")] private var charactersPNG:Class;
		
		public static const TILESIZE:int = 42;
		public static const SPEED:int = 4;
		
		private var tile_offset_x:int = 5;
		private var tile_offset_y:int = 12;
		
		public var current_tile:Tile;
		public var moving_to_tile:Tile;
		public var is_taking_turn:Boolean = false;
		
		public function Hero(X:int = 0, Y:int = 0) 
		{
			super(X + tile_offset_x, Y + tile_offset_y);
			
			loadGraphic(charactersPNG, false, true, 24, 24);

			addAnimation("knight1", [36]);
			play("knight1");
		}
		
		override public function update():void {	
			//trace("current tile: " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
			//trace("moving to tile: " + moving_to_tile.type + " at [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			//trace("currently at : [" + x + "," + y + "], moving to [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
			
			if (is_taking_turn) {
				checkMovement();
			}
			
			super.update();
		}
		
		private function checkMovement():void {
			if (current_tile != moving_to_tile) {
				var distance_x:int = moving_to_tile.x + tile_offset_x - x;
				var distance_y:int = moving_to_tile.y + tile_offset_y - y;
				
				x += distance_x * FlxG.elapsed * SPEED;
				y += distance_y * FlxG.elapsed * SPEED;
				
				if (distance_x >= -1 && distance_x <= 1 && distance_y >= -1 && distance_y <= 1) {
					setCurrentTile(moving_to_tile);
					is_taking_turn = false;
				}
			}
		}
		
		public function setCurrentTile(new_tile:Tile):void {
			current_tile = new_tile;
			x = new_tile.x + tile_offset_x;
			y = new_tile.y + tile_offset_y;
			trace("** hero at target tile ** " + current_tile.type + " at [" + current_tile.x + "," + current_tile.y + "]");
		}
		
		public function setMovingToTile(new_tile:Tile):void {
			moving_to_tile = new_tile;
			is_taking_turn = true;
			trace("** hero now moving to target tile ** " + moving_to_tile.type + " at [" + moving_to_tile.x + "," + moving_to_tile.y + "]");
		}
	}
}