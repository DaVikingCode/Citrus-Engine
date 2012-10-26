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
* A 2-by-2 matrix. Stored in column-major order.
*/
public class b2Mat22
{
	public function b2Mat22()
	{
		col1.x = col2.y = 1.0;
	}
	
	public static function FromAngle(angle:Number):b2Mat22
	{
		var mat:b2Mat22 = new b2Mat22();
		mat.Set(angle);
		return mat;
	}
	
	public static function FromVV(c1:b2Vec2, c2:b2Vec2):b2Mat22
	{
		var mat:b2Mat22 = new b2Mat22();
		mat.SetVV(c1, c2);
		return mat;
	}

	public function Set(angle:Number) : void
	{
		var c:Number = Math.cos(angle);
		var s:Number = Math.sin(angle);
		col1.x = c; col2.x = -s;
		col1.y = s; col2.y = c;
	}
	
	public function SetVV(c1:b2Vec2, c2:b2Vec2) : void
	{
		col1.SetV(c1);
		col2.SetV(c2);
	}
	
	public function Copy():b2Mat22{
		var mat:b2Mat22 = new b2Mat22();
		mat.SetM(this);
		return mat;
	}
	
	public function SetM(m:b2Mat22) : void
	{
		col1.SetV(m.col1);
		col2.SetV(m.col2);
	}
	
	public function AddM(m:b2Mat22) : void
	{
		col1.x += m.col1.x;
		col1.y += m.col1.y;
		col2.x += m.col2.x;
		col2.y += m.col2.y;
	}
	
	public function SetIdentity() : void
	{
		col1.x = 1.0; col2.x = 0.0;
		col1.y = 0.0; col2.y = 1.0;
	}

	public function SetZero() : void
	{
		col1.x = 0.0; col2.x = 0.0;
		col1.y = 0.0; col2.y = 0.0;
	}
	
	public function GetAngle() :Number
	{
		return Math.atan2(col1.y, col1.x);
	}

	/**
	 * Compute the inverse of this matrix, such that inv(A) * A = identity.
	 */
	public function GetInverse(out:b2Mat22):b2Mat22
	{
		var a:Number = col1.x; 
		var b:Number = col2.x; 
		var c:Number = col1.y; 
		var d:Number = col2.y;
		//var B:b2Mat22 = new b2Mat22();
		var det:Number = a * d - b * c;
		if (det != 0.0)
		{
			det = 1.0 / det;
		}
		out.col1.x =  det * d;	out.col2.x = -det * b;
		out.col1.y = -det * c;	out.col2.y =  det * a;
		return out;
	}
	
	// Solve A * x = b
	public function Solve(out:b2Vec2, bX:Number, bY:Number):b2Vec2
	{
		//float32 a11 = col1.x, a12 = col2.x, a21 = col1.y, a22 = col2.y;
		var a11:Number = col1.x;
		var a12:Number = col2.x;
		var a21:Number = col1.y;
		var a22:Number = col2.y;
		//float32 det = a11 * a22 - a12 * a21;
		var det:Number = a11 * a22 - a12 * a21;
		if (det != 0.0)
		{
			det = 1.0 / det;
		}
		out.x = det * (a22 * bX - a12 * bY);
		out.y = det * (a11 * bY - a21 * bX);
		
		return out;
	}
	
	public function Abs() : void
	{
		col1.Abs();
		col2.Abs();
	}

	public var col1:b2Vec2 = new b2Vec2();
	public var col2:b2Vec2 = new b2Vec2();
};

}