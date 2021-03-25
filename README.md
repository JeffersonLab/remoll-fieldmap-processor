# remoll-fieldmap-processor
Converts TOSCA .lp files into .txt files readable by remoll


Usage:
1) Copy the .lp file into the lp directory.
2) To process a file named upstream_5turn.lp, execute :

          perl batch_sens_study_local.pl -D lp -F upstream_5turn

By default, it assumes a full azimuth map or a single septant map symmetric about the center of a septant (example a field map generated between 153 and 207 in phi). If you have a single septant map that is not symmetric about the center of a septant (example a field map generated between -2 and 52 in phi),  use the -T flag: 

          perl batch_sens_study_local.pl -D lp -F upstream_5turn -T -25
          
3) Next open up the processed text file in the text folder and remove the zeroed lines at the top.

          0       -180    0       0       0       0                 x
          0       -180    0       0       0       0                 x
          0       -180    0       0       0       0                 x
          0       -27     4.5     0       0       -5.007018e-10
          0.002   -27     4.5     -1.903598e-14   -3.019426e-09   -5.007026e-10
          0.004   -27     4.5     -4.237953e-14   -6.038436e-09   -5.007048e-10
          ....................................................................

  
6)    The remaining number of lines in the file should equal the product of nR, nZ and nPhi. So, for example if the lp file has 376 steps in R, 19 steps in phi and 81 steps in Z, the total number of lines in the processed text file should be 376x19x81. 

7)    Next we need to add a six line header to field map.

          376 0 0.75                     nR rMin rMax                [different for upstream and downstream maps]
          19 -27 27                      nPhi phiMin phiMax          [different for single septant and full azimuth maps]
          81 4.5 12.5                    nZ zMin zMax                [different for upstream and downstream maps]
          25.71429 0.0                   25.71429 for single septant and 180 for full azimuth maps. In the exceptional case, use the offset value defined by T.
          7                              number of copies (7 for single septant, 1 for full azimuth map)
          0                              offset
          
8)    Copy the .txt file into remoll/map_directory for use.
