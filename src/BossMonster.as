package 
{
	import org.flixel.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class BossMonster extends FlxSprite
	{
		[Embed(source = "../assets/monster_spritesheet_120px_COLOUR.png")] private var charactersBossPNG:Class;
		
		public static const ICON_OFFSET:FlxPoint = new FlxPoint(10, 5);
		public static const SPRITE_SIZE:int = 120;
		public static const TIME_TO_MOVE:Number = 1.0;
		public static const OFFSCREEN_POINT:FlxPoint = new FlxPoint(-150, 120);
		public static const ONSCREEN_POINT:FlxPoint = new FlxPoint(12, 120);
		
		public var _type:String = "";
		public var _desc:String = "";
		public var _dread:Number = 0;
		
		public var _health:int = 1;
		public var _strength:int = 1;
		public var _speed:int = 1;
		public var _armour:int = 0;
		
		private var _playState:PlayState;
		
		private var _usedChats:Array = [];
		
		public function BossMonster(playState:PlayState, type:String, X:int = 0, Y:int = 0) 
		{
			super(X, Y);
			
			_playState = playState;
			_type = type;
			
			loadGraphic(charactersBossPNG, false, true, SPRITE_SIZE, SPRITE_SIZE);
			antialiasing = true;
						
			switch (_type) {
				case "Fire Demon":
					_desc = "OW! This card is burning hot!";
					addAnimation(_type, [8]);
					_dread = 5;
					_health = 10;
					_strength = 8;
					_speed = 3;
					_armour = 3;
					break;
				default:
					throw new Error("no matching monster defined for " + _type);
			}
			play(_type);
		}
		
		public function CheckChat():void {
			if (_playState.turn_number == 1 && _usedChats.indexOf("intruder") == -1) {
				//DoBossChat("intruder");
				_playState.BossChatOver();
			} else if (_playState.monsters_killed == 1 && _usedChats.indexOf("first_kill") == -1) {
				DoBossChat("first_kill");
			} else if (_playState.monsters_killed == 5 && _usedChats.indexOf("fifth_kill") == -1) {
				DoBossChat("fifth_kill");
			} else {
				_playState.BossChatOver();
			}
		}
		
		public function DoBossChat(chat_type:String):void {
			var appearDelay:Number = 0;
			TweenLite.to(this, TIME_TO_MOVE, { x:ONSCREEN_POINT.x, y:ONSCREEN_POINT.y, delay:appearDelay, ease:Back.easeInOut.config(0.8) } );
			appearDelay += TIME_TO_MOVE;
			
			var oneChatCycle:Number = FloatingText.FADE_IN_TIME * 2 + FloatingText.DISPLAY_TIME + FloatingText.FADE_OUT_TIME;
			
			if (chat_type == "intruder") {
				
				BossAddChat("WHO DARES INVADE THE HOT, HOT LAIR OF EMBRO, LORD OF FLAME?!", appearDelay);
				appearDelay += oneChatCycle;
				
				BossAddChat("Right in the middle of bath time, too. Look at this puddle.", appearDelay, false);
				appearDelay += oneChatCycle;
				
				BossAddChat("MINIONS! DESTROY THEM! BRING ME THEIR BONES!", appearDelay);
				appearDelay += oneChatCycle;
			} else if (chat_type == "first_kill") {
				
				BossAddChat("HAR HAR! YOU THINK I'LL MISS THAT " + _playState.battling_monster._type.toUpperCase() + "?", appearDelay);
				appearDelay += oneChatCycle;
				
				BossAddChat("NO! HE WAS MY LEAST FAVORITE MINION!", appearDelay);
				appearDelay += oneChatCycle;
			} else if (chat_type == "fifth_kill") {
				
				BossAddChat("*sigh* As usual my minions are bumbling fools..", appearDelay, false);
				appearDelay += oneChatCycle;
				
				BossAddChat("If only those sharks with spears attached to their heads had arrived.", appearDelay, false);
				appearDelay += oneChatCycle;
				
				BossAddChat("Oh well. SEND MORE RUBBER DUCKIES!", appearDelay);
				appearDelay += oneChatCycle;
			}
			
			TweenLite.to(this, TIME_TO_MOVE, { x:OFFSCREEN_POINT.x, y:OFFSCREEN_POINT.y, delay:appearDelay, ease:Back.easeInOut.config(0.8) } );
			appearDelay += TIME_TO_MOVE;
			TweenLite.delayedCall(appearDelay, _playState.BossChatOver);
			
			_usedChats.push(chat_type);
		}
		
		public function BossAddChat(chat:String, delay:Number = 0, angry:Boolean = true):void {
			TweenMax.to(this, 0.15, { x:ONSCREEN_POINT.x + 1, y:ONSCREEN_POINT.y - 2, bothScale:bothScale + 0.1, delay:delay, repeat:5, yoyo:true } );
			var boss_shout:FloatingText = new FloatingText(ONSCREEN_POINT.x + 60, ONSCREEN_POINT.y - 86, chat, delay);
			boss_shout.scrollFactor = new FlxPoint(0, 0);
			_playState.floatingTexts.add(boss_shout);
			
			if (angry) {
				TweenLite.delayedCall(delay, _playState.sndDemontalk1.play);
			} else {
				TweenLite.delayedCall(delay, _playState.sndDemontalk2.play);
			}
		}
		
		public function GetStats():String {
			var stats:String = "";
			stats += "Health: " + _health + "\n";
			stats += "Strength: " + _strength + "\n";
			stats += "Speed: " + _speed + "\n";
			stats += "Armour: " + _armour + "\n";
			return stats;
		}

	}
}