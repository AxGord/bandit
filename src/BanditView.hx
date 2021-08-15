@:assets_parent(Main)
class BanditView extends Anim implements HasAsset {

	@:asset('Idle/LightBandit_Idle') private static final IDLE = 'bandit.atlas';
	@:asset('Jump/LightBandit_Jump') private static final JUMP = 'bandit.atlas';
	@:asset('Run/LightBandit_Run') private static final RUN = 'bandit.atlas';

	private static final downLeft: Signal0 = Keyboard.down - Key.Left;
	private static final downRight: Signal0 = Keyboard.down - Key.Right;
	private static final downUp: Signal0 = Keyboard.down - Key.Up;
	private static final downDown: Signal0 = Keyboard.down - Key.Down;
	private static final upLeft: Signal0 = Keyboard.up - Key.Left;
	private static final upRight: Signal0 = Keyboard.up - Key.Right;
	private static final upUp: Signal0 = Keyboard.up - Key.Up;
	private static final upDown: Signal0 = Keyboard.up - Key.Down;

	public final onRightLimit: Signal0;
	public final onLeftLimit: Signal0;

	private final offset: Point<Int> = 24;

	private final yAxis: MoveAxis;
	private final xAxis: MoveAxis;
	private var idle: Bool = true;

	public function new() {
		super(animation(JUMP), 3);
		final yConfig: MoveConfig = {
			coreSize: new Point(22, 12),
			minSpeed: 1,
			maxSpeed: 300,
			acceleration: 0,
			friction: 200,
			gravity: 600,
			impulse: 1000
		};
		final xConfig: MoveConfig = {
			coreSize: yConfig.coreSize.swap,
			minSpeed: yConfig.minSpeed,
			maxSpeed: 80,
			acceleration: 300,
			friction: 200
		};
		xAxis = new MoveAxis(
			xConfig,
			{downUp: downLeft, upUp: upLeft, downDown: downRight, upDown: upRight}
		);
		onRightLimit = xAxis.onLimit - true;
		onLeftLimit = xAxis.onLimit - false;
		yAxis = new MoveAxis(
			yConfig,
			{downUp: downUp, downDown: downDown}
		);
		xAxis.changeValue << setX;
		yAxis.changeValue << setY;

		// final g = new Graphics();
		// g.beginFill(0x990022);
		// g.drawCircle(offset.x, offset.y, 2);
		// addChild(g);

		yAxis.onCollision - true < ground;
		downLeft << startRunLeft;
		downRight << startRunRight;
	}

	private function lostGround(): Void {
		yAxis.unlistenImpulse();
		xAxis.changeSpeed >> updateGroundAnimation;
		play(animation(JUMP));
		yAxis.onCollision - true < ground;
	}

	private function ground(): Void {
		updateGroundAnimation(xAxis.speed);
		play(animation(idle ? IDLE : RUN));
		xAxis.changeSpeed << updateGroundAnimation;
		yAxis.listenImpulse();
		yAxis.onLostCollision < lostGround;
	}

	private function updateGroundAnimation(v: Float): Void {
		final nIdle: Bool = v == 0;
		if (nIdle != idle) {
			play(animation(nIdle ? IDLE : RUN));
			idle = nIdle;
			if (nIdle) speed = 3;
		}
		if (!nIdle) {
			v = Math.abs(v / 10);
			if (v < 5) v = 5;
			speed = v;
		}
	}

	private function startRunLeft(): Void {
		DeltaTime.fixedUpdate >> _startRunRight;
		DeltaTime.fixedUpdate < _startRunLeft;
		posChanged = false;
	}

	private function _startRunLeft(): Void {
		offset.x = MathTools.cabs(offset.x);
		scaleX = 1;
		posChanged = false;
		DeltaTime.fixedUpdate < undoPosChanged;
	}

	private function startRunRight(): Void {
		DeltaTime.fixedUpdate >> _startRunLeft;
		DeltaTime.fixedUpdate < _startRunRight;
		posChanged = false;
	}

	private function _startRunRight(): Void {
		offset.x = -MathTools.cabs(offset.x);
		scaleX = -1;
		posChanged = false;
		DeltaTime.fixedUpdate < undoPosChanged;
	}

	private function undoPosChanged(): Void posChanged = false;

	private function setX(value: Float): Void {
		x = value - offset.x;
		yAxis.otherAxisValue = value;
	}

	private function setY(value: Float): Void {
		y = value - offset.y;
		xAxis.otherAxisValue = value;
	}

	public function setPos(p: Point<Int>): Void {
		xAxis.changeValue >> setX;
		yAxis.changeValue >> setY;
		final r = p - offset;
		setPosition(r.x, r.y);
		xAxis.value = p.x;
		xAxis.otherAxisValue = p.y;
		yAxis.value = p.y;
		yAxis.otherAxisValue = p.x;
		xAxis.changeValue << setX;
		yAxis.changeValue << setY;
	}

	public function setLevel(blocks: Array<Point<Int>>, gridSize: Int, ?rect: Rect<Int>): Void {
		xAxis.start(blocks, gridSize, 0, rect == null ? null : new Point(rect.x, rect.width));
		yAxis.start(blocks.map(p -> p.swap), gridSize, 0, rect == null ? null : new Point(rect.y, rect.height));
		setPos(0);
	}

}