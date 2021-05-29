# Vendee Globe Optimizer
Optimizer VG 2020/2021

This is a genetic algorithm optimizer that allows the user to plan a path to follow during the Vendee Globe 2020 race. This optimizer allowed me to overtake just over 200000 players in the 2020 VG, though it can fail miserably at times.

This was developed in order to learn more about machine learning, applying different techniques to try and improve upon the solutions given by the http://zezo.org/ simulator. The zeo simulator seems to be based upon a calculated solution, whereas this optimizer is akin to a steepest descent optimizer, which includes randomness via the genetic optimizer algorithm from the rgenoud package.

Below is an animation of the optimizer convergin after 1000 iterations. The red dots are the start and end goal.
![Optimisation](https://github.com/fernandoeblagon/VOR/blob/main/5bfs1k.gif)

_The problem_
The boat is in point A in the ocean, and I want it to get to point B as quickly as possible.

_The data_
For this some information is needed:
   1. The current Lat_0/Lon_0
   2. The goal Lat_1/Lon_1
   3. The wind available for the boat at Lat_0/Lon_0 at the time that the boat is there
   4. The speed of the vessel at the available wind, at the angle at which the vessel will be travelling, with the appropriate sail.

Current and goal are known.

The available wind at the current position can be obtained from the rwind package, which allows downloading a data frame containing the wind predictions for the area where the vessel is in, for an defined time-frame.

The speed of the vessel can be calculated from the polars of the vessel. These can be found at http://toxcct.free.fr/polars/. An example can be found below.
![Polar](https://github.com/fernandoeblagon/VOR/blob/main/Polar.png)

Since the speed of the vessel varies with the wind intensity, angle of incidence and sail configuration, calculating this is not trivial. In order to simplify this, a neural network was trained with the speed, sail and angle inputs and used to calculate the 

