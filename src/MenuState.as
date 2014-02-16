package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import com.greensock.*;
	import com.greensock.easing.*;

	public class MenuState extends FlxState
	{
		[Embed(source = "../assets/title_screen.jpg")] private var ARTtitleScreen:Class;
		[Embed(source = "../assets/play_button.png")] private var ARTplayBtn:Class;
		[Embed(source = "../assets/play_button_on.png")] private var ARTplayBtnOn:Class;
		[Embed(source = "../assets/Lemons Can Fly.ttf", fontFamily = "LemonsCanFly", embedAsCFF = "false")] public var	FONTLemonsCanFly:String;
		
		public var showResults:Boolean = true;
		public var survived:Boolean = true;
		public var finalScore:int = 0;
		public var whiteFade:FlxSprite;

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
			title.setFormat("LemonsCanFly", 36, 0xFF6E533F, "center", 0xFFEAE2AC);
			title.visible = false;
						
			var results:FlxText = new FlxText(0, 390, 1024, resultsString);
			results.setFormat("LemonsCanFly", 24, 0xFF6E533F, "center", 0xFFEAE2AC);	
			results.visible = false;
			
			var startButton:FlxButtonPlus = new FlxButtonPlus(400, 650, startGame, null, "", 150, 62);
			var playButton:FlxSprite = new FlxSprite(0, 0, ARTplayBtn);
			var playButtonOn:FlxSprite = new FlxSprite(0, 0, ARTplayBtnOn);
			startButton.loadGraphic(playButton, playButtonOn);
			startButton.screenCenter();
			
			whiteFade = new FlxSprite(0, 0);
			whiteFade.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
			whiteFade.scrollFactor = new FlxPoint(0, 0);
			whiteFade.DisappearAlpha(0, false);
			
			add(titleScreen);
			add(title);
			add(results);
			add(startButton);
			add(whiteFade);
			
			if (FlxG.debug) {
				startGame();
			}
		}

		private function startGame():void {
			whiteFade.AppearAlpha();
			TweenLite.delayedCall(1.0, FinishedFade);
		}
		
		private function FinishedFade():void {
			
			FlxG.switchState(new PlayState);
		}
	}
}