# This example demonstrates the tolerancing of a double pass system using ZPL macros with 
# OpticStudio.
# Before running the code
# Change the ext of this file from .txt to .zpl if this is not already the case.
# Copy this file to a Zemax/Macros folder.
# Insure you have copied the "double_pass_tolerancing.TOL" file to Zemax/Tolerance
# Open a fresh instance of Zemax OpticStudio (or File > New) otherwise this 
# will copy data to your existing Zemax LDE.
# Goto programming tab of OpticStudio and click Edit/run (under ZPL macros section). 
# Choose the filename and execute.


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# In a double pass light passes through an optical system twice so tolerancing for
# for forward and return paths can not be independent.
# We have used a pre-optimized two-lens monochromat from the lens catalog
# But this example can be modified for any other optical system which uses a double pass
# as the goal here is to explain how to insert coordinate breaks and build tolerance 
# data editor manually correctly to account for the double passing of the light
# This code generates an LDE/TDE file which can then be subjected to tolerancing (see the attached
# PDF for details)

# Written by Tarun Kumar, 2024

REM #1. Setting up System Explorer
###########################################################

# Setting up the lens unit to mm
SETSYSTEMPROPERTY 30, 0
# Setting up the aperture type to Float by stop size
SETSYSTEMPROPERTY 10, 3
# Setting up Afocal Image Space
SETSYSTEMPROPERTY 18, 1
# Setting up Global Coordinate Reference Surface to 1
SETSYSTEMPROPERTY 18, 1
# Setting up the field type to angle 
SETSYSTEMPROPERTY 100, 0
# Setting up the field normalization to radial 
SETSYSTEMPROPERTY 110, 0
# Setting up the number of field to 1 
SETSYSTEMPROPERTY 101, 1
# setting up the field # 1 value x=0, y= 0 degree
SETSYSTEMPROPERTY 102, 1, 0
SETSYSTEMPROPERTY 103, 1, 0
# Setting up the number of wavelengths to 1
SETSYSTEMPROPERTY 201, 1
# Setting the value of wavelength in um
SETSYSTEMPROPERTY 202, 1, 0.546
# Setting up the primary wavelength index # to 1
SETSYSTEMPROPERTY 200, 1
# Load SCHOTT and OHARA catalog
SETSYSTEMPROPERTY 23, "SCHOTT OHARA"


IF (UNIT() == 0) THEN PRINT "Lens units are mm"

# print integer i.e. no data after decimal places
FORMAT 1.0
PRINT "Number of wavelengths: ", NWAV()
# 3 digits before and after decimals
FORMAT 3.3
PRINT " Primary wavelength: ", WAVL(PWAV()), " micrometres."

FORMAT 1.0
PRINT "Number of Fields: ", NFLD()
FORMAT 3.3
PRINT "Y-Fields value: ", FLDY(1)

#2. Setting Lens Data Editor
###############################################
# Insert 23 more surfaces before the image plane i.e. surface 2

FOR i, 1, 23,1
INSERT 2 
NEXT

# setting up the OBJECT
# object type to be STANDARD
SETSURFACEPROPERTY 0, "STANDARD" 
#Write the comments
SETSURFACEPROPERTY 0, COMM, "object" 
#Defining radius (i.e. curvature) = inf of the surface
SETSURFACEPROPERTY 0, CURV, 0 

# setting up the 1st surface i.e. stop
SETSURFACEPROPERTY 1, TYPE, "STANDARD" 
#Write the comments
SETSURFACEPROPERTY 1, COMM, "STOP" 
#Set the aperture type of stop to be circular
SETSURFACEPROPERTY 1, ATYP, 1
#Min aperture size
SETSURFACEPROPERTY 1, APP1, 0
#Max aperture size
SETSURFACEPROPERTY 1, APP2, 7
#Defining radius (i.e. curvature) = inf of the surface
SETSURFACEPROPERTY 1, CURV, 0 
#Setting thickness = 30 mm
SETSURFACEPROPERTY 1, THIC, 30 
#Setting clear semi-diameter = 7 i.e. stop size = 10 mm
SETSURFACEPROPERTY 1, SDIA, 7 
# setting surface 1 as aperture STOP
STOPSURF 1 


# Setting up the 2nd surface
SETSURFACEPROPERTY 2, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 2, COMM, "Barrel misalignment"
# Row color with color code 2
SETSURFACEPROPERTY 2, 14, 2
SETSURFACEPROPERTY 2, THIC, 0 
#setting up x,y decenter and x,y,z tilts to zero in order
# (PARM refers to parameter)
SETSURFACEPROPERTY 2, PARM, 0, 1
SETSURFACEPROPERTY 2, PARM, 0, 2
SETSURFACEPROPERTY 2, PARM, 0, 3
SETSURFACEPROPERTY 2, PARM, 0, 4
SETSURFACEPROPERTY 2, PARM, 0, 5
#setting the order flag to zero
SETSURFACEPROPERTY 2, PARM, 0, 6


