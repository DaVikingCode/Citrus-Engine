package ash.io.enginecodecs
{
	import ash.core.Engine;

	public class JsonEngineCodec extends ObjectEngineCodec implements IEngineCodec
	{
		override public function encodeEngine( engine : Engine ) : Object
		{
			var object : Object = super.encodeEngine( engine );
			var encoded : String = JSON.stringify( object );
			return encoded;
		}

		override public function decodeEngine( encodedData : Object, engine : Engine ) : void
		{
			var object : Object = JSON.parse( encodedData as String );
			super.decodeEngine( object, engine );
		}
		
		override public function decodeOverEngine( encodedData : Object, engine : Engine ) : void
		{
			var object : Object = JSON.parse( encodedData as String );
			super.decodeOverEngine( object, engine );
		}
	}
}
