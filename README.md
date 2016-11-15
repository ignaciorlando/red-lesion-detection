#Retinal Vessel Segmentation and Characterization
Created by José Ignacio Orlando at Pladema Institute (Facultad de Ciencias Exactas, UNCPBA, Tandil, Argentina) and CONICET (Consejo Nacional de Investigaciones Científicas y Técnicas, Argentina).

##Introduction
This code corresponds to our paper published at MICCAI 2016. It allows you to perform:
1. Vessels segmentation in fundus images.
2. Image preprocessing to transfer pre-trained Overfeat CNN for extracting features for DR detection in fundus images.
3. Graph extraction from vessel segmentations.

##License
Our code is released under the MIT Licence (refer to the LICENSE file for details).

##Citing
If you find our code useful for your research, please cite:

(MICCAI BIBTEX)

If you use our segmentation method, please cite the following papers:

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

Additionally, if you use Soares et al. features or Azzopardi et al. features, please cite:

```
@article{soares2006retinal,
  title={Retinal vessel segmentation using the 2-D Gabor wavelet and supervised classification},
  author={Soares, Joao VB and Leandro, Jorge JG and Cesar Jr, Roberto M and Jelinek, Herbert F and Cree, Michael J},
  journal={Medical Imaging, IEEE Transactions on},
  volume={25},
  number={9},
  pages={1214--1222},
  year={2006},
  publisher={IEEE}
}
```
```
@article{azzopardi2015trainable,
  title={Trainable COSFIRE filters for vessel delineation with application to retinal images},
  author={Azzopardi, George and Strisciuglio, Nicola and Vento, Mario and Petkov, Nicolai},
  journal={Medical image analysis},
  volume={19},
  number={1},
  pages={46--57},
  year={2015},
  publisher={Elsevier}
}
```


##Contents

###Requirements
1. Download VL_Feat library and put it in util/external
2. Remove vl_kmeans functions (both MEX and .m files)