# Setting up the 3rd surface
SETSURFACEPROPERTY 3, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 3, COMM, "1st lens misalignment"
# Row color with color code 4
SETSURFACEPROPERTY 3, 14, 4
SETSURFACEPROPERTY 3, THIC, 0 
SETSURFACEPROPERTY 3, PARM, 0, 1
SETSURFACEPROPERTY 3, PARM, 0, 2
SETSURFACEPROPERTY 3, PARM, 0, 3
SETSURFACEPROPERTY 3, PARM, 0, 4
SETSURFACEPROPERTY 3, PARM, 0, 5
#setting the order flag to zero
SETSURFACEPROPERTY 3, PARM, 0, 6

# Setting up the 4th surface
SETSURFACEPROPERTY 4, TYPE, "STANDARD" 
SETSURFACEPROPERTY 4, COMM, "1st lens front" 
SETSURFACEPROPERTY 4, CURV, 1/34.724
SETSURFACEPROPERTY 4, THIC, 4.2 
SETSURFACEPROPERTY 4, GLAS, "S-NSL5" 
SETSURFACEPROPERTY 4, SDIA, 9 

# Setting up the 5th surface
SETSURFACEPROPERTY 5, TYPE, "STANDARD" 
SETSURFACEPROPERTY 5, COMM, "1st lens rear" 
SETSURFACEPROPERTY 5, CURV, -1/28.184 
#Position solve for thickness from surface 3
SOLVETYPE 5, TL, 3 
SETSURFACEPROPERTY 5, SDIA, 9 

# Setting up the 6th surface
SETSURFACEPROPERTY 6, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 6, COMM, "1st lens misalignment:return"
#Row color same as surface 3
SETSURFACEPROPERTY 6, 14, 4
# Pickup thickness from surface 5 with a scale factor of  -1
SOLVETYPE 6, TP, 5, -1
#Pickup x,y decenter and x,y,z tilts from surface 3 with a scale factor of -1
SOLVETYPE 6, PP_1, 3, -1
SOLVETYPE 6, PP_2, 3, -1
SOLVETYPE 6, PP_3, 3, -1
SOLVETYPE 6, PP_4, 3, -1
SOLVETYPE 6, PP_5, 3, -1
#setting the order flag to 1
SETSURFACEPROPERTY 6, PARM, 1, 6

# Setting up the 7th surface
SETSURFACEPROPERTY 7, TYPE, "STANDARD" 
SETSURFACEPROPERTY 7, COMM, "Dummy" 
SETSURFACEPROPERTY 7, CURV, 0
SETSURFACEPROPERTY 7, THIC, 1.956
SETSURFACEPROPERTY 7, SDIA, -1 
#SETSURFACEPROPERTY 7, SDIA, 6.904765667775799E+000 

# Setting up the 8th surface
SETSURFACEPROPERTY 8, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 8, COMM, "2nd lens misalignment"
#Row color with color code 4
SETSURFACEPROPERTY 8, 14, 6
SETSURFACEPROPERTY 8, THIC, 0.0
#setting up x,y decenter followed by x,y,z tilts in order
SETSURFACEPROPERTY 8, PARM, 0, 1
SETSURFACEPROPERTY 8, PARM, 0, 2
SETSURFACEPROPERTY 8, PARM, 0, 3
SETSURFACEPROPERTY 8, PARM, 0, 4
SETSURFACEPROPERTY 8, PARM, 0, 5
#setting the order flag to zero
SETSURFACEPROPERTY 8, PARM, 0, 6

# Setting up the 9th surface
SETSURFACEPROPERTY 9, TYPE, "STANDARD" 
SETSURFACEPROPERTY 9, COMM, "2nd lens front" 
SETSURFACEPROPERTY 9, CURV, -1/24.406 
SETSURFACEPROPERTY 9, THIC, 3.63
SETSURFACEPROPERTY 9, GLAS, "S-TIM22" 
SETSURFACEPROPERTY 9, SDIA, 9 

# Setting up the 10th surface
SETSURFACEPROPERTY 10, TYPE, "STANDARD" 
SETSURFACEPROPERTY 10, COMM, "2nd lens rear" 
SETSURFACEPROPERTY 10, CURV, -1/74.989
#Position solve for thickness from surface 8
SOLVETYPE 10, TL, 8
SETSURFACEPROPERTY 10, SDIA, 9

