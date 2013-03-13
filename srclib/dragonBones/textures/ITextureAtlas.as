package dragonBones.textures
{
	import flash.geom.Rectangle;

	public interface ITextureAtlas
	{
		function get name():String;
		function dispose():void;
		function getRegion(name:String):Rectangle
	}
}