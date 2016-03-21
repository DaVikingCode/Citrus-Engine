package ash.io.objectcodecs
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ClassObjectCodec implements IObjectCodec
	{
		public function encode( object : Object, codecManager : CodecManager ) : Object
		{
			return { type: "Class", value : getQualifiedClassName( object ) };
		}

		public function decode( object : Object, codecManager : CodecManager ) : Object
		{
			return getDefinitionByName( object.value );
		}

		public function decodeIntoObject( target : Object, object : Object, codecManager : CodecManager ) : void
		{
			target = getDefinitionByName( object.value ); // this won't work because native objects (i.e. target) are not passed by reference
		}

		public function decodeIntoProperty( parent : Object, property : String, object : Object, codecManager : CodecManager ) : void
		{
			decodeIntoObject( parent[property], object, codecManager );
		}
	}
}
