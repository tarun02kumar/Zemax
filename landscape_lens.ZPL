# This example demonstrate how to design and optimize a landscape or singlet lens using ZPL macros.
# It shows how to setup system parameters, populate the lens data editor (LDE), build custom 
# merit function, setup glass subs catalogue and run local and Hammer optimizer

# Before running the code
# Change the ext of this file from .txt to .zpl if this is not already the case.
# Copy this file to a Zemax/Macros folder.
# Open a fresh instance of Zemax OpticStudio (or File > New) otherwise this 
# will copy data to your existing zemax LDE.
# Goto programming tab of OpticStudio and click Edit/run (under ZPL macros section). 
# Choose the filename and execute.

# Design parameters: 
# F# = 10, EFL = 100 mm, Wavelengths = F, d, C and field of +/-5 degree
# Stop is separate physically defined surface.
# Lens should have min center and edge thickness of 2 mm 
# and max center thickness of 10 mm
# Lens should also have 2 mm of chipzone for mounting
# Minimize the rms spot size



# This code is broadly divided into 5 steps. 
# Step 1: Setup system Explorer variables EPD, Wavelengths, fields etc
# Step 2: Setup the LDE and bring it to quick focus using RMS spot and centroiding
# Step 3: Setup the variable for optimization
# Step 4: Build merit function and do the local optimization
# Step 5: Setup Glass substitution catalog and run Hammer for 1 mins
# Finally we open analysis windows


# Global Variables
F_Number = 10
Focal_Length = 100
Stop_Size = Focal_Length/F_Number
# For running hammer for 60 sec
Hammer_Time = 60.0
Max_field = 5 
# Chip Zone = 2 mm for mounting
Chip_Zone = 2

# User defined air thickness values
MinAir = 0.5
MaxAir = 1000
MinAirEdg = 0.5

# User defined glass thickness values
MinGlas = 2
MaxGlas = 10
MinGlasEdg = 2

# Written by Tarun Kumar, 2024


REM #1. Setting up System Explorer
###########################################################

# setting up the lens unit to mm
SETSYSTEMPROPERTY 30, 0
# setting up the aperture type to Float by stop size
SETSYSTEMPROPERTY 10, 3
# setting up the field type to angle 
SETSYSTEMPROPERTY 100, 0
# setting up the field normalization to radial 
SETSYSTEMPROPERTY 110, 0
# setting up the numbers of fields to 3 of equal area
SETSYSTEMPROPERTY 101, 3
# setting up the field # 1 value x=0, y= 0 degree
SETSYSTEMPROPERTY 102, 1, 0
SETSYSTEMPROPERTY 103, 1, 0
# setting up the field # 2 value x=0, y= Max_field/sqrt(2) degree 
SETSYSTEMPROPERTY 102, 2, 0
SETSYSTEMPROPERTY 103, 2, Max_field/sqrt(2)
# setting up the field # 3 value x=0, y= 5 degree 
SETSYSTEMPROPERTY 102, 3, 0
SETSYSTEMPROPERTY 103, 3, Max_field
# setting up the number of wavelengths to 3
SETSYSTEMPROPERTY 201, 3
# setting the value of wavelength # 1, 2, 3 in um
SETSYSTEMPROPERTY 202, 1, 0.486
SETSYSTEMPROPERTY 202, 2, 0.588
SETSYSTEMPROPERTY 202, 3, 0.656
# setting up the primary wavelength index # to 2
SETSYSTEMPROPERTY 200, 2

#FORMAT 0.000000
# Lets print some system information and variables

PRINT "---------------------------------------"

#IF (UNIT() == 0) THEN PRINT "Lens units are mm"

PRINT "Lens unit: ", $UNITS()
# 3 digits before and after decimals
FORMAT 3.3
PRINT "Wavelengths used: ", WAVL(1), ", ", WAVL(2), ", ", WAVL(3), " micrometers."
PRINT "Primary wavelength: ", WAVL(PWAV()) 
PRINT "Y-Fields values (equal area): ", FLDY(1), ", " ,FLDY(2), ", " ,FLDY(3)

PRINT "Name of the loaded glass catalog: ", $GLASSCATALOG(1)

PRINT "Default output File location: ", $DATAPATH()
PRINT "Macros folder location: ", $MACROPATH()


REM #2.  Setting Lens Data Editor
#####################################################################

# Insert two more surfaces before image plane i.e. surface 2
INSERT 2 
INSERT 2

# setting up the OBJECT
# object type to be STANDARD
SETSURFACEPROPERTY 0, TYPE, "STANDARD" 
#Write the comments
SETSURFACEPROPERTY 0, COMM, "object" 
#setup curvature = 0 i.e. radius = inf
SETSURFACEPROPERTY 0, CURV, 0 


