# Cellular AutoBata

Cellular AutoBata is an auto-battler style game loosely based on the idea of cellular automata.

The core idea is that you define a genome that consists of multiple cell types. Each cell type has
a set of genes.  These genes determine the cell's capabilities and behavers. The more powerful the gene, the more the
gene costs.  The total cost of all the genes in a cell type determines the cost of creating a cell of that type. The
total cost of all the cell types in a genome indicates the strength of the genome.

Each cell's state consists of two primary values: life and energy. A cell can have a maximum amount of life equal to the
cell's cost. When a cell is created, it has maximum life. One point of life is removed from the cell on each step of the
simulation. If a cell has zero (or less) life at the end of a simulation step, it dies.

A cell uses energy to perform actions, and replenish it's life. A cell has zero energy when it is created. A cell can
have a gene that generates energy (i.e. photosynthesis) or it can have a gene that allows it to consume a food source
which can be found in the environment. Cells can also have genes that allow them to send energy to neighboring cells. At
the end of a simulation step, after performing actions, any energy left will be used to restore the life lost at the start
of the step, or any damage done to the cell during the step.

The actions a cell can perform using it's energy are also determined by it's genes. These include emitting toxins or
performing physical attacks to damage near by enemy cells. These attacks take life from the target cell. A cell may also
have genes that provide resistance to different damage types. 

A cell with the right gene can also use it's energy to produce a new cell of the same or different cell type. The type
of cell produced, and the grid location in which it is produced, are determined by the gene's "growth plan". This is a
simple program, or set of instructions, that allow the cell to sense it's environment and determine what kind of cell
to produce and where to produce it. The sensory inputs available to a cell, also determined by the cell's genes, include
the direction and density of enemy cells and the content of the environment such as food or boundaries.

The game is structured around a series of levels, each posing a different challenge to the player. Players must choose
the right combination of genes, cell types, and growth plans to defeat enemy genomes, to over come environmental
constraints, or to achieve level targets such as occupying specific grid locations.

## Current Status

A "level editor" and "simulation viewer" are implemented, but there are no pre-built game levels. Only a limited set of
genes have been implemented. There is not yet a way to implement a growth plan, but the internals are there. This is the
current goal, and once finished the "core" of the game will be more or less complete. But a lot more work will be needed
to implement various genes and grow plan sensory inputs.

Only placeholder visual cell appearances are present. Picture something that feels much more "biological". This will
include animated effects showing cell actions (such as performing attacks).

There is currently no sound effects or music.