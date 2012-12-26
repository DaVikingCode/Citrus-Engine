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

package Box2D.Dynamics.Contacts {

	import Box2D.Common.b2internal;
	import Box2D.Dynamics.b2Body;
	
	
use namespace b2internal;
	
/**
* A contact edge is used to connect bodies and contacts together
* in a contact graph where each body is a node and each contact
* is an edge. A contact edge belongs to a doubly linked list
* maintained in each attached body. Each contact has two contact
* nodes, one for each attached body.
*/
public class b2ContactEdge
{
	public function b2ContactEdge() {}
	
	public var other:b2Body;
	public var contact:b2Contact;
	public var prev:b2ContactEdge;
	public var next:b2ContactEdge;
};
	
	
	
}