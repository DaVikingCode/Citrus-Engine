/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License.
 * Questions? Mail me at lithander at gmx.de!
 ******************************************************************************/
package citrus.utils.objectmakers.tmx {
	
	public class TmxObject {

		public var group:TmxObjectGroup;
		public var name:String;
		public var type:String;
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;
		public var rotation:int;
		public var gid:int;
		public var custom:TmxPropertySet;
		public var shared:TmxPropertySet;
		public var points:Array;
  		public var shapeType:String;

		public function TmxObject(source:XML, parent:TmxObjectGroup) {
			if (!source)
				return;
			group = parent;
			name = source.@name;
			type = source.@type;
			x = source.@x;
			y = source.@y;
			width = source.@width;
			height = source.@height;
			rotation = source.@rotation;
			// resolve inheritence
			shared = null;
			gid = -1;
			if (source.@gid.length != 0) // object with tile association?
			{
				gid = source.@gid;
				for each (var tileSet:TmxTileSet in group.map.tileSets) {
					shared = tileSet.getPropertiesByGid(gid);
					if (shared)
						break;
				}
			}

			// load properties
			var node:XML;
			for each (node in source.properties)
				custom = custom ? custom.extend(node) : new TmxPropertySet(node);
				
			//points/polygon/polyline
			var nodes:XMLList = source.children();
			
			for each(node in nodes) {
				
				shapeType = node.@name;
				points = [];
				var pointsArray:Array = String(node.@points).split(" ");
				var len:uint = pointsArray.length;
				
				for (var i:uint = 0; i < len; ++i){
					var pstr:Array = pointsArray[i].split(",");
					var point:Object = {x:int(pstr[0]), y:int(pstr[1])};
					points.push(point);
				}
				break;
			}
		}
	}
}