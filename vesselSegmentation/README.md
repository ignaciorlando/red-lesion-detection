#Retinal Vessel Segmentation
Created by José Ignacio Orlando at Pladema Institute (Facultad de Ciencias Exactas, UNCPBA, Tandil, Argentina) and CONICET (Consejo Nacional de Investigaciones Científicas y Técnicas, Argentina), under the supervision of Matthew B. Blaschko (KU Leuven, Belgium).

##Introduction
This code corresponds to our paper published at IEEE TBME 2016. It allows you to perform vessel segmentation in color fundus images.

##License
Our code is released under the MIT Licence (refer to the LICENSE file for details).

##Citing
If you find our code useful for your research, please cite:

```
@article{orlando2016discriminatively,
  title={A discriminatively trained fully connected Conditional Random Field model for blood vessel segmentation in fundus images},
  author={Orlando, Jos{\'e} Ignacio and Prokofyeva, Elena and Blaschko, Matthew},
  journal={Biomedical Engineering, IEEE Transactions on},
  year={2016},
  publisher={IEEE}
}
```
```
@incollection{orlando2014learning,
  title={Learning fully-connected CRFs for blood vessel segmentation in retinal images},
  author={Orlando, Jos{\'e} Ignacio and Blaschko, Matthew},
  booktitle={Medical Image Computing and Computer-Assisted Intervention--MICCAI 2014},
  pages={634--641},
  year={2014},
  publisher={Springer}
}
```

There are also some third party libraries included in our code. If you use it, please cite:

* Responses to 2D Gabor wavelets by Soares et al.
J. V. Soares et al.: Retinal vessel segmentation using the 2-D Gabor wavelet and supervised classification.
IEEE Transactions on Medical Imaging, vol. 25, no. 9, 2006
----------------------------
* Line detectors by Nguyen et al.
U. T. Nguyen et al.: An effective retinal blood vessel segmentation method using multi-scale line detection.
Pattern Recognition, vol. 46, no. 3, pp. 703–715, 2013.
----------------------------
* Efficient inference in fully connected CRF by Krahenbul and Koltun (C++ implementation)
P. Krahenbuhl and V. Koltun: Efficient inference in fully connected CRFs with Gaussian edge potentials.
Advances in Neural Information Processing Systems, 2012, pp. 109–117.
(if you use the MEX function that wraps this code please also cite our IEEE TMBE and MICCAI papers)
----------------------------
* Graph-cut for local neighborhood based CRF inference
Y. Boykov and V. Kolmogorov: An experimental comparison of mincut/max-flow algorithms for energy minimization in vision.
IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 26, no. 9, pp. 1124–1137, 2004.


##Contents

###Requirements
1. Set up MEX compiler according to your OS.
2. Compile the Fully Connected CRF wrapper doing:
```
mex ./CRF/CRF_1.0/fullyCRFwithGivenPairwises.cpp ./CRF/CRF_1.0/densecrf.cpp ./CRF/CRF_1.0/util.cpp 
mex ./CRF/CRF_1.0/pairwisePart.cpp ./CRF/CRF_1.0/densecrf.cpp ./CRF/CRF_1.0/util.cpp
```

###Using the code
Check out the user_manual.pdf file!