#include "mex.h" 
#include <cstdio>
#include "densecrf.cpp"
#include <iostream>
#include <fstream>


// *****************************************
// Gateway routine
void mexFunction(int nlhs, mxArray * plhs[],    // output variables
                int nrhs, const mxArray * prhs[]) // input variables
{
    
    // Macros declarations 
    // For the outputs
    #define PAIRSWISEKERNELS_OUT   plhs[0]
    // For the inputs
    #define HEIGHT_IN              prhs[0]
    #define WIDTH_IN               prhs[1]
    #define LABELING_IN            prhs[2]
    #define PAIRWISEFEATURES_IN    prhs[3]
    #define NUMPAIRWISES_IN        prhs[4]
    #define THETA_P                prhs[5]
    
    // Check the input parameters
    if (nrhs < 1 || nrhs > 6)
        mexErrMsgTxt("Wrong number of input parameters.");
    
    // Get the size of the image
    int height = (int) mxGetScalar(HEIGHT_IN);
    int width = (int) mxGetScalar(WIDTH_IN); 
    
    // Get the labeling
    short * labelingIn = (short *) mxGetData(LABELING_IN);
    
    // Get the pairwise features
    float * pairwiseFeaturesIn = (float *) mxGetData(PAIRWISEFEATURES_IN);
    
    // Get the theta_p
    float * theta_p = (float *) mxGetData(THETA_P);
    
    // Create the CRF to compute the pairwise potentials. height and width 
    // represents the size of the image, and 2 is the amount of classes
    // (background and vessels) 
    DenseCRF2D crf(height, width, 2);
    
    // Get the pairwise features
    int numPairwiseFeatures = (int) mxGetScalar(NUMPAIRWISES_IN);
    float * pairwiseFeatures = (float *) mxGetData(PAIRWISEFEATURES_IN);
    // Assign the pairwise features
    int count = 0;
    for (int pairw = 0; pairw < numPairwiseFeatures; pairw++) {
        // Encode the pairwise features
        float * single_PairwiseFeatures = new float[width * height * 3];
        for (int h_=0; h_<height; h_++) {
            for (int w_=0; w_<width; w_++) {
                single_PairwiseFeatures[(h_*width+w_)*3+0] = pairwiseFeatures[count];
				single_PairwiseFeatures[(h_*width+w_)*3+1] = ((float)(h_)) / theta_p[pairw]; 
				single_PairwiseFeatures[(h_*width+w_)*3+2] = ((float)(w_)) / theta_p[pairw];
                count++;
            }
        }
        //Assign the pairwise features
        crf.addPairwiseEnergy(single_PairwiseFeatures, 3, 1.0);
        delete [] single_PairwiseFeatures;
    }
    
    // Declare the output variables
    mwSize dims[3] = {height, width, numPairwiseFeatures};
    PAIRSWISEKERNELS_OUT = mxCreateNumericArray(3, dims, mxSINGLE_CLASS, mxREAL);
    float * pairwiseKernels = (float *) mxGetData(PAIRSWISEKERNELS_OUT);
    
    // Compute the pairwise energy
    for (int pairw = 0; pairw < numPairwiseFeatures; pairw++) {
        float * pairwiseEnergy = new float[width * height];
        crf.pairwiseEnergy(labelingIn, pairwiseEnergy, pairw);
        for (int h_ = 0; h_ < height; h_++) { 
            for (int w_ = 0; w_ < width; w_++) { 
                pairwiseKernels[h_ + height * (w_ + width * pairw)] = (float) pairwiseEnergy[h_*width+w_];
            }
        }
        delete [] pairwiseEnergy;
    }
    
    return;
    
}