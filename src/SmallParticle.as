package  
{
	import org.flixel.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class SmallParticle extends FlxParticle {
		
		private var _targetPoint:FlxPoint;
		private var _lifetime:Number = 0.5;
		private var _variance:FlxPoint;
		
		public function SmallParticle(targetPoint:FlxPoint) {
			super();
			
			var size:int = Math.random() * 3 + 7;
			var variance_x:int = Math.random() * 30 - 15;
			var variance_y:int = Math.random() * 30 - 15;
			
			_variance = new FlxPoint(variance_x, variance_y);
			exists = false;
			_targetPoint = targetPoint;
			this.scrollFactor.x = this.scrollFactor.y = 0;
			makeGraphic(size, size, 0xFF2A72BB);
		}
		
		override public function onEmit():void {
			x += _variance.x;
			y += _variance.y;
			
			//start moving towards target point
			TweenLite.to(this, _lifetime, { x:_targetPoint.x, y:_targetPoint.y, ease:Quart.easeIn } );
		}
		
	}

}