/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License.
 * Questions? Mail me at lithander at gmx.de!
 ******************************************************************************/
package com.citrusengine.utils.tmx 
{

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	public class TmxTileSet
	{
		private var _tileProps:Array = [];
		private var _image:BitmapData = null;
		
		public var firstGID:int = 0;
		public var map:TmxMap;
		public var name:String;
		public var tileWidth:int;
		public var tileHeight:int;
		public var spacing:int;
		public var margin:int;
		public var imageSource:String;
		
		//available only after immage has been assigned:
		public var numTiles:int = 0xFFFFFF;
		public var numRows:int = 1;
		public var numCols:int = 1;
		
		public function TmxTileSet(source:XML, parent:TmxMap)
		{
			firstGID = source.@firstgid;

			imageSource = source.image.@source;
			
			map = parent;
			name = source.@name;
			tileWidth = source.@tilewidth;
			tileHeight = source.@tileheight;
			spacing = source.@spacing;
			margin = source.@margin;
				
			//read properties
			for each(var node:XML in source.tile)
				if(node.properties[0])
					_tileProps[int(node.@id)] = new TmxPropertySet(node.properties[0]);
		}
		
		public function get image():BitmapData
		{
			return _image;
		}
		
		public function set image(v:BitmapData):void
		{
			_image = v;
			//TODO: consider spacing & margin
			numCols = Math.floor(v.width / tileWidth);
			numRows = Math.floor(v.height / tileHeight);
			numTiles = numRows * numCols;
		}
		
		public function hasGid(gid:int):Boolean
		{
			return (gid >= firstGID) && (gid < firstGID + numTiles);
		}
		
		public function fromGid(gid:int):int
		{
			return gid - firstGID;
		}
		
		public function toGid(id:int):int
		{
			return firstGID + id;
		}

		public function getPropertiesByGid(gid:int):TmxPropertySet
		{
			return _tileProps[gid - firstGID];	
		}
		
		public function getProperties(id:int):TmxPropertySet
		{
			return _tileProps[id];	
		}
		
		public function getRect(id:int):Rectangle
		{
			//TODO: consider spacing & margin
			return new Rectangle((id % numCols) * tileWidth, (id / numCols) * tileHeight);
		}
	}
}