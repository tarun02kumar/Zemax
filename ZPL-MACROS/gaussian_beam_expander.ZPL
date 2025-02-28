# This example uses ZPL macros to design and optimize a Gaussian beam expander using ray based method
# It shows how to setup system parameters, populate the lens data editor (LDE), build custom 
# merit function and optimize

# Before running the code
# Change the ext of this file from .txt to .zpl if this is not already the case.
# Copy this file to a Zemax/Macros folder.
# Open a fresh instance of Zemax OpticStudio (or File > New) otherwise this 
# will copy data to your existing zemax LDE.
# Goto programming tab of OpticStudio and click Edit/run (under ZPL macros section). 
# Choose the filename and execute.
# Written by Tarun Kumar and tested with OpticStudio, 2017

# System design parameters
# Gaussian beam width is 2.5 mm diameter
# Required beam width 10 mm
# lambda = 0.550 um
# EPD = 10 mm

# Analysis 
# To get apodization factor needed to get the required beam width
# I(r) = 1/e^(2*G*(r^2)) where r is normalized pupil radius and G is apodization factor
# The beam intensity drop to 1/e^2 (condition for gaussian beam) at edge of half 
# pupil (r =0.5 i.e. beam width) for G = 4 

# Written by Tarun Kumar and tested using OpticStudio 2017

REM #1. Setting up System Explorer
###########################################################

# setting up the lens unit to mm
SETSYSTEMPROPERTY 30, 0
# setting up the aperture type to EPD
SETSYSTEMPROPERTY 10, 0
# setting EPD to 10 mm
SETSYSTEMPROPERTY 11, 10
# setting apodization type to Gaussian
SETSYSTEMPROPERTY 12, 1
# setting apodization factor to 4
SETSYSTEMPROPERTY 13, 4
# check afocal image space
SETSYSTEMPROPERTY 18, 1
# setting up the field type to angle 
SETSYSTEMPROPERTY 100, 0
# setting up the field normalization to radial 
SETSYSTEMPROPERTY 110, 0
# setting up the numbers of fields to 1
SETSYSTEMPROPERTY 101, 1
# setting up the field # 1 value x=0, y= 0 degree
SETSYSTEMPROPERTY 102, 1, 0
SETSYSTEMPROPERTY 103, 1, 0
# setting up the number of wavelengths to 1
SETSYSTEMPROPERTY 201, 1
# setting the value of wavelength # 1 in um
SETSYSTEMPROPERTY 202, 1, 0.550


# Lets print some system information and variables

PRINT "---------------------------------------"

#IF (UNIT() == 0) THEN PRINT "Lens units are mm"

PRINT "Lens unit: ", $UNITS()

PRINT "Number of wavelengths: ", INTE(NWAV())
PRINT "Wavelengths used: ", WAVL(1), " micrometers."
PRINT "Primary wavelength: ", WAVL(PWAV()) 
PRINT "Number of Fields: ", INTE(NFLD())
PRINT "Y-Fields values: ", FLDY(1)

PRINT "Name of the loaded glass catalog: ", $GLASSCATALOG(1)

PRINT "Default output File location: ", $DATAPATH()
PRINT "Macros folder location: ", $MACROPATH()



REM #2. Setting Lens Data Editor
##############################################################
# insert 4 new surface before surface 2

FOR i= 1, 4,1
INSERT 2
NEXT


# setting up the OBJECT
# object type to be STANDARD
SETSURFACEPROPERTY 0, TYPE, "STANDARD" 
#Write the comments
SETSURFACEPROPERTY 0, COMM, "object" 
#Defining radius (i.e. curvature) = inf of the surface
SETSURFACEPROPERTY 0, CURV, 0 



# setting up the 1st surface
SETSURFACEPROPERTY 1, TYPE, "STANDARD" 
SETSURFACEPROPERTY 1, COMM, "STOP" 
SETSURFACEPROPERTY 1, CURV, 0 
#Setting thickness = 5 mm
SETSURFACEPROPERTY 1, THIC, 5 
#Setting clear semi-diameter to auto 
SETSURFACEPROPERTY 1, SDIA, -1 
# setting surface 1 as aperture STOP
STOPSURF 1 


# setting up the 2nd surface
SETSURFACEPROPERTY 2, TYPE, "STANDARD" 
SETSURFACEPROPERTY 2, COMM, "first lens front" 
SETSURFACEPROPERTY 2, CURV, 0 
#Setting thickness = 5 mm
SETSURFACEPROPERTY 2, THIC, 10 
#Setting the glass type
SETSURFACEPROPERTY 2, GLAS, "N-BK7"
#Setting clear semi-diameter to auto 
SETSURFACEPROPERTY 2, SDIA, -1 


# setting up the 3rd surface
SETSURFACEPROPERTY 3, TYPE, "STANDARD" 
SETSURFACEPROPERTY 3, COMM, "first lens rear" 
SETSURFACEPROPERTY 3, CURV, 0 
#Setting thickness = 5 mm
SETSURFACEPROPERTY 3, THIC, 200 
#Setting clear semi-diameter to auto
SETSURFACEPROPERTY 3, SDIA, -1 


# setting up the 4th surface
SETSURFACEPROPERTY 4, TYPE, "STANDARD" 
SETSURFACEPROPERTY 4, COMM, "second lens front" 
SETSURFACEPROPERTY 4, CURV, 0 
#Setting thickness = 5 mm
SETSURFACEPROPERTY 4, THIC, 10
#Setting the glass type
SETSURFACEPROPERTY 4, GLAS, "N-BK7"
#Setting clear semi-diameter to auto
SETSURFACEPROPERTY 4, SDIA, -1 


