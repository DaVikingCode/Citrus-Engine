package ash.io.enginecodecs
{
	import ash.core.Engine;
	import ash.io.objectcodecs.IObjectCodec;
	import ash.signals.Signal1;

	public interface IEngineCodec
	{
		function addCustomCodec( codec : IObjectCodec, ...types ) : void;

		function encodeEngine( engine : Engine ) : Object;

		function decodeEngine( encodedData : Object, engine : Engine ) : void;
		
		function decodeOverEngine( encodedData : Object, engine : Engine ) : void;
		
		function get encodeComplete() : Signal1;
		
		function get decodeComplete() : Signal1;
	}
}
