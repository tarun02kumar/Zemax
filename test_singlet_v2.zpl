


#Setting up System Explorer
###########################################################

# setting up the lens unit to mm
SETSYSTEMPROPERTY 30, 0
# setting up the aperture type to EPD
SETSYSTEMPROPERTY 10, 0
# setting up the aperture size to 40 mm 
SETSYSTEMPROPERTY 11, 40
# setting up the field type to angle 
SETSYSTEMPROPERTY 100, 0
# setting up the numbers of fields to 2
SETSYSTEMPROPERTY 101, 2
# setting up the field # 1 value x=0, y= 0 degree
SETSYSTEMPROPERTY 102, 1, 0
SETSYSTEMPROPERTY 103, 1, 0
# setting up the field # 2 value x=0, y= 5 degree 
SETSYSTEMPROPERTY 102, 2, 0
SETSYSTEMPROPERTY 103, 2, 5
# setting up the primary wavelength index # to 1
SETSYSTEMPROPERTY 200, 1
# setting up the number of wavelength(s) i.e. 1
SETSYSTEMPROPERTY 201, 1
# setting the value of wavelength # 1 to 0.587 um
SETSYSTEMPROPERTY 202, 1, 0.587


# Storing system data in array VEC1
GETSYSTEMDATA 1
PRINT "Aperture diameter:", VEC1(1) 
PRINT "Entrance Pupil Diameter:", VEC1(11) 

IF (UNIT() == 0) THEN PRINT "Lens units are mm"

PRINT " Primary wavelength: ", WAVL(PWAV()), " micrometers."

PRINT "Number of wavelengths: ", NWAV()

PRINT "Number of Fields: ", NFLD()

#Setting Lens Data Editor
###############################################

# Insert two more surfaces before image plane i.e. surface 2
INSERT 2 
INSERT 2

#setting up the OBJECT
# object type to be STANDARD
SETSURFACEPROPERTY 0, "STANDARD" 
#Write the comments
SETSURFACEPROPERTY 0, COMM, "object" 
#FDefining radius (i.e. curvature) of the surface
SETSURFACEPROPERTY 0, CURV, 0 

# setting up the 1st surface
SETSURFACEPROPERTY 1, "STANDARD" 
SETSURFACEPROPERTY 1, COMM, "STOP" 
SETSURFACEPROPERTY 1, CURV, 0 
#Setting thickness = 50 mm
SETSURFACEPROPERTY 1, THIC, 50 
# setting surface 1 as aperture STOP
STOPSURF 1 

# setting up the 2nd surface
SETSURFACEPROPERTY 2, "STANDARD" 
SETSURFACEPROPERTY 2, COMM, "front of the lens" 
#Filling radius = 100 (i.e. curvature) of the surface
SETSURFACEPROPERTY 2, CURV, 1/100
#Setting thickness = 10 mm
SETSURFACEPROPERTY 2, THIC, 10 
#Setting the glass type
SETSURFACEPROPERTY 2, GLAS, "N-BK7" 
# Selecting the chipzone to be 2 mm for lens mount
SETSURFACEPROPERTY 2, CHZN, 2 


# setting up the 3rd surface
SETSURFACEPROPERTY 3, "STANDARD" 
#Write the comments
SETSURFACEPROPERTY 3, COMM, "rear of the lens" 
#Filling default radius (i.e. curvature) and then solving
# it using F# in next line 
SETSURFACEPROPERTY 3, CURV, 0
# Solving the F# to autocalculate the radius i.e. curvature
SOLVETYPE 3, CG, 10
#Filling default thickness or distance to image plane
# solving it using quickfocus
SETSURFACEPROPERTY 3, THIC, 100
# Selecting the chipzone to be 2 mm for lens mount
SETSURFACEPROPERTY 3, CHZN, 2 

#### setting up the 4th surface or image plane
SETSURFACEPROPERTY 4, "STANDARD" 
SETSURFACEPROPERTY 4, COMM, "Image plane" 
SETSURFACEPROPERTY 4, CURV, 0 



UPDATE ALL

#Quick focus with RMS spot size and centroid using image plane
QUICKFOCUS 0, 1



#Setting up the variables for optmization
###########################################################
# setting the thickness of surface 1 variable
SOLVETYPE 1, TV
SOLVETYPE 2, TV
# setting the curvature of surface 2 variable
SOLVETYPE 2, CV
# Solve image plane distance as the marginal ray height
#SOLVETYPE 3, TM
# setting the thickness of surface 3 variable
SOLVETYPE 3, TV


# Now get the total number of surfaces
NSURF = NSUR()
PRINT "Total surfaces: ", NSURF


#Setting up the merit function
#################################################################### 
### First we define the default merit function and then we append
###  the glass thicness to it in the next section
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

# User defined air thickness values
MinAir = 0.5
MaxAir = 1000
MinAirEdg = 0.5

# User defined glass thickness values
MinGlas = 3
MaxGlas = 20
MinGlasEdg = 3

#Inserting variable in Merit function editor 

 FOR i, 1, 3, 1
 
   #Setting operand type 
   SETOPERAND 6*(i-1)+4, 11, "MNCA"
   #Setting surf1 value
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


###########################################################################

UPDATE ALL

PRINT "Initial merit function:", MFCN()

# Optmizing with automatic no of cycles with DLS  
OPTIMIZE 0, 0

PRINT "Merit function after optimization:", MFCN()

# Hammer it for 10 cycles and use DLS

HAMMER 10, 0

PRINT " Merit function after Hammer optimization :", MFCN()

 
