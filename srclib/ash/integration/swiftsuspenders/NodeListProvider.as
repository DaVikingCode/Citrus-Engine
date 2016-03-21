package ash.integration.swiftsuspenders
{
	import ash.core.Engine;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;

	/**
	 * A custom dependency provider for SwiftSuspenders to allow injection
	 * of NodeList objects based on the node class they contain.
	 * 
	 * <p>This enables injections rules like</p>
	 * 
	 * <p>[Inject(nodeType="com.myDomain.project.nodes.MyNode")]
	 * public var nodes : NodeList;</p>
	 */
	public class NodeListProvider implements DependencyProvider
	{
		private var engine : Engine;

		public function NodeListProvider( engine : Engine )
		{
			this.engine = engine;
		}

		public function apply( targetType : Class, activeInjector : Injector, injectParameters : Dictionary ) : Object
		{
			if ( injectParameters["nodeType"] )
			{
				var nodeClass : Class = getDefinitionByName( injectParameters["nodeType"] ) as Class;
				if ( nodeClass )
				{
					return engine.getNodeList( nodeClass );
				}
			}
			return null;
		}

		public function destroy() : void
		{

		}
	}
}
