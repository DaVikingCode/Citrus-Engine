package ash.io.enginecodecs
{
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.io.objectcodecs.CodecManager;
	import ash.io.objectcodecs.IObjectCodec;
	import flash.utils.getDefinitionByName;

	internal class EngineDecoder
	{
		private var codecManager : CodecManager;
		private var componentMap : Array;
		private var encodedComponentMap : Array;

		public function EngineDecoder( codecManager : CodecManager )
		{
			this.codecManager = codecManager;
			componentMap = new Array();
			encodedComponentMap = new Array();
		}

		public function reset() : void
		{
			componentMap.length = 0;
			encodedComponentMap.length = 0;
		}

		public function decodeEngine( encodedData : Object, engine : Engine ) : void
		{
			for each ( var encodedComponent : Object in encodedData.components )
			{
				decodeComponent( encodedComponent );
			}

			for each ( var encodedEntity : Object in encodedData.entities )
			{
				engine.addEntity( decodeEntity( encodedEntity ) );
			}
		}

		public function decodeOverEngine( encodedData : Object, engine : Engine ) : void
		{
			for each ( var encodedComponent : Object in encodedData.components )
			{
				encodedComponentMap[encodedComponent.id] = encodedComponent;
				decodeComponent( encodedComponent );
			}

			for each ( var encodedEntity : Object in encodedData.entities )
			{
				if ( encodedEntity.hasOwnProperty( "name" ) )
				{
					var name : String = encodedEntity.name;
					if( name )
					{
						var existingEntity : Entity = engine.getEntityByName( name );
						if( existingEntity )
						{
							overlayEntity( existingEntity, encodedEntity );
							continue;
						}
					}
				}
				engine.addEntity( decodeEntity( encodedEntity ) );
			}
		}
		
		private function overlayEntity( entity : Entity, encodedEntity : Object ) : void
		{
			for each ( var componentId : int in encodedEntity.components )
			{
				if ( componentMap.hasOwnProperty( componentId ) )
				{
					var newComponent : Object = componentMap[componentId];
					if( newComponent )
					{
						var type : Class = newComponent.constructor as Class;
						var existingComponent : Object = entity.get( type );
						if( existingComponent )
						{
							codecManager.decodeIntoComponent( existingComponent, encodedComponentMap[componentId] );
						}
						else
						{
							entity.add( newComponent );
						}
					}
				}
			}
		}

		private function decodeEntity( encodedEntity : Object ) : Entity
		{
			var entity : Entity = new Entity();
			if ( encodedEntity.hasOwnProperty( "name" ) )
			{
				entity.name = encodedEntity.name;
			}
			for each ( var componentId : int in encodedEntity.components )
			{
				if ( componentMap.hasOwnProperty( componentId ) )
				{
					entity.add( componentMap[componentId] );
				}
			}
			return entity;
		}

		private function decodeComponent( encodedComponent : Object ) : void
		{
			var codec : IObjectCodec = codecManager.getCodecForComponent( getDefinitionByName( encodedComponent.type ) );
			if( codec )
			{
				componentMap[encodedComponent.id] = codecManager.decodeComponent( encodedComponent );
			}
		}
	}
}
