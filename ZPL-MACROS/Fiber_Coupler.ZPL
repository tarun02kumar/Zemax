# This example uses ZPL macros to design and optimize the fiber coupler: We partly use the previous Beam expander
# example adjust system parameters, populate the lens data editor (LDE), build custom merit function, and optimize



# Before running the code
# Change the ext of this file from .txt to .zpl if this is not already the case.
# Copy this file to a Zemax/Macros folder.
# Open a fresh instance of Zemax OpticStudio (or File > New) otherwise this 
# will copy data to your existing Zemax LDE.
# Goto programming tab of OpticStudio and click Edit/run (under ZPL macros section). 
# Choose the filename and execute.

# System design parameters
# Gaussian beam width is 2.5 mm diameter
# Required beam width 10 mm
# lambda = 0.550 um
# EPD = 10 mm
# Fiber NA = 0.1

# Method 
# Open the beam expander example and remove the second lens (i.e. surf 4 & 5).
# Make both surfaces of the lens have inf radii.
# Since apodization factor (G) = 4 From NA of fiber, we get d = 25 mm ( i.e. 2.5/d = 0.1)
# but our lens is 10 mm thick already. So, we assign 15 mm thickness to the third surface
# and make the first surface of the lens variable to minimize aberration (to get the plano-convex lens
# with a convex side facing the Gaussian beam) and adjust to get the best focus.
# We adopt a radius based on this and fixed it and then make the distance to surface 3 variable 
# for optimizing to get the best spot by optimizing with FICL operand


# Written by Tarun Kumar and tested using OpticStudio 2017

REM #1. Setting up System Explorer
###########################################################

# Setting up the lens unit to mm
SETSYSTEMPROPERTY 30, 0
# Setting up the aperture type to EPD
SETSYSTEMPROPERTY 10, 0
# setting EPD to 10 mm
SETSYSTEMPROPERTY 11, 10
# Setting apodization type to Gaussian
SETSYSTEMPROPERTY 12, 1
# Setting apodization factor to 4
SETSYSTEMPROPERTY 13, 4
# check afocal image space
SETSYSTEMPROPERTY 18, 1
# Setting up the field type to angle 
SETSYSTEMPROPERTY 100, 0
# Setting up the field normalization to radial 
SETSYSTEMPROPERTY 110, 0
# Setting up the number of fields to 1
SETSYSTEMPROPERTY 101, 1
# setting up the field # 1 value x=0, y= 0 degree
SETSYSTEMPROPERTY 102, 1, 0
SETSYSTEMPROPERTY 103, 1, 0
# Setting up the number of wavelengths to 1
SETSYSTEMPROPERTY 201, 1
# setting the value of wavelength # 1 in um
SETSYSTEMPROPERTY 202, 1, 0.550


# Let's print some system information and variables

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
# Insert 2 new surfaces before surface 2
INSERT 2
INSERT 2


# Setting up the OBJECT
# object type to be STANDARD
SETSURFACEPROPERTY 0, TYPE, "STANDARD" 
#Write the comments
SETSURFACEPROPERTY 0, COMM, "object" 
#Defining radius (i.e. curvature) = inf of the surface
SETSURFACEPROPERTY 0, CURV, 0 



# Setting up the 1st surface
SETSURFACEPROPERTY 1, TYPE, "STANDARD" 
SETSURFACEPROPERTY 1, COMM, "STOP" 
SETSURFACEPROPERTY 1, CURV, 0 
#Setting thickness = 5 mm
SETSURFACEPROPERTY 1, THIC, 5 
#Setting clear semi-diameter to auto 
SETSURFACEPROPERTY 1, SDIA, -1 
# setting surface 1 as aperture STOP
STOPSURF 1 


# Setting up the 2nd surface
SETSURFACEPROPERTY 2, TYPE, "STANDARD" 
SETSURFACEPROPERTY 2, COMM, "first lens front" 
SETSURFACEPROPERTY 2, CURV, 0 
#Setting thickness = 5 mm
SETSURFACEPROPERTY 2, THIC, 10 
#Setting the glass type
SETSURFACEPROPERTY 2, GLAS, "N-BK7"
#Setting clear semi-diameter to auto 
SETSURFACEPROPERTY 2, SDIA, -1 
# Setting the curvature of surface  2 variable
SOLVETYPE 2, CV


