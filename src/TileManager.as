package  
{
	import org.flixel.*;
	
	public class TileManager 
	{
		public static const NORTH:int = 1;
		public static const EAST:int  = 2;
		public static const SOUTH:int = 4;
		public static const WEST:int  = 8;
		
		public var all_directions:Array = new Array(NORTH, EAST, SOUTH, WEST);
		public var all_tiles:Array = new Array();
		
		private var _playState:PlayState;
		
		public function TileManager(playState:PlayState) {
			_playState = playState;
			
			//create one of every tile
			for (var i:int = 0; i < Tile.ALL_TILES.length; i++) {
				all_tiles.push(new Tile(_playState, Tile.ALL_TILES[i]));
			}
		}
		
		public function GetRandomTile(entrance_directions:Array = null):Tile {
			if (entrance_directions == null || entrance_directions.length == 0) {
				entrance_directions = all_directions;
			}
			
			var searching:Boolean = true;
			var this_tile:Tile;
			while (searching) {
				this_tile = all_tiles[Math.floor(Math.random() * (all_tiles.length))];
				//trace("trying " + this_tile.type);
				if (this_tile.type.indexOf("corr") == 0 || this_tile.type.indexOf("room") == 0) { 
					if (this_tile.type != "room_treasure") {
						for each (var d:int in entrance_directions) {
							if (this_tile.checkExit(d)) {
								searching = false;
							}
						}
					}
				}
				
			}
			
			//trace("found " + this_tile.type);
			return new Tile(_playState, this_tile.type);
		}
		
		public static function findPath(firstNode:Tile, destinationNode:Tile):Array {
			var openNodes:Array = [];
			var closedNodes:Array = [];
			var currentNode:Tile = firstNode;
			var testNode:Tile;
			var connectedNodes:Array;
			var travelCost:Number = 1.0;
			var g:Number;
			var h:Number;
			var f:Number;
			currentNode.g = 0;
			currentNode.h = heuristic(currentNode, destinationNode, travelCost);
			trace("currentNode.h: " + currentNode.h);
			currentNode.f = currentNode.g + currentNode.h;
			var l:int = openNodes.length;
			var i:int;
			
			/*
			while (currentNode != destinationNode) {
				connectedNodes = connectedNodeFunction( currentNode );
				l = connectedNodes.length;
				for (i = 0; i < l; ++i) {
					testNode = connectedNodes[i];
					if (testNode == currentNode || testNode.travesable == false) continue;
					g = currentNode.g  + travelCost;
					h = heuristic( testNode, destinationNode, travelCost);
					f = g + h;
					if ( Pathfinder.isOpen(testNode, openNodes) || Pathfinder.isClosed( testNode, closedNodes) )	{
						if(testNode.f > f)
						{

							testNode.f = f;
							testNode.g = g;
							testNode.h = h;
							testNode.parentNode = currentNode;
						}
					}else {
						testNode.f = f;
						testNode.g = g;
						testNode.h = h;
						testNode.parentNode = currentNode;
						openNodes.push(testNode);
					}
				}
				closedNodes.push( currentNode );
				if (openNodes.length == 0) {
					return null;
				}
				openNodes.sortOn('f', Array.NUMERIC);
				currentNode = openNodes.shift() as INode;
			}
			*/
			
			return connectedNodes;
		}
		
		public static function heuristic(currentNode:Tile, destinationNode:Tile, travelCost:Number):Number {
			return currentNode.distanceSquaredToTile(destinationNode) / (Tile.TILESIZE * Tile.TILESIZE);
		}
		
		
		
		
	}

}