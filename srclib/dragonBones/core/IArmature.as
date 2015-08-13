package dragonBones.core
{
	import dragonBones.animation.IAnimatable;

	public interface IArmature extends IAnimatable
	{
		function getAnimation():Object;
		function resetAnimation():void
		
	}
}