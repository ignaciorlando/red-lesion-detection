![Graphical abstract of our method](https://raw.githubusercontent.com/ignaciorlando/red-lesion-detection/master/GRAPHICAL_ABSTRACT.png)

# An Ensemble Deep Learning Based Approach for Red Lesion Detection in Fundus Images

Created by José Ignacio Orlando at Pladema Institute (Facultad de Ciencias Exactas, UNCPBA, Tandil, Argentina) and CONICET (Consejo Nacional de Investigaciones Científicas y Técnicas, Argentina), under the supervision of [Dr. Matthew B. Blaschko](http://homes.esat.kuleuven.be/~mblaschk/) (ESAT-Visics, KU Leuven, Leuven, Belgium).

## Introduction
This code implements a red lesion detection method based on a combination of hand-crafted features and CNN based descriptors.
The main advantage of our approach is that it achieves high performance when evaluated both on a per lesion and a per image basis, being trained with small data sets such as DIARETDB1 (28 images).
A preprint of the paper explaining our methodology will be released soon.

The repository includes:

1. A new version of our blood vessel segmentation method based on fully connected CRFs learned with SOSVMs. [[paper]](https://lirias.kuleuven.be/bitstream/123456789/531621/3/OrlandoTBME2016.pdf) [[original implementation]](https://github.com/ignaciorlando/fundus-vessel-segmentation-tbme)
2. A red lesion detection method based on using CNN's and hand crafted features in combination with random forest. [[paper]](https://arxiv.org/pdf/1706.03008.pdf)
3. Code for preparing data from [DIARETDB1](http://www.it.lut.fi/project/imageret/diaretdb1/), [ROC](http://webeye.ophth.uiowa.edu/ROC/), [e-ophtha](http://www.adcis.net/en/Download-Third-Party/E-Ophtha.html) and [MESSIDOR](http://www.adcis.net/en/Download-Third-Party/Messidor.html) for our experiments.
4. Code for FROC curve computation.
5. A light CNN architecture that can be trained from small data sets using a class balanced softmax loss.
6. Code for t-SNE representation of different features.

## License
Our code is released under the MIT Licence (refer to the LICENSE file for details).

## Citing
If you use our method, please cite the following paper:

```bibtex
@article{orlando2017ensemble,
title={An Ensemble Deep Learning Based Approach for Red Lesion Detection in Fundus Images},
author={Orlando, Jos\'e Ignacio and Prokofyeva, Elena and del Fresno, Mariana and Blaschko, Matthew B},
journal={Computer Methods and Programs in Biomedicine},
year={2017}
}
```

If you use our vessel segmentation method, please cite the following papers:

```bibtex
@article{orlando2016discriminatively,
  title={A discriminatively trained fully connected Conditional Random Field model for blood vessel segmentation in fundus images},
  author={Orlando, Jos{\'e} Ignacio and Prokofyeva, Elena and Blaschko, Matthew},
  journal={Biomedical Engineering, IEEE Transactions on},
  year={2016},
  publisher={IEEE}
}
```
```bibtex
@incollection{orlando2014learning,
  title={Learning fully-connected CRFs for blood vessel segmentation in retinal images},
  author={Orlando, Jos{\'e} Ignacio and Blaschko, Matthew},
  booktitle={Medical Image Computing and Computer-Assisted Intervention--MICCAI 2014},
  pages={634--641},
  year={2014},
  publisher={Springer}
}
```

If you use our method for vessel inpainting in fundus images, please cite the following paper:

```bibtex
@incollection{orlando2016convolutional,
  title={Convolutional Neural Network transfer for glaucoma identification},
  author={Orlando, Jos{\'e} Ignacio and Prokofyeva, Elena and Blaschko, Matthew},
  booktitle={12th International Symposium on Medical Information Processing and Analysis--SIPAIM 2016},
  year={2016},
  publisher={SPIE}
}
```

Additionally, if you use Soares *et al.* features or Azzopardi *et al.* features, please cite:

```bibtex
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
```bibtex
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

## Download precomputed data and other resources

Due to the random nature of some parts of our pipeline (splits into training and validation, dropouts in the CNN, etc.) it might happen that final results are not exactly the same than the one we report. However, you can download our pretrained models from here. In that case, results should be the same.

#### **Pre-trained models**
> [Download](https://www.dropbox.com/s/wxohmajmo9cxbc1/red-lesions-detection-model.rar?dl=0)

#### Red lesion detection on DIARETDB1 test set (using Seoud et al., 2016 definition of red lesions)

We provide precomputed data for reproducibility purposes! You can download it from the following links:

* ***DIARETDB1 training set***
  * *Vessel segmentations* [Download](https://www.dropbox.com/s/gg876xahbil4d22/diaretdb1-train-vessel-segmentations.rar?dl=0)
  * *Red lesion candidates* [Download](https://www.dropbox.com/s/a9zb11al2gu9azk/diaretdb1-train-red-lesions_candidates.rar?dl=0)

* ***DIARETDB1 test set***
  * *Vessel segmentations* [Download](https://www.dropbox.com/s/wdo0691zrqske3d/diaretdb1-test-segmentations.rar?dl=0)
  * *Red lesion candidates* [Download](https://www.dropbox.com/s/f8jybt7q470nt26/diaretdb1-test-red-lesions_candidates.rar?dl=0)

#### Small red lesion detection on e-ophtha

We provide precomputed data for reproducibility purposes! You can download it from the following links:

* ***DIARETDB1-ROC training set.***
  * *Vessel segmentations* [Download](https://www.dropbox.com/s/5vensjtzknzg9t3/diaretbd1-roch-vessel-segmentations.rar?dl=0)
  * *Red lesion candidates* [Download](https://www.dropbox.com/s/a9sbgk1ofr2o5df/diaretdb1-roch-red-lesions_candidates.rar?dl=0)
* ***e-ophtha.***
  * *Vessel segmentations* [Download](https://www.dropbox.com/s/1rwfyju69g4aajp/e-ophtha-vessel-segmentations.rar?dl=0)
  * *Red lesion candidates* [Download](https://www.dropbox.com/s/do7wz6kmxq6efab/e-ophtha-red-lesions_candidates.rar?dl=0)

#### Red lesion detection on MESSIDOR using our model trained on DIARETDB1

We provide precomputed data for reproducibility purposes! You can download it from the following links:

* ***MESSIDOR***
  * *Vessel segmentations* [Download](https://www.dropbox.com/s/jb8f7f46m9axfqa/messidor-vessel-segmentations.rar?dl=0)
  * *Red lesion candidates* [Download](https://www.dropbox.com/s/i5qa67evasutvse/messidor-red-lesions_candidates.rar?dl=0)


## Download our results

If you are in a rush and you don't want to run all our code but comparing your results with ours instead, you can download from here our segmentations on [DIARETDB1 test set](https://www.dropbox.com/s/e1ewlyyopqc1e39/diaretdb1-test-red-lesions-segmentations.rar?dl=0), [e-ophtha](https://www.dropbox.com/s/abpq3ebff64l3pj/e-ophtha-red-lesions-segmentations.rar?dl=0) and [MESSIDOR](https://www.dropbox.com/s/pp2x2vm7jww0s5r/messidor-red-lesions-segmentations.rar?dl=0).

We provide:

* **Probability maps:** as .MAT files, with the same size of images but cropped around the FOV.
* **Binary segmentations:** obtained by thresholding the probability maps at a 50% probability. Again, their size is equivalent to the size of the image cropped around the FOV.
* **FROC curves:** as .FIG files. Additional data to plot it is on a .MAT file. Only for DIARETDB1 and e-ophtha.

## Using the code

### Requirements
* Microsoft Windows (7, 8 or 10), OSX El Capitan or macOS Sierra.
* MATLAB R2015a or superior. If you use MATLAB R2016b in Windows it might be possible that you won't be able to run ```vl_compilenn```. Let me know in that case and I will send to you the binary files you need :)

### First things to do
 >* Create your own copy of this repository.
 >* The folder ```/external/``` contains third-party code, that is essential for processing. We provide such files, but if you want to have the last version of those libraries you should download them and paste them in ```/external/```:
  * [VLFeat (for ROC and Pr/Re curves)](http://www.vlfeat.org/install-matlab.html)
  * [Random Forest code](https://github.com/PetterS/hep-2/tree/master/randomforest-matlab/RF_Class_C)
  * [Matconvnet](https://github.com/vlfeat/matconvnet)

### How to use this code

* Move current folder on MATLAB to the project root

```matlab
cd red-lesion-detection
```

* Run ```dr_setup``` to set up the path

```matlab
dr_setup
```

* For candidate extraction, you just have to do:
```matlab
script_extract_lesion_candidates
```
>**Remember:** You must edit ```config_extract_lesion_candidates``` before running this script to indicate the path where your images are located and to fix $L$, $k$ and $\text{px}$ values. If you don't now how to set up this parameters, you can use the scripts ```script_optimize_candidates_detection``` and ```script_optimize_number_of_pxs``` to give yourself an idea about how changing this values affect the FPI and per lesion sensitivity values you obtain on your train set.

* Once you extracted the red lesion candidates, you have to extract patches for training a CNN from scratch. You can do it using:
```matlab
script_get_red_lesion_detection_cnn_training_set
```
>**Remember:** Again, you must edit ```config_get_red_lesion_detection_cnn_training_set``` before running this script to indicate the path where your candidates and images are located.

* Congratulations! Now, you are in a position where you can train our CNN from this data. It is relatively easy. You just have to run:
```matlab
script_train_cnn
```

>**Remember:** You must edit ```config_train_cnn``` before running this script to indicate the path where your training data is located, and also some extra parameters. Our default configurations are already fixed in this script, so you can reuse them. However, you can explore your own parameters if you want. Remember not to overfitt on test data, that's not fair! ;-)

* Next step will be to trained a Random Forest classifier using both CNN and hand-crafted features. This is done by running:
```matlab
script_train_lesion_classifier
```
>**Remember:** You must edit ```config_train_lesion_classifier``` before running this script to indicate the path where your training data is located, and also some extra parameters. It also will ask you to explain the source of your features. By editing the variable ```features_source``` you can indicate if you want to use only CNN descriptors (```cnn-transfer```), hand-crafted features (```hand-crafted```) or both (```combined```). ```cnn_filename``` indicate the path (relative to ```data_path/red-lesions-detection-model/dataset_name```) where your pretrained CNN is.

* And now, you can just segment red lesions in your own data set using:
```matlab
script_segment_red_lesions
```

>**Remember:**
>- You must edit ```config_segment_red_lesions``` before running this script to indicate the path where your data set is located.
>- Ensure yourself that your data set folder is properly structured in such a way that you can find at least two folders inside: ```images```, with all your images; and ```masks```, with all your FOV masks.
>- If you want to use hand-crafted features also, you must have vessel segmentations for each of the images. Go to **How to use our segmentation method** for more details about how to do it.
>- Again, you have to provide paths to where the pretrained CNN (```cnn_filename```) and your Random Forest classifier (```trained_model_name```) are located.


### How to use our code for vessel segmentation in fundus images

Our code here is a slightly modified version of [our TBME paper](https://scholar.google.com/citations?view_op=view_citation&hl=es&user=2N3oD28AAAAJ&citation_for_view=2N3oD28AAAAJ:Y0pCki6q_DkC) on vessel segmentation. Actually, it's almost the same version we used in [our SIPAIM 2016 paper](https://scholar.google.com/citations?view_op=view_citation&hl=es&user=2N3oD28AAAAJ&citation_for_view=2N3oD28AAAAJ:eQOLeE2rZwMC) ([code here](https://github.com/ignaciorlando/overfeat-glaucoma)).

We will give you some insight about how to use it. It might be a bit unstable in terms of folders and operating systems. We are happy to accept your contributions as pull requests. If you are interested, please contact me.

OK, so let's start.

* Our segmentation method is trained on DRIVE. We are still working on a way to scale models to different resolutions to avoid retraining, but so far the best strategy we found is to normalize image sizes, resize them to a similar resolution than the one in DRIVE, and then to upsample segmentations to the original resolution. The first thing to do, then, is to manually analyze your data to estimate the scale factor. This is done my manually indicating the main vessel calibre on your data set, using ```script_measure_vessel_calibre_manually```. This script will popup an image with a rectangle around a random area of the image. You can drag that rectangle around the area where you want to zoom in, and then use double-clic to effectively zoom in there. Then, you have to draw an orthogonal line for the wider vessel. Repeat this 3 times, and for 5 images.
* This code will output a ```downsample_value```.

* Now, [download our segmentation model (3.9 MB)](https://www.dropbox.com/s/et5vplpmupbuay0/segmentation-model.rar?dl=0) trained on DRIVE and save it on a known folder.
* Edit  ```config_segment_vessels``` and assign ```scale_values = downsample_value```, and your data set name.
* Run  ```script_segment_vessels``` .

>**Warning!** You have to have sufficient space on your hard disk. This method will copy your entire data set to a separate folder, where all images will be downsample to the proper resolution.


## Acknowledgments

* This work is partially funded by ANPCyT PICT 2014-1730 and PICT 2016-0116, Internal Funds KU Leuven and FP7-MC-CIG 334380.
* J.I.O. is funded by a doctoral scholarship granted by CONICET (Argentina).
* J.I.O. would also like to thank NK and CFK. They know why :-)
