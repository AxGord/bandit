@:assets_path('')
final class Main extends Scene implements HasAsset {

	@:asset private static final level = 'dungeon.ldtk';
	@:asset private static final undergroud = '@tiles/dungeon.png';
	@:asset private static final bg1 = '@tiles/bg1.png';
	@:asset private static final bg2 = '@tiles/bg2.png';

	private final app: HeapsApp;
	private final levels: Levels = new Levels();
	private var bandit: BanditView;
	private var gridSize: Int = 0;
	private var currentLevel: Null<LevelView> = null;
	private var ui: MainUI;

	private function new(app: HeapsApp) {
		super();
		this.app = app;
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
		ui = new MainUI(this);
		ui.createUI(app);
		bandit = new BanditView();
		gridSize = levels.all_tilesets.Assets.tileGridSize;
		HeapsUtils.initResLoader(ASSETS_LIST);
		currentLevel = new LevelView(ui.container, levels.all_levels.Level_0, levels);
		currentLevel.addChild(bandit);
		bandit.onRightLimit < goTo1;
		bandit.setLevel(currentLevel.blocks, gridSize, currentLevel.rect);
	}

	private function goTo1(): Void {
		currentLevel.remove();
		bandit.remove();
		currentLevel = new LevelView(ui.container, levels.all_levels.Level_1, levels);
		bandit.onRightLimit < goTo2;
		currentLevel.addChild(bandit);
		bandit.setLevel(currentLevel.blocks, gridSize, currentLevel.rect);
	}

	private function goTo2(): Void {
		currentLevel.remove();
		bandit.remove();
		currentLevel = new LevelView(ui.container, levels.all_levels.Level_2, levels);
		currentLevel.addChild(bandit);
		bandit.setLevel(currentLevel.blocks, gridSize, currentLevel.rect);
	}

	private static function main(): Void {
		Logable.vscodePatchTrace();
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