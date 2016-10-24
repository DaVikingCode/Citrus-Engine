package aze.motion.specials 
{
	import aze.motion.EazeTween;
	import aze.motion.specials.EazeSpecial;
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	
	/**
	 * Color matrix filter tweening
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class PropertyColorMatrix extends EazeSpecial
	{
		private var removeWhenComplete:Boolean;
		private var colorMatrix:ColorMatrix;
		private var delta:Array;
		private var start:Array;
		private var temp:Array;
		
		static public function register():void
		{
			EazeTween.specialProperties["colorMatrixFilter"] = PropertyColorMatrix;
			EazeTween.specialProperties[ColorMatrixFilter] = PropertyColorMatrix;
		}
		
		public function PropertyColorMatrix(target:Object, property:*, value:*, next:EazeSpecial)
		{
			super(target, property, value, next);
			
			colorMatrix = new ColorMatrix();
			if (value.brightness) colorMatrix.adjustBrightness(value.brightness * 0xff);
			if (value.contrast) colorMatrix.adjustContrast(value.contrast);
			if (value.hue) colorMatrix.adjustHue(value.hue);
			if (value.saturation) colorMatrix.adjustSaturation(value.saturation + 1);
			if (value.colorize)
			{
				var tint:uint = ("tint" in value) ? uint(value.tint) : 0xffffff;
				colorMatrix.colorize(tint, value.colorize);
			}
			removeWhenComplete = (value.remove);
		}
		
		override public function init(reverse:Boolean):void 
		{
			var disp:DisplayObject = DisplayObject(target);
			var current:ColorMatrixFilter = PropertyFilter.getCurrentFilter(ColorMatrixFilter, disp, true) as ColorMatrixFilter; // get and remove
			if (!current) current = new ColorMatrixFilter();
			
			var begin:Array;
			var end:Array;
			if (reverse) { end = current.matrix; begin = colorMatrix.matrix; }
			else { end = colorMatrix.matrix; begin = current.matrix; }
			
			delta = new Array(20);
			for (var i:int = 0; i < 20; i++) 
				delta[i] = end[i] - begin[i];
			
			start = begin;
			temp = new Array(20);
			
			PropertyFilter.addFilter(disp, new ColorMatrixFilter(begin)); // apply filter
		}
		
		override public function update(ke:Number, isComplete:Boolean):void
		{
			var disp:DisplayObject = DisplayObject(target);
			PropertyFilter.getCurrentFilter(ColorMatrixFilter, disp, true) as ColorMatrixFilter; // remove
			
			if (removeWhenComplete && isComplete) 
			{
				disp.filters = disp.filters;
				return;
			}
			
			for (var i:int = 0; i < 20; i++) 
				temp[i] = start[i] + ke * delta[i];
			
			PropertyFilter.addFilter(disp, new ColorMatrixFilter(temp));
		}
		
		override public function dispose():void 
		{
			colorMatrix = null;
			delta = null;
			start = null;
			temp = null;
			super.dispose();
		}
	}

}

import flash.filters.ColorMatrixFilter;

// ColorMatrix Class v2.1    (stripped down by Philippe to needed features)
//
// released under MIT License (X11)
// http://www.opensource.org/licenses/mit-license.php
//
// Author: Mario Klingemann
// http://www.quasimondo.com

/*
Copyright (c) 2008 Mario Klingemann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
class ColorMatrix 
{
	// RGB to Luminance conversion constants as found on
	// Charles A. Poynton's colorspace-faq:
	// http://www.faqs.org/faqs/graphics/colorspace-faq/
	private static const LUMA_R:Number = 0.212671;
	private static const LUMA_G:Number = 0.71516;
	private static const LUMA_B:Number = 0.072169;

	// There seem different standards for converting RGB
	// values to Luminance. This is the one by Paul Haeberli:
	private static const LUMA_R2:Number = 0.3086;
	private static const LUMA_G2:Number = 0.6094;
	private static const LUMA_B2:Number = 0.0820;

	private static const ONETHIRD:Number = 1 / 3;

	private static const IDENTITY:Array = [
		1, 0, 0, 0, 0,
		0, 1, 0, 0, 0,
		0, 0, 1, 0, 0,
		0, 0, 0, 1, 0
	];

	private static const RAD:Number = Math.PI / 180;
	
	public var matrix:Array;
	
	/*
	Function: ColorMatrix

	  Constructor

	Parameters:

	  mat - if omitted matrix gets initialized with an
			identity matrix. Alternatively it can be 
			initialized with another ColorMatrix or 
			an array (there is currently no check 
			if the array is valid. A correct array 
			contains 20 elements.)
	*/
	public function ColorMatrix ( mat:Object = null )
	{
		if (mat is ColorMatrix )
		{
			matrix = mat.matrix.concat();
		} else if (mat is Array )
		{
			matrix = mat.concat();
		} else 
		{
			reset();
		}
	}

	/*
	Function: reset

	  resets the matrix to the neutral identity matrix. Applying this
	  matrix to an image will not make any changes to it.

	Parameters:

	  none
	  
	Returns:

		nothing
	*/

	public function reset():void
	{
		matrix = IDENTITY.concat();
	}

	/*
	Function: adjustSaturation

	  changes the saturation

	Parameters:

	  s - typical values come in the range 0.0 ... 2.0 where
				 0.0 means 0% Saturation
				 0.5 means 50% Saturation
				 1.0 is 100% Saturation (aka no change)
				 2.0 is 200% Saturation
				 
				 Other values outside of this range are possible
				 -1.0 will invert the hue but keep the luminance
						
	Returns:

		nothing
	*/
	public function adjustSaturation( s:Number ):void
	{
		var sInv:Number;
		var irlum:Number;
		var iglum:Number;
		var iblum:Number;
		
		sInv = (1 - s);
		irlum = (sInv * LUMA_R);
		iglum = (sInv * LUMA_G);
		iblum = (sInv * LUMA_B);
		
		concat([(irlum + s), iglum, iblum, 0, 0, 
				irlum, (iglum + s), iblum, 0, 0, 
				irlum, iglum, (iblum + s), 0, 0, 
				0, 0, 0, 1, 0]);
	}

	/*
	Function: adjustContrast

	  changes the contrast

	Parameters:

	  s - typical values come in the range -1.0 ... 1.0 where
				 -1.0 means no contrast (grey)
				 0 means no change
				 1.0 is high contrast
				
						
	  
	Returns:

		nothing
	*/
	public function adjustContrast( r:Number, g:Number = Number.NaN, b:Number = Number.NaN ):void
	{
		if (isNaN(g)) g = r;
		if (isNaN(b)) b = r;
		r += 1;
		g += 1;
		b += 1;
		
		concat([r, 0, 0, 0, (128 * (1 - r)), 
				0, g, 0, 0, (128 * (1 - g)), 
				0, 0, b, 0, (128 * (1 - b)), 
				0, 0, 0, 1, 0]);
	}

	public function adjustBrightness(r:Number, g:Number=Number.NaN, b:Number=Number.NaN):void
	{
		if (isNaN(g)) g = r;
		if (isNaN(b)) b = r;
		concat([1, 0, 0, 0, r, 
				0, 1, 0, 0, g, 
				0, 0, 1, 0, b, 
				0, 0, 0, 1, 0]);
	}

	public function adjustHue( degrees:Number ):void
	{
		degrees *= RAD;
		var cos:Number = Math.cos(degrees);
		var sin:Number = Math.sin(degrees);
		concat([((LUMA_R + (cos * (1 - LUMA_R))) + (sin * -(LUMA_R))), ((LUMA_G + (cos * -(LUMA_G))) + (sin * -(LUMA_G))), ((LUMA_B + (cos * -(LUMA_B))) + (sin * (1 - LUMA_B))), 0, 0, 
				((LUMA_R + (cos * -(LUMA_R))) + (sin * 0.143)), ((LUMA_G + (cos * (1 - LUMA_G))) + (sin * 0.14)), ((LUMA_B + (cos * -(LUMA_B))) + (sin * -0.283)), 0, 0, 
				((LUMA_R + (cos * -(LUMA_R))) + (sin * -((1 - LUMA_R)))), ((LUMA_G + (cos * -(LUMA_G))) + (sin * LUMA_G)), ((LUMA_B + (cos * (1 - LUMA_B))) + (sin * LUMA_B)), 0, 0, 
				0, 0, 0, 1, 0]);
	}

	public function colorize(rgb:int, amount:Number=1):void
	{
		var r:Number;
		var g:Number;
		var b:Number;
		var inv_amount:Number;
		
		r = (((rgb >> 16) & 0xFF) / 0xFF);
		g = (((rgb >> 8) & 0xFF) / 0xFF);
		b = ((rgb & 0xFF) / 0xFF);
		inv_amount = (1 - amount);
		
		concat([(inv_amount + ((amount * r) * LUMA_R)), ((amount * r) * LUMA_G), ((amount * r) * LUMA_B), 0, 0, 
				((amount * g) * LUMA_R), (inv_amount + ((amount * g) * LUMA_G)), ((amount * g) * LUMA_B), 0, 0, 
				((amount * b) * LUMA_R), ((amount * b) * LUMA_G), (inv_amount + ((amount * b) * LUMA_B)), 0, 0, 
				0, 0, 0, 1, 0]);
	}
	
	public function get filter():ColorMatrixFilter
	{
		return new ColorMatrixFilter( matrix );
	}

	public function concat( mat:Array ):void
	{
		var temp:Array = [];
		var i:int = 0;
		var x:int, y:int;
		for (y = 0; y < 4; y++ )
		{
			for (x = 0; x < 5; x++ )
			{
				temp[ int( i + x) ] =  Number(mat[i  ])      * Number(matrix[x]) + 
									   Number(mat[int(i+1)]) * Number(matrix[int(x +  5)]) + 
									   Number(mat[int(i+2)]) * Number(matrix[int(x + 10)]) + 
									   Number(mat[int(i+3)]) * Number(matrix[int(x + 15)]) +
									   (x == 4 ? Number(mat[int(i+4)]) : 0);
			}
			i+=5;
		}
		
		matrix = temp;
	}
	
}