package Box2D.Dynamics.Controllers 
{

	import Box2D.Dynamics.b2Body;
public class b2ControllerEdge 
{
	public function b2ControllerEdge() {}
	
	/** provides quick access to other end of this edge */
	public var controller:b2Controller;
	/** the body */
	public var body:b2Body;
	/** the previous controller edge in the controllers's body list */
	public var prevBody:b2ControllerEdge;
	/** the next controller edge in the controllers's body list */
	public var nextBody:b2ControllerEdge;
	/** the previous controller edge in the body's controller list */
	public var prevController:b2ControllerEdge;
	/** the next controller edge in the body's controller list */
	public var nextController:b2ControllerEdge;
}
}