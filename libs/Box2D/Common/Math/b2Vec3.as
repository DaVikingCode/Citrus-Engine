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

package Box2D.Common.Math{

	


/**
* A 2D column vector with 3 elements.
*/

public class b2Vec3
{
	/**
	 * Construct using co-ordinates
	 */
	public function b2Vec3(x:Number = 0, y:Number = 0, z:Number = 0)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	/**
	 * Sets this vector to all zeros
	 */
	public function SetZero():void
	{
		x = y = z = 0.0;
	}
	
	/**
	 * Set this vector to some specified coordinates.
	 */
	public function Set(x:Number, y:Number, z:Number):void
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public function SetV(v:b2Vec3):void
	{
		x = v.x;
		y = v.y;
		z = v.z;
	}
	
	/**
	 * Negate this vector
	 */
	public function GetNegative():b2Vec3 { return new b2Vec3( -x, -y, -z); }
	
	public function NegativeSelf():void { x = -x; y = -y; z = -z; }
	
	public function Copy():b2Vec3{
		return new b2Vec3(x,y,z);
	}
	
	public function Add(v:b2Vec3) : void
	{
		x += v.x; y += v.y; z += v.z;
	}
	
	public function Subtract(v:b2Vec3) : void
	{
		x -= v.x; y -= v.y; z -= v.z;
	}

	public function Multiply(a:Number) : void
	{
		x *= a; y *= a; z *= a;
	}
	
	public var x:Number;
	public var y:Number;
	public var z:Number;
	
}
}