# setting up the 5th surface
SETSURFACEPROPERTY 5, TYPE, "STANDARD" 
SETSURFACEPROPERTY 5, COMM, "second lens rear" 
SETSURFACEPROPERTY 5, CURV, 0 
#Setting thickness = 5 mm
SETSURFACEPROPERTY 5, THIC, 10 
#Setting clear semi-diameter to auto 
SETSURFACEPROPERTY 5, SDIA, -1 


#### setting up the 6th surface or image plane
SETSURFACEPROPERTY 6, TYPE, "STANDARD" 
SETSURFACEPROPERTY 6, COMM, "Image plane" 
#Setting clear semi-diameter to auto
SETSURFACEPROPERTY 6, SDIA, -1 
SETSURFACEPROPERTY 6, CURV, 0 

REM #3. Setting up the variables for optmization
###########################################################

# setting the curvature of surface 2, 3,4 and 5 variable
SOLVETYPE 2, CV
SOLVETYPE 3, CV
SOLVETYPE 4, CV
SOLVETYPE 5, CV
# Setting the glass solve as substitute for surface 2 for later hammer optimization
# SOLVETYPE 2, GS


# Now get the total number of surfaces
NSURF = NSUR()
PRINT "Total surfaces: ", NSURF


REM #4. Setting up the merit function
#################################################################### 
# We built the merit function manually for the RMS angular radius, centroid with
# 3 rings and 6 arms with x_wt and y_wt =1

# Open Merit function editor window
OPENANALYSISWINDOW "Mfe"

# Inserting 11 empty lines in Merit function editor starting from position 1
For i, 1, 11, 1
  INSERTMFO i  
NEXT

SETOPERAND 1, 10, "REAY -> Image height at half pupil (i.e. Py = 0.5) should be 10" # adding the comment to BLNK 

##Setting operand #2
# Type 
SETOPERAND 2, 11, "REAY"
# surf1 value
SETOPERAND 2, 2, 6
# Wave value
SETOPERAND 2, 3, 1
# Py value
SETOPERAND 2, 7, 0.5
# Target value
SETOPERAND 2, 8, 10
# Weight
SETOPERAND 2, 9, 1

##Setting operand #3 
# Type
SETOPERAND 3, 11, "DMFS"


SETOPERAND 4, 10, "Sequential merit function: RMS angular radius (x and y wt = 1) centroid GQ 3 rings 6 arms " # adding the comment to BLNK 

SETOPERAND 5, 10, "No air or glass constraints." # adding the comment to BLNK 

SETOPERAND 6, 10, "Operands for field 1." # adding the comment to BLNK 

##Setting operand #7 
# Type
SETOPERAND 7, 11, "ANCX"
# Wave value
SETOPERAND 7, 3, 1
#Px value
SETOPERAND 7, 6, 3.357106870197288E-001
# Weight
SETOPERAND 7, 9, 3.542270162137414E-001

##Setting operand #8 
# Type
SETOPERAND 8, 11, "ANCY"
# Wave value
SETOPERAND 8, 3, 1
# Px value
SETOPERAND 8, 6, 3.357106870197288E-001
# Weight
SETOPERAND 8, 9, 3.542270162137414E-001

##Setting operand 9 type 
SETOPERAND 9, 11, "ANCX"
# Setting operand 7 wave value
SETOPERAND 9, 3, 1
# Setting operand 2 Px value
SETOPERAND 9, 6, 7.071067811865476E-001
# Setting operand 2 Weight
SETOPERAND 9, 9, 2.557345625717812E-002

##Setting operand 10 type 
SETOPERAND 10, 11, "ANCY"
# Wave value
SETOPERAND 10, 3, 1
#  Px value
SETOPERAND 10, 6, 7.071067811865476E-001
# Weight
SETOPERAND 10, 9, 2.557345625717812E-002

##Setting operand 11 type 
SETOPERAND 11, 11, "ANCX"
#  Wave value
SETOPERAND 11, 3, 1
#  Px value
SETOPERAND 11, 6, 9.419651451198934E-001
#  Weight
SETOPERAND 11, 9, 7.212024737609961E-004

##Setting operand 12 type 
SETOPERAND 12, 11, "ANCY"
#  wave value
SETOPERAND 12, 3, 1
# Px value
SETOPERAND 12, 6, 9.419651451198934E-001
# Weight
SETOPERAND 12, 9, 7.212024737609961E-004

UPDATE ALL

# to get the enough decimal places
FORMAT 12.4 EXP
PRINT "Merit function before optmization: ", MFCN()


# Local optimzation with default no cylces and DLS
OPTIMIZE 0, 0

# to get the enough decimal places
FORMAT 12.4 EXP
PRINT "Merit function after optmization: ", MFCN()

UPDATE ALL

# pause until analysis finishes
PAUSE THREADS
# Open 2D layout
OPENANALYSISWINDOW "Lay"

#GETTEXTFILE "C:\Users\tarun\OneDrive\Documents\Zemax\Configs\Spot1.cfg", Spt

! Look at the two spot diagram windows at different surface i.e. spot surface and image surface
! we find despite beam being propagating 100 mm the spot size doesn't change because there is not 
! phase relationship between the rays that allows the beam to diffract and we have only setup the 
! Intensity distribution across the pupil so far
