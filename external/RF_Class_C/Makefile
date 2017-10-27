# Makefile to compile mex/standalone version to Andy Liaw et al.'s C code (used in R package randomForest)
# Added by Abhishek Jaiantilal ( abhishek.jaiantilal@colorado.edu )
# License: GPLv2
# Version: 0.02


#  Makefile to generate mex or standalone. will work in cygwin (for windows) or linux
#
#  make mex: generates matlab mex files which can be easily called up
#  make diabetes: generates a standalone file to test on the pima indian
#                 diabetes dataset.
#


#source directory
SRC=src/
SRC_FILES=$(SRC)/classRF.cpp $(SRC)/classTree.cpp $(SRC)/rfutils.cpp $(SRC)/cokus.cpp

#temporary .o output directory
BUILD=tempbuild/

CC=g++
FORTRAN=gfortran # or g77 whichever is present
CFLAGS= -fpic -O2 -funroll-loops -march=native  -Wall
FFLAGS=-O2 -fpic -march=native#-g -Wall
LDFORTRAN=#-gfortran
MEXFLAGS=-O

all:	clean rfsub mex twonorm

twonorm:  clean rfsub
	echo 'Generating twonorm executable'
	$(CC) $(CFLAGS) $(SRC)twonorm_C_wrapper.cpp $(SRC_FILES) rfsub.o -o twonorm_test -lgfortran -lm -DmxCalloc=calloc -DmxFree=free

mex:  rfsub
	echo 'Generating Mex'
#	mex -c $(SRC)classRF.cpp -outdir $(BUILD)classRF.o -DMATLAB $(MEXFLAGS)
	mex $(SRC)mex_ClassificationRF_train.cpp  $(SRC_FILES) rfsub.o -o mexClassRF_train -lgfortran -lm -DMATLAB $(MEXFLAGS) 
	mex $(SRC)mex_ClassificationRF_predict.cpp $(SRC_FILES) rfsub.o  -o mexClassRF_predict -lgfortran -lm -DMATLAB $(MEXFLAGS)


octave:  rfsub
	echo -e 'Generating Octave'
#	mex -c $(SRC)classRF.cpp -outdir $(BUILD)classRF.o -DMATLAB $(MEXFLAGS)
	mkoctfile $(SRC)mex_ClassificationRF_train.cpp  $(SRC_FILES) rfsub.o -o mexClassRF_train -DMATLAB -DOCTAVE --mex
	mkoctfile $(SRC)mex_ClassificationRF_predict.cpp $(SRC_FILES) rfsub.o  -o mexClassRF_predict -DMATLAB -DOCTAVE --mex


rfsub:	$(SRC)rfsub.f
	echo 'Compiling rfsub.f (fortran subroutines)'
	$(FORTRAN)  $(FFLAGS) -c $(SRC)rfsub.f -o rfsub.o
#for compiling via a cross compiler for 64 bit
#	x86_64-pc-mingw32-gfortran -c $(SRC)rfsub.f -o rfsub.o
	

clean:	
	rm twonorm_test -rf
	rm  $(BUILD)*.o *.o -rf
	rm *~ -rf
	rm *.mexw32 twonorm_test -rf
	rm *.mexa64 -rf
	rm *.mex -rf
	rm classRF -rf
	rm *.exe -rf