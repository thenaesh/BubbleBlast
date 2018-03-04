CS3217 Problem Set 5
==

**Name:** Thenaesh Elango

**Matric No:** A0124772E

**Tutor:** Li Kai

## Tips

1. CS3217's Gitbook is at https://www.gitbook.com/book/cs3217/problem-sets/details. Do visit the Gitbook often, as it contains all things relevant to CS3217. You can also ask questions related to CS3217 there.
2. Take a look at `.gitignore`. It contains rules that ignores the changes in certain files when committing an Xcode project to revision control. (This is taken from https://github.com/github/gitignore/blob/master/Swift.gitignore).
3. A Swiftlint configuration file is provided for you. It is recommended for you to use Swiftlint and follow this configuration. Keep in mind that, ultimately, this tool is only a guideline; some exceptions may be made as long as code quality is not compromised.
4. Do not burn out. Have fun!

### Rules of Your Game

Win Condition: all bubbles cleared from grid
Lose Condition: bubbles come onto the same row as the cannon

Score (red, green, blue, orange): number of clusters of the respective colour cleared
Score (special): number of special bubbles triggered


### Problem 1: Cannon Direction

When the user does a long press at a point, the projectile is fired from the cannon in the direction of the point.

(I was going to make the cannon face that direction upon tap at the same point, but I couldn't slice the spritesheet without bugs. So all I have now is the cannon base.)

### Problem 2: Upcoming Bubbles

The upcoming bubble is chosen uniformly at random from the 4 launchable bubbles. This provides decent game mechanics in general, since the user will ultimately get the bubble he needs. This bubble is displayed very clearly upon the cannon base.

Other approaches were considered, such as increasing the probability of getting a bubble if there are already a lot of that bubble on the grid or if there is a cluster of that bubble nearby. However, these approaches were not implemented as their effect on the game balance (i.e. if they make the game too easy or difficult) was difficult to determine without prohibitively extensive playtesting.

### Problem 3: Integration

The palette mode and actual game mode are implemented as separate view controllers, so switching from the palette to the actual game is a simple matter of performing a segue. Before the segue (in `prepareForSegue`), the designed level is first autosaved into a file called "PreviousLevel" and the actual game's view controller is set to load that file after it loads.

Benefits:

* The game mode view controller (`GameViewController`) always loads the level from a file, and all file-related errors are handled elsewhere. This allows `GameViewController` to just focus on the game and not any extraneous things.
* The last created level is always implicitly saved, and can be reloaded later.

Drawbacks:

* The notion of saving to file (along with potential errors) is introduced in a place where it is not necessarily needed.
* The name "PreviousFile" can no longer be used for custom save files (although I have no idea why anyone would want to use that name).

An alternative approach is passing the designed grid model directly to the game mode view controller through `prepareForSegue`, which is easy especially since `GameViewController` and `PaletteViewController` share a base class called `GridViewController` that encapsulates the grid model. This has the benefit of not requiring a file, but the designed level is lost immediately if not saved.

### Problem 4.4

The special effects are triggered on a bubble by calling a specific function (`performSpecialEffectsOnSelf`), which checks to see what type of special bubble is triggered and calling the appropriate action (`performLightningEffect`, `performBombEffect` or `performStarEffect`). All of these actions destroy the normal bubbles but not the special bubbles in their area of effect. The special bubbles are instead recorded and returned to `performSpecialEffectsOnSelf`, which then iterates across the list of special bubbles and recursively calls itself on each of them in turn. Chaining of special bubbles is thus supported by this recursive call.

Benefits:

* Efficient, as the grid is not traversed repeatedly
* Easy to implement

Drawbacks:

* Somewhat returning special bubbles from the action functions is somewhat unwieldy, since it is a bit strange for a function meant to destroy bubbles (the special effects are destructive) to return bubbles. I mitigated this by taking an array to fill as a properly named `inout` parameter instead of just returning the array of special bubbles.

An alternative approach could be maintaining a stack of triggered special bubbles and doing something that resembles a DFS where a special bubble is popped, the action is performed and any new special bubbles triggered are placed on the stack. An iterative algorithm runs until the stack is emptied. This works just as well and the two approaches are equivalent in complexity (though order of destruction may vary).

(Stack space used by the recursion and stack overflow is a non-issue since the grid is very small.)

### Problem 7: Class Diagram

![Class Diagram](class-diagram.png)

#### Model

`BubbleGrid` is the main class for the model, storing the bubbles in the grid as well as the projectile as attributes. It provides useful methods to help the controller make decisions e.g. which grid point is nearest to the current coordinate point, which bubbles of the same colour are in the same connected component as some given bubble, etc. It contains a coordinate system (needed for physics calculations) that is different from the one in the view, and whose aspect ratio is defined directly by the number of rows vs the number of bubbles in each row. The view and model coordinate systems differ only by a scaling factor, so transformation is easy.

`PhysicsEnvironment`, `StaticBody` and `DynamicBody` are protocols which make up the physics engine. An instance of `PhysicsEnvironment` may contain any number of static bodies (which are stationary and are there to be collided with by the dynamic body) and at most one (for now) dynamic body (which can move). When its `simulate` method is called with a time delta from the display link, it can then simulate the motion of the dynamic body in the environment, including collisions with the static bodies. `DynamicBody` is implemented by `ProjectileBubble` in the model, which `StaticBody` is derived into a few specific protocols (`StickyCircle`, `StickyLine`, `ReflectingLine`) that are then implemented by the models representing collidable entities (`FixedBubble`, `Ceiling`, `SideWall`). `PhysicsEnvironment` itself is implemented by `BubbleGrid` as that is the class that contains all the physics objects in the model. `StaticBody` optionally can have a mass which is used to determine gravitational acceleration (this is used to implement magnetic bubbles in the game).

#### View

`BubbleGridView` contains methods to render the bubble grid and the projectile (which in the view is simply a `BubbleView`), as well as to render with animation if needed. `BubbleGridView` also contains helper methods for translating to and from model and view coordinates. The animated rendering itself is done in the `BubbleView` class (which represents an individual bubble).

`PaletteView` renders the palette and is used for the level designer stage. In particular, it is used in `PaletteViewController`.

#### Controller

The controllers comprise the view controllers, each of which represents both a single screen and a single phase of the game.

`MenuViewController`: Handles the first segment of the game, where the user decides whether to design a level or launch an existing level. If the player chooses to launch an existing level, it segues to `LevelSelectionViewController`, otherwise it segues to `PaletteViewController`.

`LevelSelectionViewController`: Presents the user all saved levels in an encapsulated `UICollectionView`. When the user taps on a level, it segues to `GameViewController` to play the selected level. In addition to the saved levels created by the user, there are 3 prepackaged saved levels ("Cables", "Magnets", "Stripes") which are loaded from the assets bundle and presented together with the other saved levels.

`PaletteViewController`: Handles the level design phase of the game. After the level is designed and "START" is pressed, it segues to `GameViewController` to begin the actual game.

`GameViewController`: Handles the game itself. It contains methods to fire a projectile, remove bubble clusters once hit, trigger special bubbles and keep track of score. It checks for endgame conditions (empty grid or filled past a certain row) and segues to `EndGameViewController`.

`EndGameViewController`: Shows the player whether they won or lost, along with their score. Allows user to choose to play again, at which point it segues back to `MenuViewController`.

### Problem 8: Testing

Your answer here


### Problem 9: The Bells & Whistles

Your answer here


### Problem 10: Final Reflection

Your answer here
