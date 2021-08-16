package controller;

import view.HudView;

/**
 * HUD Controller
 * @author AxGord <axgord@gmail.com>
 */
@:nullSafety(Strict) final class HudController {

	private static final debugInfoPrefixes: Array<String> = [
		'FPS: ',
		'Level id: '
	];

	private final view: HudView;

	private final debugInfo: Array<String> = [ for (line in debugInfoPrefixes) line + '-' ];

	private var fps: Int = 0;

	public function new(application: HeapsApp) {
		view = new HudView(application.s2d);
		view.createUI(application);
		DeltaTime.fixedUpdate << update;
	}

	private function update(dt: DT): Void {
		final fps: Int = Math.ceil(dt.fps);
		if (fps != this.fps) {
			this.fps = fps;
			final s: String = dt;
			setDebugSlot(0, '$fps ($s ms)');
		}
	}

	public function level(id: String): Void setDebugSlot(1, id);

	private inline function setDebugSlot(n: UInt, v: String): Void {
		debugInfo[n] = debugInfoPrefixes[n] + v;
		DeltaTime.fixedUpdate < updateDebugInfo;
	}

	private function updateDebugInfo(): Void {
		view.debug.text = debugInfo.join('\n');
	}

}