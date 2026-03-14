There seems to be a specific way of kicking a pumpkin that will crash the game entirely, without Godot throwing an error or anything. 

*Crash kick example*
![[Screenshot From 2025-08-25 10-31-08.png]]

This is the last frame that the game renders to the window. Compared against a normal kick, there doesn't look to be anything out of the ordinary.

*Normal kick example*
![[Screenshot From 2025-08-25 10-32-08.png]]

The crashing kick doesn't seem to even enter the main physics code for the kick, so there seems to be something going wrong with either the code in the parent class of the kick state, Which is just PlayerState checking if the player is not on the floor and applying gravity. 

Searching it up, it seems most likely that the problem is related to freeing an object, and it also might be fixed in 4.5.