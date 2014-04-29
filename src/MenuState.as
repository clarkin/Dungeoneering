package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import com.greensock.*;
	import com.greensock.easing.*;

	public class MenuState extends FlxState
	{
		[Embed(source = "../assets/title_screen.jpg")] private var ARTtitleScreen:Class;
		[Embed(source = "../assets/instructions.png")] private var ARTinstructions:Class;
		[Embed(source = "../assets/death_screen.png")] private var ARTdeathScreen:Class;
		[Embed(source = "../assets/win_screen.png")] private var ARTwinScreen:Class;
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
		public var instructionsScreen:FlxSprite;
		public var showingInstructions:Boolean = false;
		public var deathScreen:FlxSprite;
		public var winScreen:FlxSprite;
		public var title:FlxText;
		public var results:FlxText;
		public var appearDelay:Number = APPEAR_DELAY;
		public var clickHandled:Boolean = false;

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
			instructionsScreen = new FlxSprite(43, 115, ARTinstructions);
			instructionsScreen.visible = false;
			
			startButton = new FlxButtonPlus(400, 650, showInstructions, null, "", 150, 62);
			var playButton:FlxSprite = new FlxSprite(0, 0, ARTplayBtn);
			var playButtonOn:FlxSprite = new FlxSprite(0, 0, ARTplayBtnOn);
			startButton.loadGraphic(playButton, playButtonOn);
			startButton.screenCenter();
			
			whiteFade = new FlxSprite(0, 0);
			whiteFade.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
			whiteFade.scrollFactor = new FlxPoint(0, 0);
			
			deathScreen = new FlxSprite(43, 115, ARTdeathScreen);
			deathScreen.visible = false;
			
			winScreen = new FlxSprite(43, 115, ARTwinScreen);
			winScreen.visible = false;
			
			var titleString:String = "Instructions";
			var resultsString:String = "Explore the dungeon looking for treasure,\nbut beware the monsters..\n\nFind the treasure room if you can!";
			if (showResults) {
				if (survived) {
					titleString = "You did it!!!";
					resultsString = "You managed to find " + finalScore.toString() + " treasure!";
				} else {
					titleString = "You died!";
					resultsString = "You had found " + finalScore.toString() + " treasure so far..";
				}
			}
			title = new FlxText(500, 220, 400, titleString);
			title.setFormat("LemonsCanFly", 120, 0xFF333333, "center", 0xFF999999);
			title.visible = false;
			
			results = new FlxText(500, 340, 400, resultsString);
			results.setFormat("LemonsCanFly", 80, 0xFF333333, "center", 0xFF999999);	
			results.visible = false;
			
			add(titleScreen);
			add(startButton);
			add(instructionsScreen);
			add(whiteFade);
			add(deathScreen);
			add(winScreen);
			add(title);
			add(results);
			
			if (showResults) {
				TweenLite.to(whiteFade, FlxSprite.TIME_TO_DISAPPEAR * 2, { alpha:0.7, delay:appearDelay, ease:Sine.easeOut } );
				appearDelay += APPEAR_DELAY;
				
				if (survived) {
					winScreen.visible = true;
					winScreen.AppearAlpha(appearDelay);
					appearDelay += APPEAR_DELAY;
				} else {
					deathScreen.visible = true;
					deathScreen.AppearAlpha(appearDelay);
					appearDelay += APPEAR_DELAY;
				}
				
				title.visible = true;
				title.AppearAlpha(appearDelay);
				appearDelay += APPEAR_DELAY;
				
				results.visible = true;
				results.AppearAlpha(appearDelay);
				appearDelay += APPEAR_DELAY;
				
				startButton.visible = false;
			} else {
				whiteFade.visible = true;
				whiteFade.DisappearAlpha(0, false);
				appearDelay += FlxSprite.TIME_TO_DISAPPEAR * 2;
			}
			
			if (FlxG.debug && !showResults) {
				showingInstructions = true;
				TweenLite.delayedCall(appearDelay, startGame);
			}
		}
		
		private function showInstructions():void {
			clickHandled = true;
			startButton.visible = false;
			instructionsScreen.visible = true;
			showingInstructions = true;
			instructionsScreen.Appear();
			TweenLite.delayedCall(15, startGame);
		}

		private function startGame():void {
			if (showingInstructions) {
				showingInstructions = false;
				instructionsScreen.Disappear(0, false);
				whiteFade.AppearAlpha();
				TweenLite.delayedCall(FlxSprite.TIME_TO_APPEAR * 2 + APPEAR_DELAY, FinishedFade);
			}
		}
		
		private function FinishedFade():void {
			startButton.visible = true;
			instructionsScreen.visible = false;
			FlxG.switchState(new PlayState);
		}
		
		public function hideResults():void {
			showResults = false;
			appearDelay = 0;
			
			results.DisappearAlpha(appearDelay, false);
			appearDelay += APPEAR_DELAY;
			
			title.DisappearAlpha(appearDelay, false);
			appearDelay += APPEAR_DELAY;
			
			if (survived) {
				winScreen.DisappearAlpha(appearDelay, false);
				appearDelay += APPEAR_DELAY;
			} else {
				deathScreen.DisappearAlpha(appearDelay, false);
				appearDelay += APPEAR_DELAY;
			}
			
			whiteFade.DisappearAlpha(appearDelay, false);
			appearDelay += APPEAR_DELAY;
			
			TweenLite.delayedCall(appearDelay, resetStartBtn);
		}
		
		override public function update():void {

			if (FlxG.mouse.justReleased()) {
				if(showResults && !clickHandled) {
					hideResults();
				} else if (showingInstructions && !clickHandled) {
					startGame();
				}
			}
			
			resetClickHandled();
			super.update();
		}
		
		public function resetClickHandled():void {
			clickHandled = false;
		}
		
		public function resetStartBtn():void {
			startButton.visible = true;
		}
	}
}