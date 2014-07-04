package  
{
	import org.flixel.*;
	import flash.display.Graphics;
	
	public class Gamb 
	{
		
		public static function drawPathAsLine(Sprite:FlxSprite, Path:Array, Color:uint=0xFF000000, Thickness:uint=1, Outline:uint=0x00000000):void
		{
			if (Path.length >= 2) {
				//Draw line
				var gfx:Graphics = FlxG.flashGfx;
				var tile:Tile = Path[0];
				var pt:FlxPoint = tile.getScreenXY();
				pt.x += tile.origin.x;
				pt.y += tile.origin.y;
				gfx.clear();
				gfx.moveTo(pt.x, pt.y); 
				
				var alphaComponent:Number = Number((Color >> 24) & 0xFF) / 255;
				if(alphaComponent <= 0) {
					alphaComponent = 1;
				}
				
				// EDIT! go through all remaining points and draw a line segment from the current position to the point
				for (var i:int = 1; i < Path.length; i++) {
					var last_point:FlxPoint = pt;
					tile = Path[i];
					pt = tile.getScreenXY();
					pt.x += tile.origin.x;
					pt.y += tile.origin.y;
					
					//outline
					if (Outline != 0x00000000) {
						var outline_adjustment:FlxPoint = new FlxPoint(0, 0);
						if (last_point.x - pt.x == 0) { //vertical line
							outline_adjustment.y = 1;
						} else {
							outline_adjustment.x = 1;
						}
						gfx.moveTo(last_point.x - outline_adjustment.x, last_point.y - outline_adjustment.y);
						gfx.lineStyle(Thickness + 2, Outline, alphaComponent);
						gfx.lineTo(pt.x + outline_adjustment.x, pt.y + outline_adjustment.y);
						gfx.moveTo(last_point.x, last_point.y);
					}
					
					gfx.lineStyle(Thickness, Color, alphaComponent);
					gfx.lineTo(pt.x, pt.y);
				}
				
				// Draw line to bitmap
				Sprite.pixels.draw(FlxG.flashGfxSprite); // EDIT! changed so we draw to the Sprite that was passed
				Sprite.dirty = true;
			}
		}
	}

}