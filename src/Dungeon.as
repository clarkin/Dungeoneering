package  
{
	import org.flixel.*;
	
	public class Dungeon 
	{
		public var all_monsters:Array = new Array();
		public var all_treasures:Array = new Array();
		public var _dread_level:Number = 1;
		public var _hope_level:Number = 1;
		
		private var _playState:PlayState;
		
		public function Dungeon(playState:PlayState) {
			_playState = playState;
			
			//create one of every monster & treasure
			for (var i:int = 0; i < Monster.ALL_MONSTERS.length; i++) {
				all_monsters.push(new Monster(_playState, Monster.ALL_MONSTERS[i]));
			}
			for (var j:int = 0; j < Treasure.ALL_TREASURES.length; j++) {
				all_treasures.push(new Treasure(_playState, Treasure.ALL_TREASURES[j]));
			}
		}
		
		public function GetRandomMonster():Monster {			
			var this_dread:Number = RollForDread();
			
			var searching:Boolean = true;
			var this_monster:Monster;
			while (searching) {
				this_monster = all_monsters[Math.floor(Math.random() * (all_monsters.length))];
				if (this_monster._dread == this_dread) {
					searching = false;
				}
			}
			
			//trace("getRandomMonster() found " + this_monster._type + " with dread " + this_dread);
			return new Monster(_playState, this_monster._type);
		}
		
		public function GetRandomTreasure():Treasure {
			var this_treasure:Treasure = all_treasures[Math.floor(Math.random() * (all_treasures.length))];
			
			//trace("GetRandomTreasure() found " + this_treasure._type);
			return new Treasure(_playState, this_treasure._type);
		}
		
		public function IncreaseDread():void {
			var dread:Number = Math.floor((_playState.turn_number + 2) / 5);
			//trace("dread level changing from " + _dread_level + " to " + (_dread_level + dread));
			_dread_level += dread;
			if (_dread_level > 5) {
				_dread_level = 5;
			}
		}
		
		public function ReduceDread():void {
			_dread_level--;
			if (_dread_level < 0) {
				_dread_level = 0;
			}
		}
		
		public function RollForDread():Number {
			var rolls:Array = [];
			rolls.push(randomNumber(0, 5));
			//trace("rolling for i:" + 0 + ", got: " + rolls[0]);
			for (var i:int = 1; i <= 1; i++) {
				rolls.push(randomNumber(_dread_level - 1, _dread_level + 1));
				//trace("rolling for i:" + i + ", got: " + rolls[i]);
			}
			
			var chosen_roll:Number = rolls[Math.floor(Math.random() * rolls.length)]
			if (chosen_roll < 0) {
				chosen_roll = 0;
			} else if (chosen_roll > 5) {
				chosen_roll = 5;
			}
			return chosen_roll;
		}
		
		public function randomNumber(min:Number, max:Number):Number {
			return Math.floor(Math.random() * (1 + max - min) + min);
		}

	}

}