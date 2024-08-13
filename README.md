# Godot-Block-Puzzle

A quick block puzzle game created in the Godot game engine. Check 'releases' to download and play on Windows or Android, or play on [itch.io](https://blakeles.itch.io/block-puzzle-godot)

This is my first project using Godot and was finished within a week of starting it. I have learnt a lot about the engine and GDScript during the development of this game.
I will further my knowledge by creating a few more similar, small games in the coming months.

After listening to some feedback given by friends who tried the game, I fixed the biggest issue which was that pieces were too hard to pick up. This was caused by the collisionpolygon2d being too small on the blocks, I fixed this by increasing the size of the collider whilst the block is part of a piece and then reducing it when the block has been placed on the board. Reducing the size of the collider is necessary to avoid blocks being placed in places they shouldn't be. I also fixed an issue that displayed pieces that were being dragged underneath the other pieces that were not being dragged.

Font used: Miss-16-Bit
