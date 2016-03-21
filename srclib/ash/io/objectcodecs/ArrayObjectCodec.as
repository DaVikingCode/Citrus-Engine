package ash.io.objectcodecs
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ArrayObjectCodec implements IObjectCodec
	{
		public function encode( object : Object, codecManager : CodecManager ) : Object
		{
			var type : String = getQualifiedClassName( object );
			var values : Object = [];
			var codec : IObjectCodec;
			for each( var value : Object in object )
			{
				values[ values.length ] = codecManager.encodeObject( value );
			}
			return { type:type, values:values };

			return null;
		}

		public function decode( object : Object, codecManager : CodecManager ) : Object
		{
			var type : Class = getDefinitionByName( object.type ) as Class;
			var decoded : Object = new type();
			for each( var obj : Object in object.values )
			{
				decoded[ decoded.length ] = codecManager.decodeObject( obj );
			}
			return decoded;
		}

		public function decodeIntoObject( target : Object, object : Object, codecManager : CodecManager ) : void
		{
			for each( var obj : Object in object.values )
			{
				target[ target.length ] = codecManager.decodeObject( obj );
			}
		}

		public function decodeIntoProperty( parent : Object, property : String, object : Object, codecManager : CodecManager ) : void
		{
			decodeIntoObject( parent[property], object, codecManager );
		}
	}
}