# setting up the 1st surface
SETSURFACEPROPERTY 1, TYPE, "STANDARD" 
SETSURFACEPROPERTY 1, COMM, "STOP" 
SETSURFACEPROPERTY 1, CURV, 0 
#Setting thickness = 5 mm
SETSURFACEPROPERTY 1, THIC, 5 
#Setting clear semi-diameter = 5 i.e. stop size = 10 mm
SETSURFACEPROPERTY 1, SDIA, Stop_Size/2 
# setting surface 1 as aperture STOP
STOPSURF 1 

# setting up the 2nd surface
SETSURFACEPROPERTY 2, TYPE, "STANDARD" 
SETSURFACEPROPERTY 2, COMM, "front of the lens" 
SETSURFACEPROPERTY 2, CURV, 0
SETSURFACEPROPERTY 2, THIC, 10 
#Setting the glass type
SETSURFACEPROPERTY 2, GLAS, "N-BK7" 
#Semi-diameter to be calculated automatically
SETSURFACEPROPERTY 2, SDIA, -1 
# Selecting the chipzone 
SETSURFACEPROPERTY 2, CHZN, Chip_Zone 


# setting up the 3rd surface
SETSURFACEPROPERTY 3, TYPE, "STANDARD" 
SETSURFACEPROPERTY 3, COMM, "rear of the lens" 
# Solving the F# to autocalculate the radius
SOLVETYPE 3, CG, F_Number
#Filling default thickness or BFD to image plane
# and solving it using quickfocus in next step
SETSURFACEPROPERTY 3, THIC, 100
#Semi-diameter to be calculated automatically
SETSURFACEPROPERTY 3, SDIA, -1
# Selecting the chipzone
SETSURFACEPROPERTY 3, CHZN, Chip_Zone 

# setting up the 4th surface or image plane
SETSURFACEPROPERTY 4, TYPE, "STANDARD" 
SETSURFACEPROPERTY 4, COMM, "Image plane" 
SETSURFACEPROPERTY 4, CURV, 0 



UPDATE ALL

#Quick focus with RMS spot size and centroid using image plane
QUICKFOCUS 0, 1

UPDATE ALL


REM #3. Setting up the variables for optmization
###########################################################
# setting the thickness of surface 1 and 2 variable
SOLVETYPE 1, TV
SOLVETYPE 2, TV
# setting the curvature of surface 2 variable
SOLVETYPE 2, CV
# setting the thickness of surface 3 variable
SOLVETYPE 3, TV
# Setting the glass solve as substitute for surface 2 for 
# hammer optimization later
SOLVETYPE 2, GS


# Now get the total number of surfaces
NSURF = NSUR()
PRINT "Total surfaces: ", NSURF


REM #4. Setting up the merit function
#################################################################### 


#First we define the default merit function and then we append
#the user defined glass/air thickness to it 
## Keyword code for default MF: RMS, SPOT Size, assume Centroid, use Gussian Qudarature
## Rings=3 , arms=6, ignore Grid, ignore Delete, assume Axial Symmetry,
# ignore Lateral Color, default Start, ignore Xweight, Overall weight 
DEFAULTMERIT 0, 1, 0, 1, 3, 6, 0, 0, 1, 1, -1, 0, 1

DELETEMFO 3  # delete the BLNK (BLANK) with old comments to replace it with new one
INSERTMFO 3  # Insert the new BLNK operand
SETOPERAND 3, 10, "User defined glass and air thicknesses" # adding the comment to BLNK 
# inserting 18 empty lines in Merit function editor starting from position 4
For i, 4, 21, 1
  INSERTMFO i  
NEXT



