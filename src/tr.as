package {
	import flash.utils.getTimer;
	
	public function tr(msg:String):void {
		var seconds:Number = getTimer() / 1000.0;
		trace(seconds.toFixed(3) + ": " + msg);
	}
}