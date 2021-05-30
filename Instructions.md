<h1> Usage instructions </h1>

   1. Obtain Present position of the vessel
   2. Define Destination position
   3. Define starting time
   
   Fill in variables as follows:
   a. Use the information from 1. to fill in PLa and PLo
   b. Use the information from 2. to fill in DLa and DLo
   c. Define the starting time in the format (year, month, day, hour). Only use multiples of 3 for the time. Replace the values in TiSt with the new time
      Example: For the 15th February 2018 14:30, choose: TiSt <- c(2018, 2,15, 15) 
   d. If necessary define an off-limits zone, for example an ice-exclusion zone or an island or land area.
   e. Run all the script

   
# Define Present Latitude an Longitude as well as Destination Latitude and Longitude. Values must be expressed in degrees hence minutes must be divided by 
# 60 and seconds by 3600
PLa = 4+38/60+4/60/60
PLo = 151+56/60+27/60/60
DLo = 174+41.2/60
DLa = -36-48.7/60

# Define the starting time
TiSt <- c(2018, 2,15, 15)

# Define the step size in hours. Numbers other than 3 hours are discouraged.
Rate = 3

OffLimits = c(-10, -8, 150, 162)