# Setting up the 3rd surface
SETSURFACEPROPERTY 3, TYPE, "STANDARD" 
SETSURFACEPROPERTY 3, COMM, "first lens rear" 
SETSURFACEPROPERTY 3, CURV, 0 
#Setting thickness = 5 mm
SETSURFACEPROPERTY 3, THIC, 15 
#Setting clear semi-diameter to auto
SETSURFACEPROPERTY 3, SDIA, -1 


#### setting up the 4th surface or image plane
SETSURFACEPROPERTY 4, TYPE, "STANDARD" 
SETSURFACEPROPERTY 4, COMM, "Image plane" 
#Setting clear semi-diameter to auto
SETSURFACEPROPERTY 4, SDIA, -1 
SETSURFACEPROPERTY 4, CURV, 0 


UPDATE ALL

# Now get the total number of surfaces
NSURF = NSUR()
PRINT "Total surfaces: ", NSURF


# Open 2D layout
OPENANALYSISWINDOW 2D_LAYOUT

REM #3. Setting up the First merit function
#################################################################### 


#First we define the default merit function and then we append
#the user defined glass/air thickness to it 
## Keyword code for default MF: RMS, SPOT Size, assume Centroid, use Gaussian Quadrature
## Rings=3, arms=6, ignore Grid, ignore Delete, assume Axial Symmetry,
# ignore Lateral Color, default Start, ignore Xweight, Overall weight 
DEFAULTMERIT 0, 1, 0, 1, 3, 6, 0, 0, 1, 1, -1, 0, 1

# Open the Merit function editor window
OPENANALYSISWINDOW "Mfe"

# To get enough decimal places
FORMAT 12.4 EXP
PRINT "Merit function before optimization: ", MFCN()

# Local optimization with default no cycles and DLS
OPTIMIZE 0, 0

# to get enough decimal places
FORMAT 12.4 EXP
PRINT "Merit function after optimization: ", MFCN()

UPDATE ALL

# Pause 1 sec
PAUSE TIME, 1000



REM #4. Modifying LDE and unchecking afocal image space
###################################################
# Adopting the radius of 12.5 for surface 2 
SETSURFACEPROPERTY 2, CURV, 1/12.5 
# Fixing the radius i.e. removing the solve from earlier 
SOLVETYPE 2, CF
# Setting the thickness of surface 3 variable
SOLVETYPE 3, TV

#Quick focus with RMS spot size and centroid using image plane
QUICKFOCUS 0, 1
# Uncheck the afocal image space
SETSYSTEMPROPERTY 18, 0


REM #5. Setting up the second merit function
#################################################################### 
# Deleting the earlier merit function
DELETEMFO ALL
# Inserting a new MFO line
INSERTMFO
#adding the comment to the first BLNK line
SETOPERAND 1, 10, "Optimizing focus distance to get the best coupling efficiency" 


#Setting operand type 
SETOPERAND 2, 11, "FICL"
# Sampling value
SETOPERAND 2, 2, 2
# Wavelength #
SETOPERAND 2, 3, 1
# Field #
SETOPERAND 2, 4, 1
# IgSrc #
SETOPERAND 2, 5, 1
# Sna #
SETOPERAND 2, 6, 0.1
# Rna #
SETOPERAND 2, 7, 0.1
#Setting target value
SETOPERAND 2, 8, 1.0
#Setting weight = 1
SETOPERAND 2, 9, 1.0
#Data type
SETOPERAND 2, 12, 0
#Polarization off
SETOPERAND 2, 13, 0

UPDATE ALL


# Local optimization with default # of cycles and DLS
OPTIMIZE 0,0


UPDATE ALL

# pause until the analysis finishes
PAUSE THREADS
# Open 2D layout
OPENANALYSISWINDOW "Lay"

# You can open Universal plots and setup focus distance as a variable to confirm that you get the lowest Merit function for the
# value of you get after optmization.

