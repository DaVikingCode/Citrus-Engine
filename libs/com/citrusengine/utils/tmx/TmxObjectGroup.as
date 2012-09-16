/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License.
 * Questions? Mail me at lithander@gmx.de!
 ******************************************************************************/
package com.citrusengine.utils.tmx 
{
	public class TmxObjectGroup
	{
		public var map:TmxMap;
		public var name:String;
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;
		public var opacity:Number;
		public var visible:Boolean;
		public var properties:TmxPropertySet = null;
		public var objects:Array = [];
		
		public function TmxObjectGroup(source:XML, parent:TmxMap)
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
				
			//load objects
			for each(node in source.object)
				objects.push(new TmxObject(node, this));		
		}
	}
}