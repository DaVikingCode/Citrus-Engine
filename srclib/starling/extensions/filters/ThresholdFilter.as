/**
 *	Copyright (c) 2012 Andy Saia
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

package starling.extensions.filters {

	import starling.filters.FragmentFilter;
	import starling.textures.Texture;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
 
    public class ThresholdFilter extends FragmentFilter
    {
        private var mShaderProgram:Program3D;
		private var mThresholdValue:Number;
		private var mThreshold:Vector.<Number>;
 
        public function ThresholdFilter(threshold:Number)
        {
			mThresholdValue = threshold;
			mThreshold = Vector.<Number>([ 0, 0, 0, mThresholdValue]);
        }
 
        public override function dispose():void
        {
            if (mShaderProgram) mShaderProgram.dispose();
            super.dispose();
        }
 
        protected override function createPrograms():void
        {
			var vertexShaderString:String =
				"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output space
				"mov v0, va1     \n";  // pass texture coordinates to fragment program
 
			var fragmentShaderString:String =
				"tex ft1, v0, fs0 <2d, linear, nomip> \n" + // just forward texture color
				"sub ft1 ft1 fc1.w\n" + // subtracts threshold value from the texture data's alpha channel
				"kil ft1.w \n" + // haltes execution for alpah values less then zero
				"add ft1 ft1 fc1.w\n" + // adds back threshold value to texture data's alpha channel
				"mov oc, ft1 \n"; //outputs the resulting image
 
            mShaderProgram = assembleAgal(fragmentShaderString, vertexShaderString);
        }
 
        protected override function activate(pass:int, context:Context3D, texture:Texture):void
        {
            // already set by super class:
            //
            // vertex constants 0-3: mvpMatrix (3D)
            // vertex attribute 0:   vertex position (FLOAT_2)
            // vertex attribute 1:   texture coordinates (FLOAT_2)
            // texture 0:            input texture
 
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mThreshold, 1); //sets this vector to fc0
			
			//var valueToSet:Vector.<Number> = Vector.<Number>([0,0,0, mThresholdValue]);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, mThreshold, 1); //sets this vector to fc1
			
            context.setProgram(mShaderProgram);
        }
 
		override protected function deactivate(pass:int, context:Context3D, texture:Texture):void
		{
		}
		
		//---------------
		//  getters and setters
		//---------------
		
		public function get thresholdValue():Number 
		{
			return mThresholdValue;
		}
		
		/**
		 * alpha value threshold
		 * @param value between 0 and 1
		 */
		public function set thresholdValue(value:Number):void 
		{
			mThresholdValue = value;
			mThreshold[3] = mThresholdValue;
		}
    }
}