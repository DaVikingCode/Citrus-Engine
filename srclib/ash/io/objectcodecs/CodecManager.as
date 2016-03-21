package ash.io.objectcodecs
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class CodecManager
	{
		private var codecs : Dictionary;
		private var reflectionCodec : ReflectionObjectCodec;
		private var arrayCodec : ArrayObjectCodec;

		public function CodecManager()
		{
			codecs = new Dictionary();
			var nativeCodec : NativeObjectCodec = new NativeObjectCodec();
			addCustomCodec( nativeCodec, int );
			addCustomCodec( nativeCodec, uint );
			addCustomCodec( nativeCodec, Number );
			addCustomCodec( nativeCodec, String );
			addCustomCodec( nativeCodec, Boolean );
			reflectionCodec = new ReflectionObjectCodec();
			arrayCodec = new ArrayObjectCodec();
			addCustomCodec( arrayCodec, Array );
			addCustomCodec( new ClassObjectCodec(), Class );
		}

		public function getCodecForObject( object : Object ) : IObjectCodec
		{
			var type : Class = object is Class ? Class : object.constructor as Class;
			if ( codecs[type] )
			{
				return codecs[type];
			}
			if( getQualifiedClassName( object ).substr( 0, 20 ) == "__AS3__.vec::Vector." )
			{
				return arrayCodec;
			}
			return null;
		}

		public function getCodecForType( type : Class ) : IObjectCodec
		{
			if ( codecs[type] )
			{
				return codecs[type];
			}
			if( getQualifiedClassName( type ).substr( 0, 20 ) == "__AS3__.vec::Vector." )
			{
				return arrayCodec;
			}
			return null;
		}

		public function getCodecForComponent( component : Object ) : IObjectCodec
		{
			var codec : IObjectCodec = getCodecForObject( component );
			if ( codec == null )
			{
				return reflectionCodec;
			}
			return codec;
		}

		public function getCodecForComponentType( type : Class ) : IObjectCodec
		{
			var codec : IObjectCodec = getCodecForType( type );
			if ( codec == null )
			{
				return reflectionCodec;
			}
			return codec;
		}

		public function addCustomCodec( codec : IObjectCodec, type : Class ) : void
		{
			codecs[type] = codec;
		}

		public function encodeComponent( object : Object ) : Object
		{
			if ( object === null )
			{
				return { value : null };
			}
			var codec : IObjectCodec = getCodecForComponent( object );
			if ( codec )
			{
				return codec.encode( object, this );
			}
			return { value : null };
		}

		public function encodeObject( object : Object ) : Object
		{
			if ( object === null )
			{
				return { value : null };
			}
			var codec : IObjectCodec = getCodecForObject( object );
			if ( codec )
			{
				return codec.encode( object, this );
			}
			return { value : null };
		}

		public function decodeComponent( object : Object ) : Object
		{
			if( !object.hasOwnProperty( "type" ) || ( object.hasOwnProperty( "value" ) && object.value === null ) )
			{
				return null;
			}
			var codec : IObjectCodec = getCodecForComponentType( getDefinitionByName( object.type ) as Class );
			if ( codec )
			{
				return codec.decode( object, this );
			}
			return null;
		}

		public function decodeObject( object : Object ) : Object
		{
			if( !object.hasOwnProperty( "type" ) || ( object.hasOwnProperty( "value" ) && object.value === null ) )
			{
				return null;
			}
			var codec : IObjectCodec = getCodecForType( getDefinitionByName( object.type ) as Class );
			if ( codec )
			{
				return codec.decode( object, this );
			}
			return null;
		}

		public function decodeIntoComponent( target : Object, encoded : Object ) : void
		{
			if( !encoded.hasOwnProperty( "type" ) || ( encoded.hasOwnProperty( "value" ) && encoded.value === null ) )
			{
				return;
			}
			var codec : IObjectCodec = getCodecForComponentType( getDefinitionByName( encoded.type ) as Class );
			if ( codec )
			{
				codec.decodeIntoObject( target, encoded, this );
			}
		}

		public function decodeIntoProperty( parent : Object, property : String, encoded : Object ) : void
		{
			if( !encoded.hasOwnProperty( "type" ) || ( encoded.hasOwnProperty( "value" ) && encoded.value === null ) )
			{
				return;
			}
			var codec : IObjectCodec = getCodecForType( getDefinitionByName( encoded.type ) as Class );
			if ( codec )
			{
				codec.decodeIntoProperty( parent, property, encoded, this );
			}
		}
	}
}
