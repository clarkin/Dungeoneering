package
{
    import org.flixel.system.FlxPreloader;
 
	public class Preloader extends GambrinousPreloader
	{
		public function Preloader():void
		{
			className = "Dungeoneering";
			myURL = "gambrinous.com/games/dungeoneering/";
			VERSION = "0.6.3"
			super();
		}
	}
}