#Inserting variable in Merit function editor 

 FOR i, 1, 3, 1
 
   #Setting operand type 
   SETOPERAND 6*(i-1)+4, 11, "MNCA"
   #Setting surf 1 value
   SETOPERAND 6*(i-1)+4, 2, i
   #Setting surf 2 value
   SETOPERAND 6*(i-1)+4, 3, i
   #Setting target value
   SETOPERAND 6*(i-1)+4, 8, MinAir
   #Setting weight = 1
   SETOPERAND 6*(i-1)+4, 9, 1.0
  
   SETOPERAND 6*(i-1)+5, 11, "MXCA"
   SETOPERAND 6*(i-1)+5, 2, i
   SETOPERAND 6*(i-1)+5, 3, i
   SETOPERAND 6*(i-1)+5, 8, MaxAir
   SETOPERAND 6*(i-1)+5, 9, 1.0
    
   SETOPERAND 6*(i-1)+6, 11, "MNEA"
   SETOPERAND 6*(i-1)+6, 2, i
   SETOPERAND 6*(i-1)+6, 3, i
   SETOPERAND 6*(i-1)+6, 8, MinAirEdg
   SETOPERAND 6*(i-1)+6, 9, 1.0
  
   SETOPERAND 6*(i-1)+7, 11, "MNCG"
   SETOPERAND 6*(i-1)+7, 2, i
   SETOPERAND 6*(i-1)+7, 3, i
   SETOPERAND 6*(i-1)+7, 8, MinGlas
   SETOPERAND 6*(i-1)+7, 9, 1.0
   
   SETOPERAND 6*(i-1)+8, 11, "MXCG"
   SETOPERAND 6*(i-1)+8, 2, i
   SETOPERAND 6*(i-1)+8, 3, i
   SETOPERAND 6*(i-1)+8, 8, MaxGlas
   SETOPERAND 6*(i-1)+8, 9, 1.0

   SETOPERAND 6*(i-1)+9, 11, "MNEG"
   SETOPERAND 6*(i-1)+9, 2, i
   SETOPERAND 6*(i-1)+9, 3, i
   SETOPERAND 6*(i-1)+9, 8, MinGlasEdg
   SETOPERAND 6*(i-1)+9, 9, 1.0

 NEXT

PRINT "Initial merit function:", MFCN()

# Local Optimization with default # of cycles and DLS
OPTIMIZE 0, 0

FORMAT 9.5 EXP
# Merit function after local optimization
x1 = MFCN()

PRINT "Merit function after optimization:", x1



REM #5 Setting Glass substitution template
####################################################################################
# Check use glass subs template
GLASSTEMPLATE 0, 1
# Check exclude glasses with incomplete data
GLASSTEMPLATE 1, 1
# Check standard 
GLASSTEMPLATE 11, 1
# Check preferred 
GLASSTEMPLATE 12, 1
# Uncheck obsolete 
GLASSTEMPLATE 13, 0
# Uncheck special 
GLASSTEMPLATE 14, 0

# check max relative cost
GLASSTEMPLATE 21, 1
# check max climatic resistance
GLASSTEMPLATE 22, 1
# check max stain resistance
GLASSTEMPLATE 23, 1
# Uncheck acid resistance
GLASSTEMPLATE 24, 0
# Uncheck Alkali resistance
GLASSTEMPLATE 25, 0
# Uncheck phosphate resistance
GLASSTEMPLATE 26, 0

# set max relative cost as 10
GLASSTEMPLATE 31, 10
# set max climatic resistance as 1
GLASSTEMPLATE 32, 2
# set max stain resistance as 1
GLASSTEMPLATE 33, 1

UPDATE ALL

# pause for 2 sec
PAUSE TIME, 1000

FORMAT 2.0
PRINT "Please wait ", HAMMER_TIME, " sec for hammer optimization....."

REM #6 Run the HAMMER for 60 seconds
##############################################################################
# Turning on the timer
TIMER
# Label to return to for GOTO command
LABEL 1
# HAMMER optimization with 10 cycles and DLS 
HAMMER 10, 0

# If elapsed time <= 60 sec since the timer is on then goto LABEL 1
IF ETIM() <= HAMMER_TIME THEN GOTO 1


UPDATE ALL

FORMAT 9.5 EXP
PRINT "Final merit function after Hammer with glass substitution:", MFCN()



##############################################################################


# Storing system data in array VEC1
GETSYSTEMDATA 1

# Lets print some optical system parameters
PRINT "----------------------------- "
PRINT "Entrance Pupil Diameter: ", VEC1(11)
PRINT "Entrance Pupil Position: ", VEC1(12)   
PRINT "Exit Pupil Diameter: ", VEC1(13)   
PRINT "Exit Pupil Position: ", VEC1(14) 
PRINT "Index of refraction at the primary wavelength: ", INDX(2)

# pause for 2 sec before opening analysis windows
PAUSE TIME, 2000


#Open layout, standard spot diagram, ray fan and merit function editor
OPENANALYSISWINDOW "Lay"
#PAUSE TIME, 2000
OPENANALYSISWINDOW "Spt"
#PAUSE TIME, 2000
OPENANALYSISWINDOW "Ray"
#PAUSE TIME, 2000
OPENANALYSISWINDOW "MFE"

UPDATE ALL


# rings when the code finishes 
BEEP


# Final Note:
# Landscaope lens is a simplest imaging system with few degree of
# freedom therefore, its suffers from substantial uncorrectable aberrations.
