package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;

	public class MenuState extends FlxState
	{
		[Embed(source = "../assets/title_screen.jpg")] private var ARTtitleScreen:Class;
		[Embed(source = "../assets/play_button.png")] private var ARTplayBtn:Class;
		[Embed(source = "../assets/play_button_on.png")] private var ARTplayBtnOn:Class;
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
			
			var title:FlxText = new FlxText(0, 350, 1024, titleString);
			title.setFormat("Crushed", 36, 0xFF6E533F, "center", 0xFFEAE2AC);
			title.visible = false;
						
			var results:FlxText = new FlxText(0, 390, 1024, resultsString);
			results.setFormat("Crushed", 24, 0xFF6E533F, "center", 0xFFEAE2AC);	
			results.visible = false;
			
			var startButton:FlxButtonPlus = new FlxButtonPlus(400, 650, startGame, null, "", 150, 62);
			var playButton:FlxSprite = new FlxSprite(0, 0, ARTplayBtn);
			var playButtonOn:FlxSprite = new FlxSprite(0, 0, ARTplayBtnOn);
			startButton.loadGraphic(playButton, playButtonOn);
			startButton.screenCenter();
			
			add(titleScreen);
			add(title);
			add(results);
			add(startButton);
			
			//FlxG.switchState(new PlayState);
		}

		private function startGame():void {
			FlxG.fade(0xFFEEEEEE, 1, finishedFade);
		}
		
		private function finishedFade():void {
			FlxG.switchState(new PlayState);
		}
	}
}