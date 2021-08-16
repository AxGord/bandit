package view;

/**
 * Bandit View
 * @author AxGord <axgord@gmail.com>
 */
@:assets_parent(Assets)
@:nullSafety(Strict) final class BanditView extends Anim implements HasAsset {

	@:asset('Idle/LightBandit_Idle') private static final IDLE = 'bandit.atlas';
	@:asset('Jump/LightBandit_Jump') private static final JUMP = 'bandit.atlas';
	@:asset('Run/LightBandit_Run') private static final RUN = 'bandit.atlas';

	private final offset: Point<Int>;

	private var idle: Bool = true;

	public function new(offset: Point<Int>) {
		super(animation(JUMP), 3);
		this.offset = offset;
	}

	public function lostGround(): Void play(animation(JUMP));
	public function ground(): Void play(animation(idle ? IDLE : RUN));

	public function updateGroundAnimation(v: Float): Void {
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

	public function startRunLeft(): Void {
		offset.x = MathTools.cabs(offset.x);
		scaleX = 1;
	}

	public function startRunRight(): Void {
		offset.x = -MathTools.cabs(offset.x);
		scaleX = -1;
	}

	public inline function setX(value: Float): Void x = value - offset.x;
	public inline function setY(value: Float): Void y = value - offset.y;

	public inline function setPos(p: Point<Int>): Void {
		final r: Point<Int> = p - offset;
		setPosition(r.x, r.y);
	}

}