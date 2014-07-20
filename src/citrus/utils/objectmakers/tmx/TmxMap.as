/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License.
 * Questions? Mail me at lithander at gmx.de!
 ******************************************************************************/
/**
 * Modified in 2014 by fdufafa:
	 * Layers from tmx, including object layers, are available as ordered in TiledMapEditor.
 */
package citrus.utils.objectmakers.tmx {
	
	public class TmxMap {
		
		public var version:String;
		public var orientation:String;
		public var width:uint;
		public var height:uint;
		public var tileWidth:uint;
		public var tileHeight:uint;
		
		public var properties:TmxPropertySet = null;
		public var tileSets:Object = {};
		
		public var layers_ordered:Array = [];
		
		static private const TILE_LAYER_NAME:String = 'layer';
		static private const OBJECT_LAYER_NAME:String = 'objectgroup';
		
		public function TmxMap(source:XML) {
			// map header
			version = source.@version ? source.@version : "unknown";
			orientation = source.@orientation ? source.@orientation : "orthogonal";
			width = source.@width;
			height = source.@height;
			tileWidth = source.@tilewidth;
			tileHeight = source.@tileheight;
			
			// read properties
			for each (var node:XML in source.properties) {
				properties = properties ? properties.extend(node) : new TmxPropertySet(node);
			}
			
			// load tilesets
			for each (node in source.tileset) {
				tileSets[node.@name] = new TmxTileSet(node, this);
			}
			
			// load layers of the map in order
			for each (node in source.children()) {
				if (node.name() == TILE_LAYER_NAME) {
					layers_ordered.push(new TmxLayer(node, this));
				}else if (node.name() == OBJECT_LAYER_NAME) {
					layers_ordered.push(new TmxObjectGroup(node, this));
				}
			}
		}
		
		public function getTileSet(name:String):TmxTileSet {
			return tileSets[name] as TmxTileSet;
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