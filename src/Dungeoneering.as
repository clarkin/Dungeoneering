package
{
	import org.flixel.*; 
	[SWF(width = "1024", height = "768", backgroundColor = "#000000")] 
	[Frame(factoryClass="Preloader")]
 
	public class Dungeoneering extends FlxGame
	{
		public function Dungeoneering()
		{
			
			super(1024, 768, MenuState, 1); 
		}
	}
}