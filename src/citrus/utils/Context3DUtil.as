package citrus.utils
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	/**
	 * https://github.com/PrimaryFeather/Starling-Framework/issues/337#issuecomment-20620689
	 */
	public class Context3DUtil
	{
		private static var contexts:Vector.<String>;
		private static var supportsCallback:Function;
		private static var checkingProfile:String;
		
		public static function supportsProfile(nativeStage:Stage, profile:String, callback:Function):void
		{
			supportsCallback = callback;
			checkingProfile = profile;
			
			if (nativeStage.stage3Ds.length > 0)
			{
				var stage3D:Stage3D = nativeStage.stage3Ds[0];
				stage3D.addEventListener(Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener, false, 10, true);
				stage3D.addEventListener(ErrorEvent.ERROR, supportsProfileContextErroredListener, false, 10, true);
				try
				{  
					stage3D.requestContext3D("auto", profile);
				}
				catch (e:Error)
				{
					stage3D.removeEventListener(flash.events.Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener);
					stage3D.removeEventListener(ErrorEvent.ERROR, supportsProfileContextErroredListener);
					
					if (supportsCallback !=null)
						supportsCallback(checkingProfile, false);
				}
			}
			else
			{
				// no Stage3D instances
				if (supportsCallback !=null)
					supportsCallback(checkingProfile, false);
			}
		}
		
		private static function supportsProfileContextErroredListener(event:ErrorEvent):void
		{
			var targetStage3D:Stage3D = event.target as Stage3D;
			if (targetStage3D)
			{
				targetStage3D.removeEventListener(Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener);
				targetStage3D.removeEventListener(ErrorEvent.ERROR, supportsProfileContextErroredListener);
			}
			if (supportsCallback !=null)
				supportsCallback(checkingProfile, false);
		}
		
		private static function supportsProfileContextCreatedListener(event:Event):void
		{
			var targetStage3D:Stage3D = event.target as Stage3D;
			
			if (targetStage3D)
			{
				targetStage3D.removeEventListener(Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener);
				targetStage3D.removeEventListener(ErrorEvent.ERROR, supportsProfileContextErroredListener);
				
				if (targetStage3D.context3D)
				{
					// the context is recreated as long as there are listeners on it, but there shouldn't be here.
					// Beginning with AIR 3.6, we can guarantee that with an additional parameter of false.
					var disposeContext3D:Function = targetStage3D.context3D.dispose;
					if (disposeContext3D.length == 1)
						disposeContext3D(false);
					else
						disposeContext3D();
					
					if (supportsCallback !=null)
						supportsCallback(checkingProfile, true);
				}
			}
		}
	
	}

}