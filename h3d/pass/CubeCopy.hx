package h3d.pass;

private class CubeCopyShader extends h3d.shader.ScreenShader {

	static var SRC = {
		@param var texture : SamplerCube;
		@param var mat : Mat3x4;
		function fragment() {
			pixelColor = texture.get(vec3(calculatedUV, 1) * mat);
		}
	}
}

class CubeCopy extends ScreenFx<CubeCopyShader> {

	var cubeDir = [ h3d.Matrix.L([0,0,-1,0, 0,1,0,0, -1,-1,1,0]),
					h3d.Matrix.L([0,0,1,0, 0,1,0,0, 1,-1,-1,0]),
	 				h3d.Matrix.L([-1,0,0,0, 0,0,1,0, 1,-1,-1,0]),
	 				h3d.Matrix.L([-1,0,0,0, 0,0,-1,0, 1,1,1,0]),
				 	h3d.Matrix.L([-1,0,0,0, 0,1,0,0, 1,-1,1,0]),
				 	h3d.Matrix.L([1,0,0,0, 0,1,0,0, -1,-1,-1,0]) ];

	public function new() {
		super(new CubeCopyShader());
	}

	public function apply( from, to, ?blend : h3d.mat.BlendMode, ?customPass : h3d.mat.Pass ) {
		for(i in 0 ... 6){
			if( to != null )
				engine.pushTarget(to, i);
			shader.texture = from;
			shader.mat = cubeDir[i];
			if( customPass != null ) {
				var old = pass;
				pass = customPass;
				if( blend != null ) pass.setBlendMode(blend);
				var h = shaders;
				while( h.next != null )
					h = h.next;
				h.next = @:privateAccess pass.shaders;
				render();
				pass = old;
				h.next = null;
			} else {
				pass.setBlendMode(blend == null ? None : blend);
				render();
			}
			shader.texture = null;
			if( to != null )
				engine.popTarget();
		}
	}

	public static function run( from : h3d.mat.Texture, to : h3d.mat.Texture, ?blend : h3d.mat.BlendMode, ?pass : h3d.mat.Pass ) {
		var engine = h3d.Engine.getCurrent();
		if( to != null && from != null && (blend == null || blend == None) && pass == null && engine.driver.copyTexture(from, to) )
			return;
		var inst : CubeCopy = @:privateAccess engine.resCache.get(CubeCopy);
		if( inst == null ) {
			inst = new CubeCopy();
			@:privateAccess engine.resCache.set(CubeCopy, inst);
		}
		return inst.apply(from, to, blend, pass);
	}
}