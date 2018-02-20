CS3217 Problem Set 4
==

**Name:** Thenaesh Elango

**Matric No:** A0124772E

**Tutor:** Li Kai

## Tips

1. CS3217's Gitbook is at https://www.gitbook.com/book/cs3217/problem-sets/details. Do visit the Gitbook often, as it contains all things relevant to CS3217. You can also ask questions related to CS3217 there.
2. Take a look at `.gitignore`. It contains rules that ignores the changes in certain files when committing an Xcode project to revision control. (This is taken from https://github.com/github/gitignore/blob/master/Swift.gitignore).
3. A SwiftLint configuration file is provided for you. It is recommended for you to use SwiftLint and follow this configuration. Keep in mind that, ultimately, this tool is only a guideline; some exceptions may be made as long as code quality is not compromised.
    - Unlike previous problem sets, you are creating the Xcode project this time, which means you will need to copy the config into the folder created by Xcode and [configure Xcode](https://github.com/realm/SwiftLint#xcode) yourself if you want to use SwiftLint. 
4. Do not burn out. Have fun!

## Problem 1: Design

## Problem 1.1

![Class Diagram](class-diagram.png)

`ViewController` is where the display link is initialised and thus serves as the heartbeat for the entire system (i.e. calls methods in both the model and view).. Important gameplay elements, such as tracking the projectile state and deciding what to do when it is stopped by a collision with placed bubbles is also performed in methods defined here. This class, as the name implies, serves as the controller.

`BubbleGrid` is the main class for the model, storing the bubbles in the grid as well as the projectile as attributes. It provides useful methods to help the controller make decisions e.g. which grid point is nearest to the current coordinate point, which bubbles of the same colour are in the same connected component as some given bubble, etc. It contains a coordinate system (needed for physics calculations) that is different from the one in the view, and whose aspect ratio is defined directly by the number of rows vs the number of bubbles in each row. The view and model coordinate systems differ only by a scaling factor, so transformation is easy.

`BubbleGridView` is the main class for the view. It contains methods to render the bubble grid and the projectile (which in the view is simply a `BubbleView`), as well as to render with animation if needed. `BubbleGridView` also contains helper methods for translating to and from model and view coordinates. The animated rendering itself is done in the `BubbleView` class (which represents an individual bubble).

`PhysicsEnvironment`, `StaticBody` and `DynamicBody` are protocols which make up the physics engine. An instance of `PhysicsEnvironment` may contain any number of static bodies (which are stationary and are there to be collided with by the dynamic body) and at most one (for now) dynamic body (which can move). When its `simulate` method is called with a time delta from the display link, it can then simulate the motion of the dynamic body in the environment, including collisions with the static bodies. `DynamicBody` is implemented by `ProjectileBubble` in the model, which `StaticBody` is derived into a few specific protocols (`StickyCircle`, `StickyLine`, `ReflectingLine`) that are then implemented by the models representing collidable entities (`FixedBubble`, `Ceiling`, `SideWall`). `PhysicsEnvironment` itself is implemented by `BubbleGrid` as that is the class that contains all the physics objects in the model.

## Problem 1.2

Removing all bubbles of a given colour is a simple matter of adding a method into `BubbleGrid`, alongside the existing connected component tests. All that needs to be done is to iterate across the bubble grid and remove each bubble if the bubble is of the colour specified. This is easy to do because the grid is represented as a 2D array, and is efficient because there aren't many bubbles.

In general, adding more grid-related logic to be executed when the projectile lands on a bubble is done by adding methods to support that logic into `BubbleGrid` and modifying the method `handleProjectileLanding` (currently in the view controller) to use the additional functionality. If `BubbleGrid` starts getting too large, the methods relating to specific and complex game logic (as opposed to simple operations on the grid) can be refactored into a separate protocol that is then extended by `BubbleGrid`.

Adding additional physics logic will require additional protocols in the physics engine to represent the different types of bodies involved, and even possible modification of the `simulate` method in `PhysicsEnvironment`. We consider the case of adding a magnetic bubble object, which is possibly one of the more intrusive changes to the physics engine. The `StaticBody` protocol (which all objects the projectile can interact with derive from) has a `collide` method (usually changing the velocity of the projectile), which the `PhysicsEnvironment`'s `simulate` method calls only if the `DynamicBody` in the environment is colliding with it. For the case of a magnetic bubble, we can add a method `actAtDistance`, which the `simulate` method will always call whether or not the `DynamicBody` is colliding with it. We can supply a default implementation that does nothing. We can then create a `MagneticBody` protocol deriving from `StaticBody` that overrides `actAtDistance` to  affect the acceleration of the projectile in accordance with the inverse square law.

## Problem 2.1

The user inputs the angle for launching the bubble by swiping on the screen in the desired direction. This direction is determined by reading the `velocity` attribute of the corresponding `UIPanGestureRecognizer`, converting it to a vector in the model's coordinate space and normalising it.

## Problem 3: Testing

### Projectile Properties and Movement

**For this section, we start each test by starting a game with an empty grid.**

Action 1: Do nothing.

Expectation 1: There should be a projectile bubble at the bottom centre of the screen.

Action 2: Swipe the screen at a randomly chosen angle (not in a downward direction). Repeat for several arbitrarily chosen angles towards both the right and left of the screen.

Expectation 2: The projectile should travel in the direction of the swipe at a constant velocity.

Action 3: Swipe the screen downwards at an arbitrary angle.

Expectation 3: The projectile should not move and should remain available for firing. Confirm this by swiping upwards and ensuring that the projectile does indeed fire.

Action 4: Fire off a projectile.

Expectation 4: A new projectile should appear for firing as soon as the already-fired one stops moving and snaps to grid. Confirm this by swiping upwards and ensuring that the new projectile does fire.

Action 5: Repeat Action 4 several times and observe the colours of the new projectiles.

Expectation 5: The sequence of colours should appear random (in the layman sense, not in any mathematically precise sense).

### Collisions with Walls and Ceiling

**For this section, we start each test by starting a game with an empty grid.**

Action 1: Swipe a projectile towards the ceiling in a manner such that its trajectory doesn't come into contact with any walls.

Expectation 1: The projectile should stop moving as soon at its boundary touches the ceiling. The projectile should also snap to a nearest possible grid position.

Action 2: Swipe a projectile towards the right wall.

Expectation 2: The projectile should reflect from the right wall the moment its boundary touches the wall. The reflection should be such that the horizontal component of the velocity is negated and the vertical component remains the same.

Action 3: Swipe a projectile towards the left wall.

Expectation 3: The projectile should reflect from the left wall the moment its boundary touches the wall. the reflection should be such that the horizontal component of the velocity is negated and the vertical component remains the same.

Action 4: Swipe a projectile towards either wall in a manner such that the angle between the trajectory and the horizontal is small. Observe the projectile after (WLOG) it reflects off the left wall.

Expectation 4: The projectile should travel to the right wall with the expected trajectory and reflect off the right wall in the expected manner (described in Expectation 2). After a finite sequence of reflections (exactly how many depends on the original angle the projectile was fired at) off alternating walls, the projectile should collide with the ceiling and stop.

### Interaction of Projectile with Bubbles

**For this section, unless otherwise specified, the initial placement of bubbles on the grid is always connected to the ceiling.**

Action 1: Start a new game with some bubbles, where no two adjacent bubbles have the same colour. Fire the projectile into a group of adjacent bubbles.

Expectation 1: The projectile should stop when its boundary comes into contact with any bubble. The projectile should also snap to the nearest possible grid position.

Action 2: Start a new game with a group of two adjacent bubbles of the same colour. Fire projectiles onto other positions on the ceiling to discard them until the current projectile colour matches that of the group initially described. Fire the projectile into the group.

Expectation 2: The projectile should stop when its boundary comes into contact with any bubble. The projectile should also snap to the nearest possible grid position. The cluster of (now) three bubbles should then fade away.

Action 3: Repeat Action 2 for a group of n adjacent bubbles, for various values of n.

Expectation 3: The projectile should stop when its boundary comes into contact with any bubble. The projectile should also snap to the nearest possible grid position. The cluster of (now) n+1 bubbles should then fade away.

Action 4: Start the game with an inverted T-shaped structure, where the neck dangling from the ceiling is of one colour and the base is of another colour. Make sure some ceiling is exposed to the line of fire. Discard projectiles (by firing onto the ceiling) until the (projectile) colour same as that of the neck of the inverted T is obtained. Fire the projectile onto the neck of the T (by reflecting off a wall if necessary).

Expection 4: Upon contact of the projectile with the neck of the T, the neck including the projectile should fade away. The base of the T, left unconnected to the ceiling, then drops off and fades away.

Action 5: Start the game with a group of bubbles connected to the ceiling and a group of bubbles not connected to the ceiling.

Expectation 5: The group of bubbles not connected to the ceiling should immediately drop off and fade away.

Action 6: Start the game with several layers of bubbles, where each layer is of uniform colour, differs in colour from the layers directly above and below it and occupies every grid point on its row. Discard projectiles (at some corner) until the projectile is the same colour as the bottom-most layer. Fire the projectile at the bottom-most layer. Repeat this process for each layer.

Expectation 6: The layers should disappear one by one. Any discarded bubbles stuck onto some corner of layer k should fall off and fade away as soon as layer k disappears (and those bubbles are hence no longer connected to the ceiling).

Action 7: Create a setup similar to Action 6, but where the "layers" are vertical and occupy columns instead of rows (since a column doesn't follow a straight line, each "layer" is jagged). Fire the projectile onto a "layer" that is the same colour as the projectile. Repeat this several times.

Expectation 7: Each "layer", upon being hit by a projectile of the same colour as itself, fades away.
