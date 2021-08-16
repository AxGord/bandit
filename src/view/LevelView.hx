package view;

/**
 * Level View
 * @author AxGord <axgord@gmail.com>
 */
@:assets_parent(Assets)
@:nullSafety(Strict) final class LevelView extends Object implements HasAsset {

	@:asset private static final undergroud = '@tiles/dungeon.png';
	@:asset private static final bg1 = '@tiles/bg1.png';
	@:asset private static final bg2 = '@tiles/bg2.png';

	private final application: HeapsApp;

	public function new(application: HeapsApp) {
		super(application.s2d);
		this.application = application;
		application.canvas.onDynStageResize << updateCamera;
	}

	public function addTiles(tiles: Layer_Tiles, def: LayerDefJson, tilesets: TilesetDefJson): Void {
		@:nullSafety(Off) final group: TileGroup = tiles.render();
		group.setPosition(-def.tilePivotX * tilesets.tileGridSize, -def.tilePivotY * tilesets.tileGridSize);
		addChild(group);
	}

	public function updateCamera(): Void {
		setScale(1);
		final r: Rect<Float> = application.canvas.dynStage;
		@:nullSafety(Off) final ch: Object = children.pop(); // tmp hide hero for correct resize
		var b: Bounds = getBounds();
		setScale(Math.min(r.width / b.width, r.height / b.height));
		b = getBounds();
		setPosition(r.width / 2 - b.width / 2, r.height / 2 - b.height / 2);
		children.push(ch);
	}

}