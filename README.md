# Sailing offshore Optimizer
Optimizer VG 2020/2021

This is an optimizer that allows the user to plan a path to follow during a Sailing Offshore race. This optimizer allowed me to overtake just over 200 000 players in the 2020 VG, though it can fail miserably at times.

What it does is offer an alternative solution to the maximum slope which optimizes the course from the position of the vessel but that can miss local maxima due to its starting conditions.

This was developed in order to learn more about machine learning, applying different techniques to try and improve upon the solutions given by the http://zezo.org/ simulator. The zezo simulator seems to be based upon a steepest descent optimizer, whereas this optimizer is akin includes randomness via the genetic optimizer algorithm from the rgenoud package.

From the Rgenoud package:
> Genoud is a function that combines evolutionary search algorithms with derivative-based (Newton
> or quasi-Newton) methods to solve difficult optimization problems. Genoud may also be used for
> optimization problems for which derivatives do not exist. Genoud, via the cluster option, supports
> the use of multiple computers, CPUs or cores to perform parallel computations.


__The problem__

The boat is in point A in the ocean, and I want it to get to point B as quickly as possible. Should I go on a straigth line or tack all the way from A to B?
![Position](https://github.com/fernandoeblagon/Vendee-Globe/blob/main/Position.png)

__The data__

To solve the problem some information is needed:
   1. The starting Lat_0/Lon_0
   2. The goal Lat_1/Lon_1
   3. The wind available for the boat at Lat_0/Lon_0 at the time that the boat is there
   4. The speed of the vessel at the available wind, at the angle at which the vessel will be travelling, with the appropriate sail.

Current and goal Lat/Lon are given by the game if your playing Virtual Regatta or else you should know where your starting point is.

The available wind at the current position can be obtained from the rwind package, which allows downloading a data frame containing the wind predictions from the NOOA website for the area where the vessel is in, for a defined date/time. The wind predictions are obtained on this optimizer in 3-hour intervals. Each record is composed of the Lat/Lon+Time, speed vectors and wind speed and angle as follows:
![Wind](https://github.com/fernandoeblagon/Vendee-Globe/blob/main/Wind.png)

The speed of the vessel can be calculated from the polars of the vessel. These can be found at http://toxcct.free.fr/polars/. An example can be found below.
![Polar](https://github.com/fernandoeblagon/VOR/blob/main/Polar.png)

Since the speed of the vessel varies with the wind intensity, angle of incidence and chosen sail, calculating the velocity of the boat is not trivial. In order to solve this problem, a neural network (NN) was trained with the data from the polars using true wind speed and true wind angle as inputs and speed as ouput for each sail. The NN can be used to calculate the velocity of the boat. An example neural network for the 2020 IMOCA60 jib is shown below.
![NN](https://github.com/fernandoeblagon/VOR/blob/main/nnVorJib.png)

__Steps__

In order to go from A to B, we need to take 3-hour steps. On each step we calculate the new position of the vessel after a 3-hour interval. The new position is taken as a starting point for the next step.

Typically 12-18 steps are taken per simulation, covering up to 144 hours. A single step is described below.
![Step](https://github.com/fernandoeblagon/VOR/blob/main/Step.png)

__The full journey__

By calculating all of the steps, using the end point of the previous step as the starting point of the next one, we can calculate the distance covered by the boat sailing on a straight line from A to B.
![FullJourney](https://github.com/fernandoeblagon/VOR/blob/main/FullJourney.png)

__The easiest solution__

Going from A to B in a straight line is a straightforward thing. The angle is a constant defined by the starting and end points. Nevertheless, since the speed of the boat changes with the wind angle and wind intensity, but also with the direction of the boat against the wind, very seldom going from A to B on a straight line will give us the fastest time. 

Hence, the optimization problem, what is the best angle for the vessel to travel at each 3-hour step in order to get as fast as possible from A to B?

__Optimized solution__

We start with the straight line solution and iterate through solutions whilst setting the optimizer with a goal to minimize the distance between the last step and point B, our goal. 

It's imprtant to point out that the optimizer will try to minimize the distance between the last point in the simulation and the goal. If the distance is too short, the optimizer will fail to optimize anything and could even find a longer route that would deliver us on the last point at the set goal, instead of getting there faster.

Below is an animation of the optimizer converging after 1000 iterations. The red dots are the start and end points.
![Optimisation](https://github.com/fernandoeblagon/VOR/blob/main/5bfs1k.gif)

The output of the optimiser is a table with the optimized bearings and a map showing the straigth line solution versus the optimized one. An example is shown below. The map may not look the same anymore since this is from 2018 using the google map package.
![Example](https://github.com/fernandoeblagon/VOR/blob/main/Example.png)

__Files__

The .csv files are the polars, downloaded from the http://toxcct.free.fr/polars/ website.

NN1 to NN6 are the scripts that calculate the neural network for each sail and store them as nn objects.

OptimVor.R is the main script that downloads the wind data, iterates the steps, runs the optimizer and prints the table and plot with the optimized solution.

__Usage instructions__

The usage instructions can be found in https://github.com/fernandoeblagon/Vendee-Globe/blob/main/Instructions.md
