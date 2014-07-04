package  
{
	import org.flixel.*;
	import flash.display.Graphics;
	
	public class Gamb 
	{
		
		public static function drawPathAsLine(Sprite:FlxSprite, Path:Array, Color:uint=0xFF000000, Thickness:uint=1, Fill:uint=0x00000000):void
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
					
					gfx.lineStyle(Thickness, Color, alphaComponent);
					gfx.lineTo(pt.x, pt.y);
				}
				
				if (Fill != 0x00000000) {
					gfx.beginFill(Fill);
					gfx.drawRect(pt.x - 2, pt.y - 2, 4, 4);
					gfx.endFill();
					gfx.moveTo(pt.x, pt.y);
				}
				
				// Draw line to bitmap
				Sprite.pixels.draw(FlxG.flashGfxSprite); // EDIT! changed so we draw to the Sprite that was passed
				Sprite.dirty = true;
			}
		}
	}

}