@:assets_parent(Main)
class BanditView extends Anim implements HasAsset {

	@:asset('Idle/LightBandit_Idle') private static final idle = 'bandit.atlas';

	private static final downLeft: Signal0 = Keyboard.down - Key.Left;
	private static final downRight: Signal0 = Keyboard.down - Key.Right;
	private static final downUp: Signal0 = Keyboard.down - Key.Up;
	private static final downDown: Signal0 = Keyboard.down - Key.Down;
	private static final upLeft: Signal0 = Keyboard.up - Key.Left;
	private static final upRight: Signal0 = Keyboard.up - Key.Right;
	private static final upUp: Signal0 = Keyboard.up - Key.Up;
	private static final upDown: Signal0 = Keyboard.up - Key.Down;

	public function new(parent: Object, gridSize: Int) {
		super(animation(idle), 3, parent);
	}

	public function setLevel(blocks: Array<Point<Int>>): Void {}

}