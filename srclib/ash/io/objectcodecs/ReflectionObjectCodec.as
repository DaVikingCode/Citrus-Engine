package ash.io.objectcodecs
{
	import flash.utils.getDefinitionByName;

	public class ReflectionObjectCodec implements IObjectCodec
	{
		public function encode( object : Object, codecManager : CodecManager ) : Object
		{
			var reflection : ObjectReflection = ObjectReflectionFactory.reflection( object );
			var properties : Object = {};
			for ( var name : String in reflection.propertyTypes )
			{
				properties[ name ] = codecManager.encodeObject( object[name] );
			}
			return { type:reflection.type, properties:properties };
		}

		public function decode( object : Object, codecManager : CodecManager ) : Object
		{
			var type : Class = getDefinitionByName( object.type ) as Class;
			var decoded : Object = new type();
			for ( var name : String in object.properties )
			{
				if( decoded.hasOwnProperty( name ) )
				{
					decoded[name] = codecManager.decodeObject( object.properties[name] );
				}
			}
			return decoded;
		}

		public function decodeIntoObject( target : Object, object : Object, codecManager : CodecManager ) : void
		{
			for ( var name : String in object.properties )
			{
				if( target.hasOwnProperty( name ) )
				{
					if( target[name] )
					{
						codecManager.decodeIntoProperty( target, name, object.properties[name] );
					}
					else
					{
						target[name] = codecManager.decodeObject( object.properties[name] );
					}
				}
			}
		}

		public function decodeIntoProperty( parent : Object, property : String, object : Object, codecManager : CodecManager ) : void
		{
			decodeIntoObject( parent[property], object, codecManager );
		}
	}
}
