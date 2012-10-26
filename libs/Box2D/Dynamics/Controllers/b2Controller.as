/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

package Box2D.Dynamics.Controllers 
{

	import Box2D.Common.b2internal;
	import Box2D.Dynamics.*;
use namespace b2internal;
	
/**
 * Base class for controllers. Controllers are a convience for encapsulating common
 * per-step functionality.
 */
public class b2Controller 
{
	public virtual function Step(step:b2TimeStep):void {}
		
	public virtual function Draw(debugDraw:b2DebugDraw):void { }
	
	public function AddBody(body:b2Body) : void 
	{
		var edge:b2ControllerEdge = new b2ControllerEdge();
		edge.controller = this;
		edge.body = body;
		//
		edge.nextBody = m_bodyList;
		edge.prevBody = null;
		m_bodyList = edge;
		if (edge.nextBody)
			edge.nextBody.prevBody = edge;
		m_bodyCount++;
		//
		edge.nextController = body.m_controllerList;
		edge.prevController = null;
		body.m_controllerList = edge;
		if (edge.nextController)
			edge.nextController.prevController = edge;
		body.m_controllerCount++;
	}
	
	public function RemoveBody(body:b2Body) : void
	{
		var edge:b2ControllerEdge = body.m_controllerList;
		while (edge && edge.controller != this)
			edge = edge.nextController;
			
		//Attempted to remove a body that was not attached?
		//b2Settings.b2Assert(bEdge != null);
		
		if (edge.prevBody)
			edge.prevBody.nextBody = edge.nextBody;
		if (edge.nextBody)
			edge.nextBody.prevBody = edge.prevBody;
		if (edge.nextController)
			edge.nextController.prevController = edge.prevController;
		if (edge.prevController)
			edge.prevController.nextController = edge.nextController;
		if (m_bodyList == edge)
			m_bodyList = edge.nextBody;
		if (body.m_controllerList == edge)
			body.m_controllerList = edge.nextController;
		body.m_controllerCount--;
		m_bodyCount--;
		//b2Settings.b2Assert(body.m_controllerCount >= 0);
		//b2Settings.b2Assert(m_bodyCount >= 0);
	}
	
	public function Clear():void
	{
		while (m_bodyList)
			RemoveBody(m_bodyList.body);
	}
	
	public function GetNext():b2Controller{return m_next;}
	public function GetWorld():b2World { return m_world; }
	
	public function GetBodyList() : b2ControllerEdge
	{
		return m_bodyList;
	}
	
	b2internal var m_next:b2Controller;
	b2internal var m_prev:b2Controller;
	
	protected var m_bodyList:b2ControllerEdge;
	protected var m_bodyCount:int;
	
	b2internal var m_world:b2World;
}
	
}