package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;

	public class MenuState extends FlxState
	{
		[Embed(source = "../assets/title_screen.jpg")] private var ARTtitleScreen:Class;
		[Embed(source = "../assets/Crushed.ttf", fontFamily = "Crushed", embedAsCFF = "false")] public	var	FONTCrushed:String;
		
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
			FlxG.bgColor = 0xFF333333;
			
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
			
			var title:FlxText = new FlxText(0, 300, 1024, titleString);
			title.setFormat("Crushed", 36, 0xFFFF8A8A, "center", 0);
						
			var results:FlxText = new FlxText(0, 340, 1024, resultsString);
			results.setFormat("Crushed", 24, 0xFFFF8A8A, "center", 0);	
			
			var startButton:FlxButtonPlus = new FlxButtonPlus(400, 600, startGame, null, "START GAME", 320, 50);
			startButton.textNormal.setFormat("Crushed", 36, 0xFF812222, "center", 0);
			startButton.textHighlight.setFormat("Crushed", 36, 0xFF812222, "center", 0);
			startButton.borderColor = 0xFF5C3425;
			startButton.updateInactiveButtonColors([0xFFFFCCCC, 0xFFFF8A8A]);
			startButton.updateActiveButtonColors([0xFFFF8A8A, 0xFFFFCCCC]);
			startButton.screenCenter();			
			
			add(titleScreen);
			add(title);
			add(results);
			add(startButton);
			
			FlxG.switchState(new PlayState);
		}

		private function startGame():void {
			FlxG.fade(0xFF333333, 1, finishedFade);
		}
		
		private function finishedFade():void {
			FlxG.switchState(new PlayState);
		}
	}
}