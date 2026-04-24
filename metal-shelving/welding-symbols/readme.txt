Standard welding symbols and supplemental symbols block library


Created by:
Bates Technical College, Tacoma, WA, USA
Evening welding program, instructor and students.
July/Aug 2019

                   
This is a free open source block library of welding symbols and auxiliary/supplemental symbols. This library is to remain free of charge for personal and/or educational use. If you are a profitable business entity, please purchase a welding symbol block library online. 

                  
Many thanks to LibreCAD, LibreOffice, Linux Mint, Linux and Open Source communities, GitHub and Sourceforge for the free software and supporting the Open Source Community! 

                  
A big thank you to the students of Bates Technical College Welding Program for creating the welding symbols block library. Many hours of work was done in class and outside during personal time at home, again, Thank You!


Sincerely,
Bates Welding Program, 2019

-------------------------------------------------------------------------------------------------------------


                #######            #####    ##############     ###########      ######
               ###    ##          ##  ##   ##############     ###########     ###    ###
              ###    ##          ##   ##         ##          ##              ##      
             ###    ##          ##    ##        ##          ##               ##
            ###   ###          ## ######       ##          #######             ###
           ###      ##        ##########      ##          ##                     ####
          ###       ###      ##       ##     ##          ##                         ###
         ###        ###    ####      ###    ##          ###########          ##     ###
        #############     ####       ###   ##          ############           ########

-------------------------------------------------------------------------------------------------------------


Drawn in LibreCAD
Multiple Platforms: Windows/MacOS/LinuxOS
Scale Factor : 1
Drawing Units: INCH
Arrow size: 0.1"


KEY:

All symbols file names are orderd as follows:
Arrow side    1-4
Other side    5-8
Both sides    9-12

All files in order of arrow point as Reference Point, 

Starting with "Arrow Side" on Reference line as follows: 1=top left, 2=bottom left, 3=top right, 4=bottom right, as positions 1-4

5-8 restarts the cycle but weld symbol on "other side" of ref line as follows: 5=top left, 6=bottom left, 7=top right, 8=bottom right

9-12 shall be "Both Sides" of Reference line.

Position 1, Arrow side, Top Left
Position 2, Arrow side, Bottom Left
Position 3, Arrow side, Top Right
Position 4, Arrow Side, Bottom Right
Position 5, Other side, Top Left
Position 6, Other side, Bottom Left
Position 7, Other side, Top Right
Position 8, Other Side, Bottom Right
Position 9, Both sides, Top Left
Position 10, Both sides, Bottom Left
Position 11, Both sides, Top Right
Position 12, Both Sides, Bottom Right

############################################

Fillet Weld:    F**.dxf
Plug/Slot Weld: Plug**.dxf
Spot Weld:      Slot**.dxf
Stud Weld:      Stud**.dxf
Seam Weld:      Seam**.dxf
Back:           Back**.dxf
Surfacing Weld: Surf**.dxf
Edge Weld:       Edge**.dxf
Square Weld:    Squr**.dxf
V-Groove Weld:  Vgrv**.dxf
Bevel Weld:     Bev***.dxf
U-Groove Weld:  Ugrv**.dxf
J-Groove Weld:  Jgrv**.dxf
Flare-V Weld:   FlarV*.dxf
Flare-Bevel:    FlrBv*.dxf
Scarf:          Scarf*.dxf
Field Weld:     Field*.dxf
Melt-Thru:      Melthru.dxf
Consum  Insert: Cinsrt.dxf
Backing:        Backing*.dxf
Spacer:         Space*.dxf
Flush contour:  confl*.dxf
Convex contour: concv**.dxf
Concave contour:concc**.dxf
Weld All Around:WldAllRnd.dxf

############################################

Example:
   “Bevel groove, arrow side weld”, arrow and reference line running up and to the right would be "Bev3.dxf".


Fillet Welds:

    Noted as "F**" in file name, number following "F" is stated above for desired position on blueprint.  

“Fillet weld other side”, arrow and reference line running up and to the left would be "F5.dxf"


--------------------------------------------------------------------

Aux symbols:

Same numbering system as weld symbols, 2 sets of each for Fillet welds and all other weld symbols.
Ref point: tip of arrow. 
Arrow side(top left to bottom right position)1-4, 
Other side = 5-8(top left to bottom right position)

Aux symbols include:

    Weld all around: WldAllRnd.dxf
    Field Weld:      Field**.dxf
    Contour Flush:   confl**.dxf
    Contour Convex:  concv**.dxf    
    Contour Concave: concc.**dxf

Standard contour symbols:

            EXAMPLE: V-Groove weld symbol;arrow side; top left position="Vgrv1.dxf"
            add flush contour symbol;top left position;arrow side="confl1.dxf"

            EXAMPLE 2: Bevel weld; other side; bottom right position="Bev8.dxf"
            add convex contour symbol;other side;botton right position="concv8.dxf"


Fillet Weld Contours:

    Fillet Flush:    conflF1-F8.dxf    EXAMPLE= "conflF3.dxf"
    Fillet Convex:   concvF1-F8.dxf
    Fillet Concave:  conccF1-F8.dxf

            EXAMPLE: Fillet weld;arrow side;bottom left position="F2.dxf"
                     add Concave symbol: arrow side;bottom left position="conccF2.dxf"
