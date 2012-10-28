/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License.
 * Questions? Mail me at lithander at gmx.de!
 ******************************************************************************/
package com.citrusengine.utils.tmx 
{

	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class TmxLayer
	{
		public var map:TmxMap;
		public var name:String;
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;
		public var opacity:Number;
		public var visible:Boolean;
		public var tileGIDs:Array;
		public var properties:TmxPropertySet = null;
		
		public function TmxLayer(source:XML, parent:TmxMap)
		{
			map = parent;
			name = source.@name;
			x = source.@x; 
			y = source.@y; 
			width = source.@width; 
			height = source.@height; 
			visible = !source.@visible || (source.@visible != 0);
			opacity = source.@opacity;
			
			//load properties
			var node:XML;
			for each(node in source.properties)
				properties = properties ? properties.extend(node) : new TmxPropertySet(node);
			
			//load tile GIDs
			tileGIDs = [];
			var data:XML = source.data[0];
			if(data)
			{
				var chunk:String = "";
				if(data.@encoding.length() == 0)
				{
					//create a 2dimensional array
					var lineWidth:int = width;
					var rowIdx:int = -1;
					for each(node in data.tile)
					{
						//new line?
						if(++lineWidth >= width)
						{
							tileGIDs[++rowIdx] = [];
							lineWidth = 0;
						}
						var gid:int = node.@gid;
						tileGIDs[rowIdx].push(gid);
					}
				}
				else if(data.@encoding == "csv")
				{
					chunk = data;
					tileGIDs = csvToArray(chunk, width);
				}
				else if(data.@encoding == "base64")
				{
					chunk = data;
					var compressed:Boolean = false;
					if(data.@compression == "zlib")
						compressed = true;
					else if(data.@compression.length() != 0)
						throw Error("TmxLayer - data compression type not supported!");
					
					for(var i:int = 0; i < 100; i++)
						tileGIDs = base64ToArray(chunk, width, compressed);	
				}
			}
		}
		
		public function toCsv(tileSet:TmxTileSet = null):String
		{
			var max:int = 0xFFFFFF;
			var offset:int = 0;
			if(tileSet)
			{
				offset = tileSet.firstGID;
				max = tileSet.numTiles - 1;
			}
			var result:String = "";
			for each(var row:Array in tileGIDs)
			{
				var chunk:String = "";
				var id:int = 0;
				for each(id in row)
				{
					id -= offset;
					if(id < 0 || id > max)
						id = 0;
					result += chunk;
					chunk = id+",";
				}
				result += id+"\n";	
			}
			return result;
		}
		
		public static function csvToArray(input:String, lineWidth:int):Array
		{
			var result:Array = [];
			var rows:Array = input.split("\n");
			for each(var row:String in rows)
			{
				var resultRow:Array = [];
				var entries:Array = row.split(",", lineWidth);
				for each(var entry:String in entries)
					resultRow.push(uint(entry)); //convert to uint
				result.push(resultRow);
			}
			return result;
		}
		
		public static function base64ToArray(chunk:String, lineWidth:int, compressed:Boolean):Array
		{
			var result:Array = [];
			var data:ByteArray = base64ToByteArray(chunk);
			if(compressed)
				data.uncompress();
			data.endian = Endian.LITTLE_ENDIAN;
			while(data.position < data.length)
			{
				var resultRow:Array = [];
				for(var i:int = 0; i < lineWidth; i++)
					resultRow.push(data.readInt());
				result.push(resultRow);
			}
			return result;
		}
		
		private static const BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
		
		public static function base64ToByteArray(data:String):ByteArray 
		{
			var output:ByteArray = new ByteArray();
			//initialize lookup table
			var lookup:Array = [];
			for(var c:int = 0; c < BASE64_CHARS.length; c++)
				lookup[BASE64_CHARS.charCodeAt(c)] = c;
			
			for (var i:uint = 0; i < data.length - 3; i += 4) 
			{
				//read 4 bytes and look them up in the table
				var a0:int = lookup[data.charCodeAt(i)];
				var a1:int = lookup[data.charCodeAt(i + 1)];
				var a2:int = lookup[data.charCodeAt(i + 2)];
				var a3:int = lookup[data.charCodeAt(i + 3)];
			
				// convert to and write 3 bytes
				if(a1 < 64)
					output.writeByte((a0 << 2) + ((a1 & 0x30) >> 4));
				if(a2 < 64)
					output.writeByte(((a1 & 0x0f) << 4) + ((a2 & 0x3c) >> 2));
				if(a3 < 64)
					output.writeByte(((a2 & 0x03) << 6) + a3);
			}
			
			// Rewind & return decoded data
			output.position = 0;
			return output;
		}
	}
}