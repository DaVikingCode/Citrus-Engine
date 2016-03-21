package ash.io.enginecodecs
{
	import ash.core.Engine;
	import ash.io.objectcodecs.CodecManager;
	import ash.io.objectcodecs.IObjectCodec;
	import ash.signals.Signal1;

	public class ObjectEngineCodec implements IEngineCodec
	{
		private var encoder : EngineEncoder;
		private var decoder : EngineDecoder;
		private var codecManager : CodecManager;
		private var encodeCompleteSignal : Signal1 = new Signal1( Object );
		private var decodeCompleteSignal : Signal1 = new Signal1( Engine );

		public function ObjectEngineCodec()
		{
			codecManager = new CodecManager();
			encoder = new EngineEncoder( codecManager );
			decoder = new EngineDecoder( codecManager );
		}

		public function addCustomCodec( codec : IObjectCodec, ...types ) : void
		{
			for each ( var type : Class in types )
			{
				codecManager.addCustomCodec( codec, type );
			}
		}

		public function encodeEngine( engine : Engine ) : Object
		{
			encoder.reset();
			var encoded : Object = encoder.encodeEngine( engine );
			encodeCompleteSignal.dispatch( encoded );
			return encoded;
		}

		public function decodeEngine( encodedData : Object, engine : Engine ) : void
		{
			decoder.reset();
			decoder.decodeEngine( encodedData, engine );
			decodeCompleteSignal.dispatch( engine );
		}

		public function decodeOverEngine( encodedData : Object, engine : Engine ) : void
		{
			decoder.reset();
			decoder.decodeOverEngine( encodedData, engine );
			decodeCompleteSignal.dispatch( engine );
		}
		
		public function get encodeComplete() : Signal1
		{
			return encodeCompleteSignal;
		}
		
		public function get decodeComplete() : Signal1
		{
			return decodeCompleteSignal;
		}
	}
}
