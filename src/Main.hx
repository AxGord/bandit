import controller.LoadController;

/**
 * Bandit and dungeon
 * Entry point
 * @author AxGord <axgord@gmail.com>
 */
function main(): Void {
	#if debug
	Logable.vscodePatchTrace();
	#end
	AssetManager.baseUrl = Config.baseUrl;
	#if js
		js.Browser.console.log('Build date: ${pony.Tools.getBuildDate()}');
		pony.JsTools.onDocReady < init;
	#else
		#if (app == 'win')
		hl.UI.closeConsole();
		#end
		inline init();
	#end
}

function init(): Void {
	new HeapsApp(new Point<Int>(Config.width, Config.height), Config.background).onInit < initHandler;
}

function initHandler(application: HeapsApp): Void {
	application.setFixedScene(new Scene());
	new LoadController(application);
}