# Setting up the 11th surface
SETSURFACEPROPERTY 11, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 11, COMM, "2nd lens misalignment:return"
#Row color same as surface 8
SETSURFACEPROPERTY 11, 14, 6
# Pickup thickness from surface 10 with scale factor of  -1
SOLVETYPE 11, TP, 10, -1
#Pickup x,y decenter and x,y,z tilts from surface 8 with scale factor of -1
SOLVETYPE 11, PP_1, 8, -1
SOLVETYPE 11, PP_2, 8, -1
SOLVETYPE 11, PP_3, 8, -1
SOLVETYPE 11, PP_4, 8, -1
SOLVETYPE 11, PP_5, 8, -1
#setting the order flag to 1
SETSURFACEPROPERTY 11, PARM, 1, 6

# Setting up the 12th surface
SETSURFACEPROPERTY 12, TYPE, "STANDARD" 
SETSURFACEPROPERTY 12, COMM, "Dummy" 
SETSURFACEPROPERTY 12, CURV, 0
#Position solve for thickness from surface 2
SOLVETYPE 12, TL, 2
#autofill semi-diameter
SETSURFACEPROPERTY 12, SDIA, -1
#SETSURFACEPROPERTY 12, SDIA, 6.805374287323017

# Setting up the 13th surface
SETSURFACEPROPERTY 13, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 13, COMM, "Barrel misalignment:return"
#Row color same as surface 2
SETSURFACEPROPERTY 13, 14, 2
# Pickup thickness from surface 12 with scale factor of  -1
SOLVETYPE 13, TP, 12, -1
#Pickup x,y decenter and x,y,z tilts from surface 2 with scale factor of -1
SOLVETYPE 13, PP_1, 2, -1
SOLVETYPE 13, PP_2, 2, -1
SOLVETYPE 13, PP_3, 2, -1
SOLVETYPE 13, PP_4, 2, -1
SOLVETYPE 13, PP_5, 2, -1
#setting the order flag to 1
SETSURFACEPROPERTY 13, PARM, 1, 6

# Setting up the 14th surface
SETSURFACEPROPERTY 14, TYPE, "STANDARD" 
SETSURFACEPROPERTY 14, COMM, "Compensator" 
SETSURFACEPROPERTY 14, CURV, 0 
SETSURFACEPROPERTY 14, THIC, 52.47136669801098
SETSURFACEPROPERTY 14, SDIA, -1

# Setting up the 15th surface
SETSURFACEPROPERTY 15, TYPE, "STANDARD" 
SETSURFACEPROPERTY 15, COMM, "reflecting mirror" 
SETSURFACEPROPERTY 15, CURV, 0
SETSURFACEPROPERTY 15, THIC, 0
SETSURFACEPROPERTY 15, GLAS, "MIRROR" 
SETSURFACEPROPERTY 15, SDIA, 5 


UPDATE ALL
# Once reloading the required glass catalogs
# LOADCATALOG

# Setting up the 16th surface
SETSURFACEPROPERTY 16, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 16, COMM, " "
# set the row color
SETSURFACEPROPERTY 16, 14, 3
#setting return to surface 10 using XYZ orientation
SETSURFACEPROPERTY 16, 76, 3
SETSURFACEPROPERTY 16, 77, 10


# Setting up the 17th surface
SETSURFACEPROPERTY 17, TYPE, "IRREGULA" 
SETSURFACEPROPERTY 17, COMM, "Locked to surf 10" 
#pick curvature from surf 10
SOLVETYPE 17, CP, 10, 1
#Position solve for thickness from surface 9
SOLVETYPE 17, TL, 9
#Glass pickup from surf 9
SOLVETYPE 17, GP, 9 
SETSURFACEPROPERTY 17, SDIA, 9 
#Pickup x & y decenter, x,y,z tilts, coma, and angle from surface 10 with scale factor of 1
SOLVETYPE 17, PP_1, 10, 1
SOLVETYPE 17, PP_2, 10, 1
SOLVETYPE 17, PP_3, 10, 1
SOLVETYPE 17, PP_4, 10, 1
SOLVETYPE 17, PP_5, 10, 1
SOLVETYPE 17, PP_6, 10, 1
SOLVETYPE 17, PP_7, 10, 1
SOLVETYPE 17, PP_8, 10, 1
# setting up the 18th surface
SETSURFACEPROPERTY 18, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 18, COMM, " "
# set the row color
SETSURFACEPROPERTY 18, 14, 3
#setting return to surface 9 using XYZ orientation
SETSURFACEPROPERTY 18, 76, 3
SETSURFACEPROPERTY 18, 77, 9

