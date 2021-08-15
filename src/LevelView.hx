@:nullSafety(Strict) final class LevelView extends Object {

	private static var reversed: Array<String> = [];

	public final blocks: Array<Point<Int>> = [];

	public function new(parent: Object, level: Levels_Level, levels: Levels) {
		super(parent);
		final lvlId: String = level.identifier;
		if (!reversed.contains(lvlId)) {
			level.allUntypedLayers.reverse();
			reversed.push(lvlId);
		}
		for (layer in level.allUntypedLayers) {
			switch layer.type {
				case Tiles:
					final tiles: Layer_Tiles = cast layer;
					for ( cy in 0...tiles.cHei ) for ( cx in 0...tiles.cWid ) if ( tiles.hasAnyTileAt(cx, cy) )
						blocks.push(new Point(cx * tiles.gridSize + tiles.pxTotalOffsetX, cy * tiles.gridSize + tiles.pxTotalOffsetY));
					@:nullSafety(Off) final group: TileGroup = tiles.render();
					final def: LayerDefJson = levels.getLayerDefJson(tiles.identifier);
					final tilesets: TilesetDefJson = levels.getTilesetDefJson(tiles.tilesetUid);
					group.setPosition(-def.tilePivotX * tilesets.tileGridSize, -def.tilePivotY * tilesets.tileGridSize);
					addChild(group);
				case _:
			}
		}

		final b = getBounds();
		setScale(Math.min(Config.width / b.width, Config.height / b.width));
		final b = getBounds();
		setPosition(Config.width / 2 - b.width / 2, Config.height / 2 - b.width / 2);
	}

}