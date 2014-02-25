package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import com.greensock.*;
	import com.greensock.easing.*;

	public class MenuState extends FlxState
	{
		[Embed(source = "../assets/title_screen.jpg")] private var ARTtitleScreen:Class;
		[Embed(source = "../assets/death_screen.png")] private var ARTdeathScreen:Class;
		[Embed(source = "../assets/play_button.png")] private var ARTplayBtn:Class;
		[Embed(source = "../assets/play_button_on.png")] private var ARTplayBtnOn:Class;
		[Embed(source = "../assets/Lemons Can Fly.ttf", fontFamily = "LemonsCanFly", embedAsCFF = "false")] public var	FONTLemonsCanFly:String;
		
		public static const APPEAR_DELAY:Number = 0.6;
		
		public var showResults:Boolean = true;
		public var survived:Boolean = true;
		public var finalScore:int = 0;
		public var whiteFade:FlxSprite;
		public var startButton:FlxButtonPlus;
		public var titleScreen:FlxSprite;
		public var deathScreen:FlxSprite;
		public var title:FlxText;
		public var results:FlxText;
		public var appearDelay:Number = APPEAR_DELAY;

		public function MenuState(showResults:Boolean = false, survived:Boolean = false, finalScore:int = 0)
		{
			this.showResults = showResults;
			this.survived = survived;
			this.finalScore = finalScore;
		}


		override public function create():void {
			FlxG.mouse.show();
			FlxG.bgColor = 0xFF333333;

			titleScreen = new FlxSprite(0, 0, ARTtitleScreen);
			
			startButton = new FlxButtonPlus(400, 650, startGame, null, "", 150, 62);
			var playButton:FlxSprite = new FlxSprite(0, 0, ARTplayBtn);
			var playButtonOn:FlxSprite = new FlxSprite(0, 0, ARTplayBtnOn);
			startButton.loadGraphic(playButton, playButtonOn);
			startButton.screenCenter();
			
			whiteFade = new FlxSprite(0, 0);
			whiteFade.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
			whiteFade.scrollFactor = new FlxPoint(0, 0);
			//whiteFade.DisappearAlpha(0, false);
			
			deathScreen = new FlxSprite(43, 115, ARTdeathScreen);
			deathScreen.visible = false;
			
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
			title = new FlxText(0, 350, 1024, titleString);
			title.setFormat("LemonsCanFly", 120, 0xFF333333, "center");
			title.visible = false;
			
			results = new FlxText(0, 390, 1024, resultsString);
			results.setFormat("LemonsCanFly", 24, 0xFF333333, "center");	
			results.visible = false;
			
			add(titleScreen);
			
			add(deathScreen);
			add(title);
			add(results);
			add(whiteFade);
			
			add(startButton);
			
			if (showResults) {
				deathScreen.visible = true;
				deathScreen.AppearAlpha(appearDelay);
				appearDelay += APPEAR_DELAY;
				
				title.visible = true;
				title.AppearAlpha(appearDelay);
				appearDelay += APPEAR_DELAY;
				
				results.visible = true;
				results.AppearAlpha(appearDelay);
				appearDelay += APPEAR_DELAY;
			} else {
				whiteFade.DisappearAlpha(0, false);
				TweenLite.delayedCall(appearDelay, resetStartBtn);
			}
			
			
			
			
			if (FlxG.debug) {
				//startGame();
			}
		}

		private function startGame():void {
			whiteFade.AppearAlpha();
			TweenLite.delayedCall(1.0, FinishedFade);
		}
		
		private function FinishedFade():void {
			FlxG.switchState(new PlayState);
		}
		
		override public function update():void {
			if (FlxG.mouse.justReleased() && showResults) {
				trace('hiding results');
				showResults = false;
				
				appearDelay = 0;
				
				results.DisappearAlpha(appearDelay, false);
				appearDelay += APPEAR_DELAY;
				
				title.DisappearAlpha(appearDelay, false);
				appearDelay += APPEAR_DELAY;
				
				deathScreen.DisappearAlpha(appearDelay, false);
				appearDelay += APPEAR_DELAY;
				
				whiteFade.DisappearAlpha(appearDelay, false);
				appearDelay += APPEAR_DELAY;
				
				TweenLite.delayedCall(appearDelay, resetStartBtn);
			}
		}
		
		public function resetStartBtn():void {
			results.visible = false;
			title.visible = false;
			deathScreen.visible = false;
			whiteFade.visible = false;
			startButton.resetToNormal();
		}

	}
}