package model;

import model.MoveAxisModel;

typedef ControlKeys = {
	left: Key,
	right: Key,
	up: Key,
	down: Key
}

/**
 * Bandit Model
 * @author AxGord <axgord@gmail.com>
 */
@:nullSafety(Strict) final class BanditModel implements HasSignal {

	@:auto public final onGround: Signal0;
	@:auto public final onLostGround: Signal0;

	private final onGroundCollision: Signal0;

	public final downLeft: Signal0;
	public final downRight: Signal0;

	public final xAxis: MoveAxisModel;
	public final yAxis: MoveAxisModel;

	public function new(control: ControlKeys, xConfig: MoveConfig, yConfig: MoveConfig) {
		downLeft = Keyboard.down - control.left;
		downRight = Keyboard.down - control.right;
		xAxis = new MoveAxisModel(
			xConfig,
			{
				downUp: downLeft,
				upUp: Keyboard.up - control.left,
				downDown: downRight,
				upDown: Keyboard.up - control.right
			}
		);
		yAxis = new MoveAxisModel(yConfig, { downUp: Keyboard.down - control.up });
		onGroundCollision = yAxis.onCollision - true;
		onGroundCollision < ground;
		link();
	}

	public function setLevel(blocks: Array<Point<Int>>, gridSize: Int, pos: Point<Int>, ?rect: Rect<Int>): Void {
		xAxis.start(blocks, gridSize, 0, rect == null ? null : new Point(rect.x, rect.width));
		yAxis.start(blocks.map(p -> p.swap), gridSize, 0, rect == null ? null : new Point(rect.y, rect.height));
		setPos(pos);
	}

	private inline function link(): Void {
		xAxis.changeValue << yAxis.setOther;
		yAxis.changeValue << xAxis.setOther;
	}

	private inline function unlink(): Void {
		xAxis.changeValue >> yAxis.setOther;
		yAxis.changeValue >> xAxis.setOther;
	}

	public inline function setPos(p: Point<Int>): Void {
		xAxis.value = p.x;
		yAxis.value = p.y;
	}

	public function ground(): Void {
		yAxis.listenImpulse();
		yAxis.onLostCollision < lostGround;
		eGround.dispatch();
	}

	private function lostGround(): Void {
		yAxis.unlistenImpulse();
		onGroundCollision < ground;
		eLostGround.dispatch();
	}

}