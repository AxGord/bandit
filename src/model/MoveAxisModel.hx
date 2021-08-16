package model;

typedef MoveConfig = {
	coreSize: Point<Int>,
	minSpeed: Float,
	maxSpeed: Float,
	acceleration: Float,
	friction: Float,
	?gravity: Float,
	?impulse: Float
}

typedef ControlSignals = {
	?downUp: Signal0,
	?upUp: Signal0,
	?downDown: Signal0,
	?upDown: Signal0
}

/**
 * Move Axis Model
 * @author AxGord <axgord@gmail.com>
 */
@:nullSafety(Strict) class MoveAxisModel extends Tumbler {

	@:auto public var onCollision: Signal1<Bool>;
	@:auto public var onLostCollision: Signal0;
	@:auto public var onLimit: Signal1<Bool>;

	@:bindable public var value: Float = 0;
	@:bindable public var otherAxisValue: Float = 0;
	@:bindable public var speed: Float = 0;

	private var internalSpeed: Float = 0;

	private var blocks: Array<Point<Int>> = [];
	private var gridSize: Int = 0;
	private var limits: Null<Point<Int>> = null;

	private final coreSize: Point<Int>;
	private final minSpeed: Float;
	private final maxSpeed: Float;
	private final acceleration: Float;
	private final friction: Float;
	private final gravity: Float = 0;
	private final impulse: Float = 0;

	private final downUp: Null<Signal0>;
	private final upUp: Null<Signal0>;
	private final downDown: Null<Signal0>;
	private final upDown: Null<Signal0>;
	private final downImpulse: Null<Signal0>;
	private final upImpulse: Null<Signal0>;

	private var upPressed: Bool = false;
	private var downPressed: Bool = false;

	public function new(config: MoveConfig, ?controlSignals: ControlSignals) {
		super(false);
		coreSize = config.coreSize;
		minSpeed = config.minSpeed;
		maxSpeed = config.maxSpeed;
		acceleration = config.acceleration;
		friction = config.friction;
		if (config.gravity != null) gravity = config.gravity;
		if (config.impulse != null) impulse = config.impulse;
		if (controlSignals != null) {
			var has: Bool = false;
			if (controlSignals.downUp != null && controlSignals.upUp != null) {
				downUp = controlSignals.downUp;
				upUp = controlSignals.upUp;
				has = true;
			} else if (controlSignals.downUp != null) {
				downImpulse = controlSignals.downUp;
				has = true;
			} else if (controlSignals.upUp != null) {
				downImpulse = controlSignals.upUp;
				has = true;
			}
			if (controlSignals.downDown != null && controlSignals.upDown != null) {
				downDown = controlSignals.downDown;
				upDown = controlSignals.upDown;
				has = true;
			} else if (controlSignals.downDown != null) {
				upImpulse = controlSignals.downDown;
				has = true;
			} else if (controlSignals.upDown != null) {
				upImpulse = controlSignals.upDown;
				has = true;
			}
			if (has) {
				onEnable << listenKeyboard;
				onDisable << unlistenKeyboard;
			}
		}

		onEnable << listenUpdate;
		onDisable << unlistenUpdate;
	}

	public function listenKeyboard(): Void {
		if (downUp != null) downUp << upBegin;
		if (upUp != null) upUp << upEnd;
		if (downDown != null) downDown << downBegin;
		if (upDown != null) upDown << downEnd;
	}

	public function unlistenKeyboard(): Void {
		if (downUp != null) downUp >> upBegin;
		if (upUp != null) upUp >> upEnd;
		if (downDown != null) downDown >> downBegin;
		if (upDown != null) upDown >> downEnd;
		if (upImpulse != null) upImpulse >> makeUpImpulse;
		if (downImpulse != null) downImpulse >> makeDownImpulse;
		unlistenImpulse();
	}

	private function makeUpImpulse(): Void internalSpeed = Math.max(internalSpeed - impulse, -maxSpeed);
	private function makeDownImpulse(): Void internalSpeed = Math.min(internalSpeed + impulse, maxSpeed);

	public function listenUpdate(): Void {
		if (gravity != 0) DeltaTime.update.add(gravityUpdate, 1);
		DeltaTime.update.add(update, 1);
	}

	public function unlistenUpdate(): Void {
		if (gravity != 0) DeltaTime.update << update;
		DeltaTime.update >> update;
	}

	public function listenImpulse(): Void {
		if (upImpulse != null) upImpulse < makeUpImpulse;
		if (downImpulse != null) downImpulse < makeDownImpulse;
	}

	public function unlistenImpulse(): Void {
		if (upImpulse != null) upImpulse >> makeUpImpulse;
		if (downImpulse != null) downImpulse >> makeDownImpulse;
	}

	private function upBegin(): Void {
		upPressed = true;
		DeltaTime.update >> downUpdate;
		DeltaTime.update << upUpdate;
	}

	private function upEnd(): Void {
		upPressed = false;
		DeltaTime.update >> upUpdate;
		if (downPressed) DeltaTime.update << downUpdate;
	}

	private function downBegin(): Void {
		downPressed = true;
		DeltaTime.update >> upUpdate;
		DeltaTime.update << downUpdate;
	}

	private function downEnd(): Void {
		downPressed = false;
		DeltaTime.update >> downUpdate;
		if (upPressed) DeltaTime.update << upUpdate;
	}

	private function upUpdate(dt: DT): Void internalSpeed = Math.min(internalSpeed + dt * acceleration, maxSpeed + friction * dt);
	private function downUpdate(dt: DT): Void internalSpeed = Math.max(internalSpeed - dt * acceleration, -maxSpeed - friction * dt);

	private function gravityUpdate(dt: DT): Void {
		internalSpeed = gravity > 0 ?
			Math.max(internalSpeed - dt * gravity, -maxSpeed - friction * dt) :
			Math.min(internalSpeed + dt * (-gravity), maxSpeed + friction * dt);
	}

	private function update(dt: DT): Void {
		var sp: Float = internalSpeed;
		if (sp != 0) {
			if (Math.abs(sp) < minSpeed) {
				speed = 0;
				return;
			}
			var v: Float = value - sp * dt;
			if (limits != null && v - coreSize.x <= limits.x) {
				v = limits.x + coreSize.x;
				sp = 0;
				eLimit.dispatch(false);
			} else if (limits != null && v + coreSize.x >= limits.y) {
				v = limits.y - coreSize.x;
				sp = 0;
				eLimit.dispatch(true);
			} else {
				var index: Int = checkCollision(v, otherAxisValue);
				if (index != -1) {
					final top: Bool = sp < 0;
					v = blocks[index].x + (top ? -coreSize.x : gridSize + coreSize.x);
					sp = 0;
					eCollision.dispatch(top);
				} else {
					eLostCollision.dispatch();
				}
			}
			if (sp > 0) {
				sp -= friction * dt;
				if (sp < minSpeed) sp = 0;
				else if (sp > maxSpeed) sp = maxSpeed;
			} else if (sp < 0) {
				sp += friction * dt;
				if (sp > minSpeed) sp = 0;
				else if (-sp > maxSpeed) sp = -maxSpeed;
			}
			internalSpeed = sp;
			speed = sp;
			value = v;
		}
	}

	private function checkCollision(a: Float, b: Float): Int {
		for (i in 0...blocks.length) {
			final p: Point<Int> = blocks[i];
			if (a + coreSize.x > p.x && a - coreSize.x < p.x + gridSize && b > p.y - coreSize.y && b - coreSize.y < p.y + gridSize)
				return i;
		}
		return -1;
	}

	public function destroy(): Void {
		unlistenKeyboard();
		upEnd();
		downEnd();
		DeltaTime.update >> update;
		destroySignals();
	}

	public inline function changeBlocks(blocksList: Array<Point<Int>>, size: Int, lim: Null<Point<Int>>): Void {
		blocks = blocksList;
		gridSize = size;
		limits = lim;
	}

	public inline function start(blocksList: Array<Point<Int>>, size: Int, pos: Point<Int>, lim: Null<Point<Int>>): Void {
		changeBlocks(blocksList, size, lim);
		setPos(pos.x, pos.y);
		enable();
	}

	public inline function stop(): Void {
		disable();
		blocks = [];
	}

	public inline function setPos(a: Float, b: Float): Void {
		value = a;
		otherAxisValue = b;
	}

	public function setOther(v: Float): Void otherAxisValue = v;

}
