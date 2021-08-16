package controller;

/**
 * Main Controller
 * Entry point after init and load
 * @author AxGord <axgord@gmail.com>
 */
@:nullSafety(Strict) final class MainController {

	private final application: HeapsApp;
	private final levelsController: LevelsController;
	private final hudController: HudController;

	public function new(application: HeapsApp) {
		this.application = application;
		levelsController = new LevelsController(application);
		hudController = new HudController(application);
		levelsController.onLevel << hudController.level;
		levelsController.start();
	}

}