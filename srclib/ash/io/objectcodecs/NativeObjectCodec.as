package ash.io.objectcodecs
{
	import flash.utils.getQualifiedClassName;
	import ash.io.objectcodecs.IObjectCodec;
	import ash.io.objectcodecs.CodecManager;

	public class NativeObjectCodec implements IObjectCodec
	{
		public function encode( object : Object, codecManager : CodecManager ) : Object
		{
			return { type: getQualifiedClassName( object ), value : object };
		}

		public function decode( object : Object, codecManager : CodecManager ) : Object
		{
			return object.value;
		}

		public function decodeIntoObject( target : Object, object : Object, codecManager : CodecManager ) : void
		{
			throw( new Error( "Can't decode into a native object because the object is passed by value, not by reference, so we're decoding into a local copy not the original." ) );
		}

		public function decodeIntoProperty( parent : Object, property : String, object : Object, codecManager : CodecManager ) : void
		{
			parent[property] = object.value;
		}
	}
}
