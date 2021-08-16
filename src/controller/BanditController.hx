package controller;

import view.BanditView;

import model.MoveAxisModel;
import model.BanditModel;

/**
 * Bandit Controller
 * @author AxGord <axgord@gmail.com>
 */
@:nullSafety(Strict) final class BanditController {

	public final view: BanditView;
	public final model: BanditModel;
	public final onRightLimit: Signal0;
	public final onLeftLimit: Signal0;

	public function new() {
		view = new BanditView(Config.bandit_offset);

		final yConfig: MoveConfig = {
			coreSize: new Point(Config.bandit_width, Config.bandit_height),
			minSpeed: Config.bandit_minSpeed,
			maxSpeed: Config.bandit_maxSpeedY,
			acceleration: 0,
			friction: Config.bandit_friction,
			gravity: Config.bandit_gravity,
			impulse: Config.bandit_jumpImpulse
		};

		final xConfig: MoveConfig = {
			coreSize: yConfig.coreSize.swap,
			minSpeed: yConfig.minSpeed,
			maxSpeed: Config.bandit_maxSpeedX,
			acceleration: Config.bandit_acceleration,
			friction: yConfig.friction
		};

		model = new BanditModel({left: Key.Left, right: Key.Right, up: Key.Up, down: Key.Down}, xConfig, yConfig);

		onRightLimit = model.xAxis.onLimit - true;
		onLeftLimit = model.xAxis.onLimit - false;

		model.xAxis.changeValue << view.setX;
		model.yAxis.changeValue << view.setY;

		model.downLeft << view.startRunLeft;
		model.downLeft << updateX;
		model.downRight << view.startRunRight;
		model.downRight << updateX;

		model.onGround << ground;
		model.onLostGround << lostGround;
	}

	public inline function setLevel(blocks: Array<Point<Int>>, gridSize: Int, pos: Point<Int>, ?rect: Rect<Int>): Void {
		model.setLevel(blocks, gridSize, pos, rect);
		view.setPos(pos);
	}

	private function updateX(): Void view.setX(model.xAxis.value);

	public function ground(): Void {
		view.updateGroundAnimation(model.xAxis.speed);
		view.ground();
		model.xAxis.changeSpeed << view.updateGroundAnimation;
	}

	private function lostGround(): Void {
		model.yAxis.unlistenImpulse();
		model.xAxis.changeSpeed >> view.updateGroundAnimation;
		view.lostGround();
	}

}