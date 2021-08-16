package controller;

import view.HudView;

/**
 * Load Controller
 * @author AxGord <axgord@gmail.com>
 */
@:nullSafety(Strict) final class LoadController {

	private final application: HeapsApp;

	public function new(application: HeapsApp) {
		this.application = application;
		AssetManager.loadComplete(initLoad, loadHandler);
	}

	private function initLoad(cb: (Int, Int) -> Void): Void {
		final p = AssetManager.cbjoin(cb);
		Assets.loadAllAssets(p.a);
		HudView.loadUI(p.b);
	}

	private function loadHandler(): Void {
		#if js
		js.Browser.document.getElementById('preloader').remove();
		#end
		new MainController(application);
	}

}