# Setting up the 19th surface
SETSURFACEPROPERTY 19, TYPE, "IRREGULA" 
SETSURFACEPROPERTY 19, COMM, "Locked to surf 9" 
#pick curvature from surf 10
SOLVETYPE 19, CP, 9, 1
#Position solve for thickness from surface 9
SOLVETYPE 19, TL, 5
SETSURFACEPROPERTY 19, SDIA, 9 
#Pickup x & y decenter, x,y,z tilts, coma, and angle from surface 9 with scale factor of 1
SOLVETYPE 19, PP_1, 9, 1
SOLVETYPE 19, PP_2, 9, 1
SOLVETYPE 19, PP_3, 9, 1
SOLVETYPE 19, PP_4, 9, 1
SOLVETYPE 19, PP_5, 9, 1
SOLVETYPE 19, PP_6, 9, 1
SOLVETYPE 19, PP_7, 9, 1
SOLVETYPE 19, PP_8, 9, 1
# Setting up the 20th surface
SETSURFACEPROPERTY 20, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 20, COMM, " "
# set the row color
SETSURFACEPROPERTY 20, 14, 3
#setting return to surface 5 using XYZ orientation
SETSURFACEPROPERTY 20, 76, 3
SETSURFACEPROPERTY 20, 77, 5

# Setting up the 21th surface
SETSURFACEPROPERTY 21, TYPE, "IRREGULA" 
SETSURFACEPROPERTY 21, COMM, "locked to surface 5" 
#pick curvature from surf 5 with scale factor 1
SOLVETYPE 21, CP, 5, 1
#Position solve for thickness from surface 4
SOLVETYPE 21, TL, 4
#Glass pickup from surf 4
SOLVETYPE 21, GP, 4 
SETSURFACEPROPERTY 21, SDIA, 9 
#Pickup x & y decenter, x,y & z tilts, coma, and angle from surface 5 with scale factor of 1
SOLVETYPE 21, PP_1, 5, 1
SOLVETYPE 21, PP_2, 5, 1
SOLVETYPE 21, PP_3, 5, 1
SOLVETYPE 21, PP_4, 5, 1
SOLVETYPE 21, PP_5, 5, 1
SOLVETYPE 21, PP_6, 5, 1
SOLVETYPE 21, PP_7, 5, 1
SOLVETYPE 21, PP_8, 5, 1

# Setting up the 22th surface
SETSURFACEPROPERTY 22, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 22, COMM, " "
# set the row color
SETSURFACEPROPERTY 22, 14, 3
#setting return to surface 4 using XYZ orientation
SETSURFACEPROPERTY 22, 76, 3
SETSURFACEPROPERTY 22, 77, 4

# Setting up the 23rd surface
SETSURFACEPROPERTY 23, TYPE, "IRREGULA" 
SETSURFACEPROPERTY 23, COMM, "Locked to surf 4" 
#pick curvature from surf 5 with scale factor 1
SOLVETYPE 23, CP, 4, 1
SETSURFACEPROPERTY 23, THIC, -30
SETSURFACEPROPERTY 23, SDIA, 9 
#Pickup x & y decenter, x,y,z tilts, coma, and angle from surface 4 with scale factor of 1
SOLVETYPE 23, PP_1, 4, 1
SOLVETYPE 23, PP_2, 4, 1
SOLVETYPE 23, PP_3, 4, 1
SOLVETYPE 23, PP_4, 4, 1
SOLVETYPE 23, PP_5, 4, 1
SOLVETYPE 23, PP_6, 4, 1
SOLVETYPE 23, PP_7, 4, 1
SOLVETYPE 23, PP_8, 4, 1

# Setting up the 24th surface
SETSURFACEPROPERTY 24, TYPE, "COORDBRK" 
SETSURFACEPROPERTY 24, COMM, " "
# set the row color
SETSURFACEPROPERTY 24, 14, 3
#setting return to surface 1 using XYZ orientation
SETSURFACEPROPERTY 24, 76, 3
SETSURFACEPROPERTY 24, 77, 1

# Setting up the Image surface surface
SETSURFACEPROPERTY 25, TYPE, "STANDARD" 
SETSURFACEPROPERTY 25, COMM, "Locked to surf 1" 
SETSURFACEPROPERTY 25, CURV, 0
SETSURFACEPROPERTY 25, SDIA, 7 
# Pickup aperture from surface 1
SETSURFACEPROPERTY 25, APPU, 1


UPDATE ALL

#Pause 1 sec
PAUSE TIME, 1000

OPENANALYSISWINDOW "L3d" 

#Pause 1 sec
PAUSE TIME, 1000

OPENANALYSISWINDOW "TDE"

#Pause 1 sec
LOADTOLERANCE "double_pass_tolerancing.TOL"

