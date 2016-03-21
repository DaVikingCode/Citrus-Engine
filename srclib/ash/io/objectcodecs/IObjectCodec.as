package ash.io.objectcodecs
{
	public interface IObjectCodec
	{
		function encode( object : Object, codecManager : CodecManager ) : Object;
		function decode( object : Object, codecManager : CodecManager ) : Object;
		function decodeIntoObject( target : Object, object : Object, codecManager : CodecManager ) : void;
		function decodeIntoProperty( parent : Object, property : String, object : Object, codecManager : CodecManager ) : void;
	}
}
