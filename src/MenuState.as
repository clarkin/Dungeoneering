package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;

	public class MenuState extends FlxState
	{
		[Embed(source = "../assets/title_screen.jpg")] private var ARTtitleScreen:Class;
		[Embed(source = "../assets/Popup.ttf", fontFamily = "Popup", embedAsCFF = "false")] public	var	FONTPopup:String;
		
		public var showResults:Boolean = true;
		public var survived:Boolean = true;
		public var finalScore:int = 0;

		public function MenuState(showResults:Boolean = false, survived:Boolean = false, finalScore:int = 0)
		{
			this.showResults = showResults;
			this.survived = survived;
			this.finalScore = finalScore;
		}


		override public function create():void {
			FlxG.mouse.show();
			
			var titleString:String = "Instructions";
			var resultsString:String = "Explore the dungeon looking for treasure,\nbut beware the monsters..\n\nFind the treasure room if you can!";
			if (showResults) {
				if (survived) {
					titleString = "You made it out!";
					resultsString = "You managed to find " + finalScore.toString() + " treasure!";
				} else {
					titleString = "You died!";
					resultsString = "You had found " + finalScore.toString() + " treasure so far..";
				}
			}
			
			var titleScreen:FlxSprite = new FlxSprite(0, 0, ARTtitleScreen);
			
			var title:FlxText = new FlxText(0, 200, 800, titleString);
			title.setFormat("Popup", 36, 0x5C3425, "center", 0);
			
			var results:FlxText = new FlxText(0, 240, 800, resultsString);
			results.setFormat("Popup", 24, 0x5C3425, "center", 0);	
			
			var startButton:FlxButtonPlus = new FlxButtonPlus(400, 500, startGame, null, "START GAME", 320, 40);
			startButton.textNormal.setFormat("Popup", 36, 0x5C3425, "center", 0);
			startButton.textHighlight.setFormat("Popup", 36, 0x5C3425, "center", 0);
			startButton.borderColor = 0xFF5C3425;
			startButton.updateInactiveButtonColors([0xFFC2A988, 0xFFFFFFCC]);
			startButton.updateActiveButtonColors([0xFFD54DFF, 0xFFF9E6FF]);
			startButton.screenCenter();			
			
			add(titleScreen);
			add(title);
			add(results);
			add(startButton);
			
			//FlxG.switchState(new PlayState);
		}

		private function startGame():void {
			FlxG.fade(0xFF000000, 1, finishedFade);
		}
		
		private function finishedFade():void {
			FlxG.switchState(new PlayState);
		}
	}
}