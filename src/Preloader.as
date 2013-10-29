package
{
    import org.flixel.system.FlxPreloader;
 
	public class Preloader extends FlxPreloader
	{
		public function Preloader():void
		{
			className = "Dungeoneering";
			myURL = "http://gambrinous.com/games/dungeoneering/";
			super();
		}
	}
}
