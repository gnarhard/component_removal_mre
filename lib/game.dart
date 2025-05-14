import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:removal_issue_mre/pool.dart';

class MyGame extends FlameGame with SingleGameInstance {
  @override
  Future<void> onLoad() async {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();

    camera = CameraComponent.withFixedResolution(
      width: size.x,
      height: size.y,
      world: world,
      viewfinder: Viewfinder()..anchor = Anchor.topLeft,
    );

    add(camera);

    final pool = Pool<PositionComponent>('items')
      ..build(
        10,
        (pool, index) => RectangleComponent.square(
          size: 50,
          paint: Paint()..color = Colors.white,
          children: [ReturningToPoolOnRemoveComponent(pool)],
        )..debugMode = true,
      );

    final startPosition = Vector2(0, size.y / 2);
    final endPosition = Vector2(size.x, size.y / 2);

    world.add(
      TimerComponent(
        period: .2,
        repeat: true,
        tickWhenLoaded: true,
        onTick: () {
          final item = pool.get();
          item.position.setFrom(startPosition);
          item.addAll([
            // Move to edge of screen
            SequenceEffect([
              MoveEffect.to(endPosition, EffectController(duration: 1)),
              RemoveEffect(),
            ]),

            // simulate early removal (like when a weapon collides with a ship)
            TimerComponent(
              period: .4,
              removeOnFinish: true,
              onTick: () => item.removeFromParent(),
            ),
          ]);

          world.add(item);
        },
      ),
    );
  }
}

class ReturningToPoolOnRemoveComponent extends Component
    with ParentIsA<PositionComponent> {
  final Pool<Component> pool;

  ReturningToPoolOnRemoveComponent(this.pool);

  @override
  void onRemove() {
    final oldParent = parent;
    removed.then((_) => pool.release(oldParent));
  }
}
