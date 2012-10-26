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

package Box2D.Common{

	import Box2D.Common.Math.*;
	


/**
* Color for debug drawing. Each value has the range [0,1].
*/

public class b2Color
{

	public function b2Color(rr:Number, gg:Number, bb:Number){
		_r = uint(255 * b2Math.Clamp(rr, 0.0, 1.0));
		_g = uint(255 * b2Math.Clamp(gg, 0.0, 1.0));
		_b = uint(255 * b2Math.Clamp(bb, 0.0, 1.0));
	}
	
	public function Set(rr:Number, gg:Number, bb:Number):void{
		_r = uint(255 * b2Math.Clamp(rr, 0.0, 1.0));
		_g = uint(255 * b2Math.Clamp(gg, 0.0, 1.0));
		_b = uint(255 * b2Math.Clamp(bb, 0.0, 1.0));
	}
	
	// R
	public function set r(rr:Number) : void{
		_r = uint(255 * b2Math.Clamp(rr, 0.0, 1.0));
	}
	// G
	public function set g(gg:Number) : void{
		_g = uint(255 * b2Math.Clamp(gg, 0.0, 1.0));
	}
	// B
	public function set b(bb:Number) : void{
		_b = uint(255 * b2Math.Clamp(bb, 0.0, 1.0));
	}
	
	// Color
	public function get color() : uint{
		return (_r << 16) | (_g << 8) | (_b);
	}
	
	private var _r:uint = 0;
	private var _g:uint = 0;
	private var _b:uint = 0;

};

}