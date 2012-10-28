/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License.
 * Questions? Mail me at lithander at gmx.de!
 ******************************************************************************/
package com.citrusengine.utils.tmx 
{
	public class TmxObject
	{
		public var group:TmxObjectGroup;
		public var name:String;
		public var type:String;
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;
		public var gid:int;
		public var custom:TmxPropertySet;
		public var shared:TmxPropertySet;
		
		public function TmxObject(source:XML, parent:TmxObjectGroup)
		{
			if(!source)
				return;
			group = parent;
			name = source.@name;
			type = source.@type;
			x = source.@x; 
			y = source.@y; 
			width = source.@width; 
			height = source.@height;
			//resolve inheritence
			shared = null;
			gid = -1;
			if(source.@gid.length != 0) //object with tile association?
			{
				gid = source.@gid;
				for each(var tileSet:TmxTileSet in group.map.tileSets)
				{
					shared = tileSet.getPropertiesByGid(gid);
					if(shared)
						break;
				}
			}
			
			//load properties
			var node:XML;
			for each(node in source.properties)
				custom = custom ? custom.extend(node) : new TmxPropertySet(node);
		}
	}
}