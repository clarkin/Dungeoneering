package  
{
	import org.flixel.*;
	
	public class Dungeon 
	{
		public var all_monsters:Array = new Array();
		public var _dread_level:Number = 0;
		
		private var _playState:PlayState;
		
		public function Dungeon(playState:PlayState) {
			_playState = playState;
			
			//create one of every monster
			for (var i:int = 0; i < Monster.ALL_MONSTERS.length; i++) {
				all_monsters.push(new Monster(_playState, Monster.ALL_MONSTERS[i]));
			}
		}
		
		public function GetRandomMonster():Monster {			
			var searching:Boolean = true;
			var this_monster:Monster;
			while (searching) {
				this_monster = all_monsters[Math.floor(Math.random() * (all_monsters.length))];
				//trace("trying " + this_tile.type);
				searching = false;
				
			}
			
			trace("getRandomMonster() found " + this_monster._type);
			return new Monster(_playState, this_monster._type);
		}
		
		
		
	}

}