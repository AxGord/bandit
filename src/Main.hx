@:assets_path('')
final class Main extends Scene implements HasAsset {

	@:asset private static final level = 'dungeon.ldtk';
	@:asset private static final undergroud = '@tiles/dungeon.png';

	private final app: HeapsApp;
	private final levels: Levels = new Levels();

	private function new(app: HeapsApp) {
		super();
		this.app = app;
		AssetManager.baseUrl = 'assets/';
		HeapsUtils.initResLoader(ASSETS_LIST);
		AssetManager.loadComplete(cb -> {
			final p = AssetManager.cbjoin(cb);
			Main.loadAllAssets(p.a);
			MainUI.loadUI(p.b);
		}, loadHandler);
	}

	private function loadHandler(): Void {
		#if js
		js.Browser.document.getElementById('preloader').remove();
		#end
		levels.parseJson(text(level));
		final ui = new MainUI(this);
		ui.createUI(app);
		final gridSize: Int = levels.all_tilesets.Assets.tileGridSize;
		final level = new LevelView(ui.container, levels.all_levels.Level_0, levels);
		new BanditView(level, gridSize).setLevel(level.blocks);
	}

	private static function main():Void {
		AssetManager.baseUrl = Config.baseUrl;
		#if js
			pony.JsTools.onDocReady < init;
		#else
			#if (app == 'win')
			hl.UI.closeConsole();
			#end
			inline init();
		#end
	}

	private static function init(): Void new HeapsApp(new Point<Int>(Config.width, Config.height), Config.background).onInit < initHandler;
	private static function initHandler(application: HeapsApp): Void application.setScalableScene(new Main(application));

}

@:ui('ui/main.xml')
class MainUI extends HeapsXmlUi {}