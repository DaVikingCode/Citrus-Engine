/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License.
 * Questions? Mail me at lithander@gmx.de!
 ******************************************************************************/
package com.citrusengine.utils.tmx 
{
	public dynamic class TmxPropertySet
	{
		public function TmxPropertySet(source:XML)
		{
			extend(source);
		}
		
		public function extend(source:XML):TmxPropertySet
		{
			for each (var prop:XML in source.property)
			{
				var key:String = prop.@name;
				var value:String = prop.@value;
				this[key] = value;
			}
			return this;
		}
	}
}