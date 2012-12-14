/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License.
 * Questions? Mail me at lithander at gmx.de!
 ******************************************************************************/
package citrus.utils.objectmakers.tmx {
	
	public class TmxMap {

		public var version:String;
		public var orientation:String;
		public var width:uint;
		public var height:uint;
		public var tileWidth:uint;
		public var tileHeight:uint;

		public var properties:TmxPropertySet = null;
		public var layers:Object = {};
		public var tileSets:Object = {};
		public var objectGroups:Object = {};

		public function TmxMap(source:XML) {
			// map header
			version = source.@version ? source.@version : "unknown";
			orientation = source.@orientation ? source.@orientation : "orthogonal";
			width = source.@width;
			height = source.@height;
			tileWidth = source.@tilewidth;
			tileHeight = source.@tileheight;
			// read properties
			for each (node in source.properties)
				properties = properties ? properties.extend(node) : new TmxPropertySet(node);
			// load tilesets
			var node:XML = null;
			for each (node in source.tileset)
				tileSets[node.@name] = new TmxTileSet(node, this);
			// load layer
			for each (node in source.layer)
				layers[node.@name] = new TmxLayer(node, this);
			// load object group
			for each (node in source.objectgroup)
				objectGroups[node.@name] = new TmxObjectGroup(node, this);
		}

		public function getTileSet(name:String):TmxTileSet {
			return tileSets[name] as TmxTileSet;
		}

		public function getLayer(name:String):TmxLayer {
			return layers[name] as TmxLayer;
		}

		public function getObjectGroup(name:String):TmxObjectGroup {
			return objectGroups[name] as TmxObjectGroup;
		}

		// works only after TmxTileSet has been initialized with an image...
		public function getGidOwner(gid:int):TmxTileSet {
			for each (var tileSet:TmxTileSet in tileSets) {
				if (tileSet.hasGid(gid))
					return tileSet;
			}
			return null;
		}
	}
}