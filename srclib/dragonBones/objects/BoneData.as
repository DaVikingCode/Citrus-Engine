package dragonBones.objects
{
	
	/** @private */
	final public class BoneData extends Node
	{
		internal var _displayList:Vector.<DisplayData>;
		
		internal var _name:String;
		public function get name():String
		{
			return _name;
		}
		
		internal var _parent:String;
		public function get parent():String
		{
			return _parent;
		}
		
		public function get displayLength():uint
		{
			return _displayList.length;
		}
		
		public function BoneData()
		{
			super();
			_displayList = new Vector.<DisplayData>;
		}
		
		public function dispose():void
		{
			_displayList = null;
		}
		
		override public function copy(node:Node):void
		{
			super.copy(node);
			var boneData:BoneData = node as BoneData;
			if(boneData)
			{
				_name = boneData.name;
				_parent = boneData.parent;
			}
		}
		
		public function getDisplayDataAt(index:int):DisplayData
		{
			return _displayList.length > index?_displayList[index]:null;
		}
	}
}