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

## Rules of Your Game

Win Condition: all bubbles cleared from grid
Lose Condition: bubbles come onto the same row as the cannon

Score (red, green, blue, orange): number of clusters of the respective colour cleared
Score (special): number of special bubbles triggered


## Problem 1: Cannon Direction

When the user does a long press at a point, the projectile is fired from the cannon in the direction of the point.

(I was going to make the cannon face that direction upon tap at the same point, but I couldn't slice the spritesheet without bugs. So all I have now is the cannon base.)

## Problem 2: Upcoming Bubbles

The upcoming bubble is chosen uniformly at random from the 4 launchable bubbles. This provides decent game mechanics in general, since the user will ultimately get the bubble he needs. This bubble is displayed very clearly upon the cannon base.

Other approaches were considered, such as increasing the probability of getting a bubble if there are already a lot of that bubble on the grid or if there is a cluster of that bubble nearby. However, these approaches were not implemented as their effect on the game balance (i.e. if they make the game too easy or difficult) was difficult to determine without prohibitively extensive playtesting.

## Problem 3: Integration

The palette mode and actual game mode are implemented as separate view controllers, so switching from the palette to the actual game is a simple matter of performing a segue. Before the segue (in `prepareForSegue`), the designed level is first autosaved into a file called "PreviousLevel" and the actual game's view controller is set to load that file after it loads.

Benefits:

* The game mode view controller (`GameViewController`) always loads the level from a file, and all file-related errors are handled elsewhere. This allows `GameViewController` to just focus on the game and not any extraneous things.
* The last created level is always implicitly saved, and can be reloaded later.

Drawbacks:

* The notion of saving to file (along with potential errors) is introduced in a place where it is not necessarily needed.
* The name "PreviousFile" can no longer be used for custom save files (although I have no idea why anyone would want to use that name).

An alternative approach is passing the designed grid model directly to the game mode view controller through `prepareForSegue`, which is easy especially since `GameViewController` and `PaletteViewController` share a base class called `GridViewController` that encapsulates the grid model. This has the benefit of not requiring a file, but the designed level is lost immediately if not saved.

## Problem 4.4

The special effects are triggered on a bubble by calling a specific function (`performSpecialEffectsOnSelf`), which checks to see what type of special bubble is triggered and calling the appropriate action (`performLightningEffect`, `performBombEffect` or `performStarEffect`). All of these actions destroy the normal bubbles but not the special bubbles in their area of effect. The special bubbles are instead recorded and returned to `performSpecialEffectsOnSelf`, which then iterates across the list of special bubbles and recursively calls itself on each of them in turn. Chaining of special bubbles is thus supported by this recursive call.

Benefits:

* Efficient, as the grid is not traversed repeatedly
* Easy to implement

Drawbacks:

* Somewhat returning special bubbles from the action functions is somewhat unwieldy, since it is a bit strange for a function meant to destroy bubbles (the special effects are destructive) to return bubbles. I mitigated this by taking an array to fill as a properly named `inout` parameter instead of just returning the array of special bubbles.

An alternative approach could be maintaining a stack of triggered special bubbles and doing something that resembles a DFS where a special bubble is popped, the action is performed and any new special bubbles triggered are placed on the stack. An iterative algorithm runs until the stack is emptied. This works just as well and the two approaches are equivalent in complexity (though order of destruction may vary).

(Stack space used by the recursion and stack overflow is a non-issue since the grid is very small.)

## Problem 7: Class Diagram

![Class Diagram](class-diagram.png)

### Model

`BubbleGrid` is the main class for the model, storing the bubbles in the grid as well as the projectile as attributes. It provides useful methods to help the controller make decisions e.g. which grid point is nearest to the current coordinate point, which bubbles of the same colour are in the same connected component as some given bubble, etc. It contains a coordinate system (needed for physics calculations) that is different from the one in the view, and whose aspect ratio is defined directly by the number of rows vs the number of bubbles in each row. The view and model coordinate systems differ only by a scaling factor, so transformation is easy.

`PhysicsEnvironment`, `StaticBody` and `DynamicBody` are protocols which make up the physics engine. An instance of `PhysicsEnvironment` may contain any number of static bodies (which are stationary and are there to be collided with by the dynamic body) and at most one (for now) dynamic body (which can move). When its `simulate` method is called with a time delta from the display link, it can then simulate the motion of the dynamic body in the environment, including collisions with the static bodies. `DynamicBody` is implemented by `ProjectileBubble` in the model, which `StaticBody` is derived into a few specific protocols (`StickyCircle`, `StickyLine`, `ReflectingLine`) that are then implemented by the models representing collidable entities (`FixedBubble`, `Ceiling`, `SideWall`). `PhysicsEnvironment` itself is implemented by `BubbleGrid` as that is the class that contains all the physics objects in the model. `StaticBody` optionally can have a mass which is used to determine gravitational acceleration (this is used to implement magnetic bubbles in the game).

### View

`BubbleGridView` contains methods to render the bubble grid and the projectile (which in the view is simply a `BubbleView`), as well as to render with animation if needed. `BubbleGridView` also contains helper methods for translating to and from model and view coordinates. The animated rendering itself is done in the `BubbleView` class (which represents an individual bubble).

`PaletteView` renders the palette and is used for the level designer stage. In particular, it is used in `PaletteViewController`.

### Controller

The controllers comprise the view controllers, each of which represents both a single screen and a single phase of the game.

`MenuViewController`: Handles the first segment of the game, where the user decides whether to design a level or launch an existing level. If the player chooses to launch an existing level, it segues to `LevelSelectionViewController`, otherwise it segues to `PaletteViewController`.

`LevelSelectionViewController`: Presents the user all saved levels in an encapsulated `UICollectionView`. When the user taps on a level, it segues to `GameViewController` to play the selected level. In addition to the saved levels created by the user, there are 3 prepackaged saved levels ("Cables", "Magnets", "Stripes") which are loaded from the assets bundle and presented together with the other saved levels.

`PaletteViewController`: Handles the level design phase of the game. After the level is designed and "START" is pressed, it segues to `GameViewController` to begin the actual game.

`GameViewController`: Handles the game itself. It contains methods to fire a projectile, remove bubble clusters once hit, trigger special bubbles and keep track of score. It checks for endgame conditions (empty grid or filled past a certain row) and segues to `EndGameViewController`.

`EndGameViewController`: Shows the player whether they won or lost, along with their score. Allows user to choose to play again, at which point it segues back to `MenuViewController`.

## Problem 8: Testing

### Black-Box Tests

####  Painting of bubbles

This part is from PS3.

* Tap handler behaviour (paints tapped bubble with selected colout, cycles through colours)
    * Select a non-erase bubble from palette and tap the grid at a few points. Only those few points should change to the chosen colour.
    * Select a non-erase bubble from palette and tap a filled point multiple times. The colours of that point should cycle (red -> green -> blue -> orange -> red).
    * Select the erase bubble from palette and tap the grid at an empty point several times. Nothing should happen.
    * Select the erase bubble from palette and tap the grid at a filled point. The filled bubble should become empty.
* Pan handler behaviour (paints bubbles in trajectory with selected colour, no cycling behaviour)
    * Select a non-erase bubble from palette and drag on the grid across several empty bubbles. The empty bubbles along the trajectory should become filled with the selected bubble colour.
    * Select a non-erase bubble from palette and drag on the grid across a set of bubbles that include empty, filled with chosen colour and filled with other colour. All bubbles along the trajectory should become of the chosen colour, regardless of their original colour or lack thereof.
    * Select the erase bubble from palette and drag on the grid across a set of bubbles that include empty and filled. All bubbles along the drag trajectory should be erased.
* Long press handler behaviour (erases bubbles in trajectory)
    * Select a non-erase bubble from palette, tap on the grid and hold for a while, then drag across a set of bubbles that include empty, filled with chosed colour and filled with other colour. All bubbles along the trajectory should be erased.
    * Select the erase bubble from palette, tap on the grid and hold for a while, then drag across a set of bubbles that include empty and filled. All bubbles along the trajectory should be erased.
    * Select a non-erase bubble and tap at random points both on and off the grid. Only the bubbles on the grid should get filled; the parts below the bubble grid should not get filled with bubbles. Repeat this with dragging rather than tapping. Same results should apply.

#### Selection from palette

This part is from PS3.

The registering of a bubble selection in the palette is already thoroughly tested above, so we don't test it again.

* Bubble selection in palette (highlights selected colour)
    * Select a bubble from palette and ensure that it is highlighted with all others grayed out
* Reset (clears all bubbles in grid)
    * Paint a random pattern. Tap on the reset button. The grid should be cleared.
* Save (persists grid pattern to file, available even after restart) and load (reads pattern from file and applies it back to grid)
    * Paint a recognisable pattern on the grid. Tap on save and enter a filename. Reset the grid and paint some other random pattern. Then tap on load and enter the same filename. The grid should display the original pattern that was saved. Quit the app, restart it and load the same file again. The same pattern should appear.
* Load (gives warning if file not found)
    * Tap on load and enter a filename that was never used for saving. An alert should pop up mentioning an error loading the file.
* Save (overwrites existing files)
    * Paint a recognisable pattern on the grid. Tap on save and enter a filename. Paint another recognisable pattern on the grid and save with the same filename. Load the filename. The second pattern should appear and not the first.


#### Projectile Properties and Movement

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

#### Collisions with Walls and Ceiling

**For this section, we start each test by starting a game with an empty grid.**

Action 1: Swipe a projectile towards the ceiling in a manner such that its trajectory doesn't come into contact with any walls.

Expectation 1: The projectile should stop moving as soon at its boundary touches the ceiling. The projectile should also snap to a nearest possible grid position.

Action 2: Swipe a projectile towards the right wall.

Expectation 2: The projectile should reflect from the right wall the moment its boundary touches the wall. The reflection should be such that the horizontal component of the velocity is negated and the vertical component remains the same.

Action 3: Swipe a projectile towards the left wall.

Expectation 3: The projectile should reflect from the left wall the moment its boundary touches the wall. the reflection should be such that the horizontal component of the velocity is negated and the vertical component remains the same.

Action 4: Swipe a projectile towards either wall in a manner such that the angle between the trajectory and the horizontal is small. Observe the projectile after (WLOG) it reflects off the left wall.

Expectation 4: The projectile should travel to the right wall with the expected trajectory and reflect off the right wall in the expected manner (described in Expectation 2). After a finite sequence of reflections (exactly how many depends on the original angle the projectile was fired at) off alternating walls, the projectile should collide with the ceiling and stop.

#### Interaction of Projectile with Bubbles

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

#### Special Bubbles

Action 1: Design a new level with a magnetic bubble placed on the top left. Launch the game and fire the projectile straight up.

Expectation 1: The projectile should accelerate towards the magnetic bubble, with acceleration increasing as it gets closer to the bubble.

Action 2: Design a new level with a magnetic bubble placed on the top left and another on the top right. Launch the game and fire the projectile straight up.

Expectation 2: The bubble should travel mostly straight up, though it may slightly diverge if the bubble is fired slightly to the right or left.

Action 3: Load the "Cables" prepackaged level and clear out all the normal bubbles in the inner "triangle" below the lightning bubble. Then shoot a projectile onto the lightning bubble.

Expectation 3: This tests the behaviour of both the lightning and indestructible bubbles. When the inner "triangle" is cleared out, the single indestructible bubble inside the triangle is no longer connected to the ceiling and should drop off. When the lightning bubble is hit, the normal bubbles on the same row (but not the indestructible bubbles) are destroyed. The whole unconnected chunk then drops off.

Action 4: Load the "Magnets" prepackaged level and fire the projectile at one of the star bubbles at the side (the top one is intentionally difficult to hit with all the magnets and lighning bubbles above it).

Expectation 4: From the top row (the only row with normal bubbles), all bubbles the same colour as the projectile fired should disappear.

Action 5: Design a new level with a bomb bubble surrounded by two layers of both normal bubbles and indestructible bubbles (attach everything to the ceiling). Fire a projectile at the bomb bubble.

Expectation 5: The bomb bubble should explode and all the normal bubbles directly touching it should explode as well. The indestructible bubbles directly touching it as well as all bubbles one layer away should not explode.

Action 6: Design a new level with 5 rows where each row has a bomb bubble and a lightning bubble, where the lightning bubble of row k is directly below the bomb bubble of row k+1. There should be no other contact between the special bubbles; in particular, there should never be more than 2 special (we don't consider the indestructible bubble to be special here) bubbles in a cluster anywhere. Make all the other bubbles in the first row normal bubbles, while all other bubbles in the other row are indestructible bubbles. Fire a projectile at the exposed special bubble in row 5.

Expectation 6: The game should end immediately and segue to the win screen.


#### Level Selection Screen

Action 1: Create a lot of levels (e.g. 20) in the level editor. Restart the game and go to the level selection screen.

Expectation 1: The levels should all be there, together with the 3 prepackaged levels ("Cables", "Magnets", "Stripes") and any previously created levels. The last level played by clicking "START" from the level editor should be present as "Previous Level"). If the list is too long to fit into the screen, it should be able to scroll in the natural iOS way.

Action 2: Go to the level selection screen and tap on a level.

Expectation 2: A new game should start with that level.

### Glass-Box Tests

#### Game Files

Action 1: Attempt to save or load a file with non-alphanumeric characters in the palette save/load prompts.

Expectation 1: The guard clause checking for `isFileNameLegal` should be triggered and the message stating this should be presented as a dialog box.

Action 2: Run the game in the emulator and go to the game save directory (can be found by printing `FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first`) in the terminal. Delete all files. Start the game and `ls` the directory. Go to the level load screen and `ls` the directory again.

Expectation 2: On the first `ls`, the directory should still be empty. On the second `ls`, the files `Cables`, `Magnets` and `Stripes` should be found in the directory, having been created from the asset bundle during the loading of `LevelSelectionViewController`.

#### Audio

Action 1: Launch the game, let the starting music play for a while, then load a level from the level selection screen while the music is playing halfway. Complete the game and click "Play Again" on the endgame screen.

Expectation 1: The music should change to a new tune when the level is loaded. Upon clicking "Play Again", the starting menu screen should be loaded and the starting music should play from the beginning again, not from where it left off.

#### End Game States

Action 1: Create a game (without special bubbles)  such that it is easy to clear the entire level (perhaps a single row of red bubbles, or a few large monochromatic clusters). Then fire enough projectiles until the level is cleared. Each time a cluster of bubbles is cleared, make a note of it and record the colour.

Expectation 1: Once the last bubble has been eliminated from the grid, the game should segue to a screen declaring victory. The number of each type of cluster cleared is listed and should match the tally, as the score for a given colour is incremented every time a cluster of that colour is cleared. The score for special bubble triggered (marked "special" at the bottom of the screen) should be 0, as no special bubbles were triggered.

Action 2: Create a new level (without special bubbles) and play in the stupidest possible manner, such that the bubbles keep piling up towards the bottom of the screen with very few clusters being cleared. Note the clusters cleared, as in Action 1.

Expectation 2: When any bubble snaps into the row directly above the projectile launcher, the game should segue to a screen declaring failure. The scores should be as before in Expectation 1.

Action 3: Load the "Magnets" prepackaged level and hit the 4 side star bubbles in a manner such that the game is won (one colour of projectile to each).

Expectation 3: The game should end and segue to the win screen, where the "special" score at the bottom is exactly 4. This is because the special score is incremented each time a special bubble is triggered.

Action 4: Design a new level with 2 rows: top row with all red bubbles except 1 lightning bubble, next row with all indestructable bubbles except 1 bomb bubble placed touching the top row's lightning bubble and 1 lightning bubbles placed elsewhere in the row not touching any other special bubble. Play the level and hit the lower row's lightning bubble.

Expectation 4: The game should end in a victory due to the special bubble cascade and the top row's lightning bubble destroying the entire top row. The special score should be 3, since the special score is incremented in each recursive call in `performSpecialEffectOnSelf`.

## Problem 9: The Bells & Whistles

### Bells

* Music for game menu, level selection screen and level design screen (one of the soundtracks from Doki Doki Literature Club, a visual horror novel by Dan Salvato)
* Music while playing game (which should sound familiar to every Singaporean male)
* Sound effects when launching bubble, clearing a cluster and triggering special bubbles (some sound effects from Super Mario)

A full audio subsystem was implemented as a singleton to handle music at all parts of the game. It is located at `Audio.swift`.

### Whistles

* Level selector screen that allows not just convenient selecting of prepackaged levels but all saved levels from a scrolling menu
    * Added by reading out the contents of the save directory and displaying it with a `UICollectionView`
* Win/lose conditions and appropriate end game screens
    * Win test: check if the top row is clear
    * Lose test: check if the row just above the launcher has any bubbles
* Score calculation and reporting on end game screens, split into each type of bubble cluster and special bubble triggers
    * Counters added to `GameViewController` and incremented at appropriate locations in the cluster clearing code and special bubble triggering code
* "Play Again" button on the end game screens to enable user to go back to the main menu
    * Just a segue back to the menu screen

## Problem 10: Final Reflection

The original idea of MVC as applied to this game was that models reflected the game state, views presented the model on the screen and controllers read input and updated the model. The model contained the bubble class, the bubble colour enum and the bubble grid class. There were views for the bubble grid, the palette and several subviews of the grid like the cannon and projectile. The game engine and level handling code was implemented in the view controllers.

For the model, I initially started out with bubbles only having a grid position and only the view bubble having a coordinate. However I had to change this in order to introduce a physics engine in PS4, since physics required coordinates to operate. I did not use the view's coordinates, and instead introduced a separate coordinate system ([0, 1] * [0, aspectRatio]). The aspect ratio depended on the number of rows and columns allowed, and this was fixed as a constant in a global file.

I initially did not know how to use segues properly and ended up with one massive view controller containing both palette-handling code and actual game code in PS4. This was two controllers combined into one: the game engine and the level designer. After figuring out how to use segues for PS5, I split each stage of the game up into its own view controller. The specific game mechanics was then contained in `GameViewController`.

I decided not to have a separate GameEngine class since this game was not very abstractable, and contains just game mechanics and physics. A game engine is generally supposed to contain graphics systems (with rendering techniques), audio systems, physics systems, but these are not very applicable here (as compared to some 3D game). The one thing that was indeed abstractable was the physics engine, which I designed as a set of protocols to be concretely instantiated by the game classes.

On hindsight, however, perhaps I should have created a game engine representing the notion of a "bubble game", but just not containing any specific mechanics. I could have placed rendering techniques (like which bubbles to rerender) in the engine, and the "Collidables" in the model there as well. This realisation came after realising that my model and view classes were growing out of control with lots of helper methods lying around for various cases.

Or perhaps, a strict adherence to MVC is a problem for this particular case. I felt myself fighting the confines of MVC for very little gain (even on hindsight). There are already established patterns for games, where there is something vaguely resembling MVC but not entirely, with a game loop rendering a scene graph. I could have tried to do something like that instead, and would have had I known about the display link back in PS3.
