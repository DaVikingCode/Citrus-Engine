package dragonBones.objects {

	import flash.display.Loader;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	public class TextureAtlasByteArrayLoader extends Loader
	{
		private static const loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
		
		public function TextureAtlasByteArrayLoader()
		{
			super();
			loaderContext.allowCodeImport = true;
		}
		
		override public function loadBytes(bytes:ByteArray, context:LoaderContext=null):void
		{
			context = context == null ? loaderContext : context;
			super.loadBytes(bytes, context);
		}
	}
}