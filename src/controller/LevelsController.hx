package controller;

import view.LevelView;

import model.LevelsModel;

/**
 * Levels Controller
 * @author AxGord <axgord@gmail.com>
 */
@:assets_parent(Assets)
@:nullSafety(Off) final class LevelsController implements HasAsset implements HasSignal {

	@:asset private static final ldtk = 'dungeon.ldtk';

	@:auto public final onLevel: Signal1<String>;

	public final banditController: BanditController;
	private final model: LevelsModel = new LevelsModel();
	private final reversed: Array<String> = [];
	private final levelView: LevelView;
	private final gridSize: Int = 0;

	public var blocks: Array<Point<Int>> = [];
	public var rect: Null<Rect<Int>> = null;

	public function new(application: HeapsApp) {
		banditController = new BanditController();
		model.parseJson(text(ldtk));
		levelView = new LevelView(application);
		gridSize = model.all_tilesets.Assets.tileGridSize;
	}

	public function start(): Void {
		HeapsUtils.initResLoader(ASSETS_LIST);
		loadLevel(model.all_levels.Level_0);
		banditController.onRightLimit < goTo1;
	}

	private function goTo1(): Void {
		loadLevel(model.all_levels.Level_1);
		banditController.onRightLimit < goTo2;
	}

	private function goTo2(): Void {
		loadLevel(model.all_levels.Level_2);
	}

	public function loadLevel(level: LevelsModel_Level): Void {
		levelView.removeChildren();
		final lvlId: String = level.identifier;
		eLevel.dispatch(lvlId);
		if (!reversed.contains(lvlId)) {
			level.allUntypedLayers.reverse();
			reversed.push(lvlId);
		}
		blocks = [];
		rect = null;
		for (layer in level.allUntypedLayers) {
			switch layer.type {
				case Tiles:
					final tiles: Layer_Tiles = cast layer;
					if (tiles.identifier == 'Main') {
						for ( cy in 0...tiles.cHei ) for ( cx in 0...tiles.cWid ) if ( tiles.hasAnyTileAt(cx, cy) )
							blocks.push(new Point(cx * tiles.gridSize + tiles.pxTotalOffsetX, cy * tiles.gridSize + tiles.pxTotalOffsetY));
						rect = new Rect(0, 0, tiles.cWid * tiles.gridSize, tiles.cHei * tiles.gridSize);
					}
					levelView.addTiles(tiles, model.getLayerDefJson(tiles.identifier), model.getTilesetDefJson(tiles.tilesetUid));
				case _:
			}
		}
		banditController.setLevel(blocks, gridSize, 50, rect);
		levelView.addChild(banditController.view);
		levelView.updateCamera();
	}

}