package ash.io.enginecodecs
{
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.io.objectcodecs.CodecManager;
	import ash.io.objectcodecs.IObjectCodec;
	import flash.utils.Dictionary;

	internal class EngineEncoder
	{
		private var codecManager : CodecManager;
		private var componentEncodingMap : Dictionary;
		private var encodedEntities : Array;
		private var encodedComponents : Array;
		private var nextComponentId : uint;
		private var encoded : Object;
		
		public function EngineEncoder( codecManager : CodecManager )
		{
			this.codecManager = codecManager;
			reset();
		}
		
		public function reset() : void
		{
			nextComponentId = 1;
			encodedEntities = [];
			encodedComponents = [];
			componentEncodingMap = new Dictionary();
			encoded = { entities : encodedEntities, components : encodedComponents };
		}

		public function encodeEngine( engine : Engine ) : Object
		{
			var entities : Vector.<Entity> = engine.entities;

			for each ( var entity : Entity in entities )
			{
				encodeEntity( entity );
			}
			return encoded;
		}

		private function encodeEntity( entity : Entity ) : void
		{
			var components : Array = entity.getAll();
			var componentIds : Array = [];
			for each ( var component : * in components )
			{
				var encodedComponent : Object = encodeComponent( component );
				if( encodedComponent )
				{
					componentIds[ componentIds.length ] = encodedComponent;
				}
			}
			encodedEntities[ encodedEntities.length ] = {
				name : entity.name,
				components : componentIds
			};
		}

		private function encodeComponent( component : Object ) : uint
		{
			if ( componentEncodingMap[ component ] )
			{
				return componentEncodingMap[ component ].id;
			}
			var encoded : Object = codecManager.encodeComponent( component );
			if( encoded )
			{
				encoded.id = nextComponentId++;
				componentEncodingMap[ component ] = encoded;
				encodedComponents[ encodedComponents.length ] = encoded;
				return encoded.id;
			}
			return 0;
		}
	}
}
