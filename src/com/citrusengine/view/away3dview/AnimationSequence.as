package com.citrusengine.view.away3dview {

	import away3d.animators.VertexAnimationSet;
	import away3d.animators.VertexAnimator;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.materials.TextureMaterial;
	import away3d.utils.Cast;

	import flash.display.Bitmap;
	import flash.display.BitmapData;

	/**
	 * @author Aymeric
	 */
	public class AnimationSequence extends ObjectContainer3D {
		
		private var _mesh:Mesh;
		
		private var _Model:*;
		private var _Texture:Bitmap;
		
		private var _animationSet:VertexAnimationSet;

		public function AnimationSequence(Model:*, Texture:Bitmap) {
			
			_Model = Model;
			_Texture = Texture;
			
			AssetLibrary.loadData(_Model);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, _onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, _onResourceComplete);
		}
		
		public function get mesh():Mesh {
			return _mesh;
		}
		
		private function _onAssetComplete(event:AssetEvent):void {
			
			if (event.asset.assetType == AssetType.MESH) {
				_mesh = event.asset as Mesh;
				AssetLibrary.removeEventListener(AssetEvent.ASSET_COMPLETE, _onAssetComplete);

			} else if (event.asset.assetType == AssetType.ANIMATION_SET) {
				_animationSet = event.asset as VertexAnimationSet;
				
			}
		}

		private function _onResourceComplete(event:LoaderEvent):void {
			
			AssetLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, _onResourceComplete);

			var bitmapData:BitmapData = _Texture.bitmapData;
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(bitmapData));

			_mesh.material = material;
			addChild(_mesh);
			
			// create animator
			_mesh.animator = new VertexAnimator(_animationSet);
			//_mesh.animator.activeState.looping = false; -> index problem, why?
		}
		
		public function changeAnimation(animation:String):void {
			
			_mesh.animator.play(animation);
		}
	}
}
