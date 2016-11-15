/*
 * file: SORcomplete_mex.c
 * author: Matthew Blaschko - matthew.blaschko@inria.fr
 * (c) copyright 2011-2012
 */


#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include <mex.h>

void SORCloopAllPairsKernel(double *alpha, double *delta, double *sunsort, double *s, double *p, double *Delta, int lengthDelta, char slackmargin);
void SORCloopMarginKernel(double *alpha, double *delta, double *spos, double *ppos, double *sneg, double *pneg, double *Deltapos, double *Deltaneg,int lengthspos,int lengthsneg);
void SORCloopSlackKernel(double *alpha, double *delta, double *spos, double *ppos, double *sneg, double *pneg, double *Deltapos, double *Deltaneg,int lengthspos,int lengthsneg);
void SORCloopGTKernel(double *alpha, double *delta, double *spos, double *ppos, double *sneg, double *pneg, double *Deltapos, double *Deltaneg,int lengthspos,int lengthsneg);
int computeCutoff(double *Delta,int lengthDelta);

/*
 * [s,p] = sort(sunsort);
 * slackmargin = 's';
 * [psi,delta] = SORcomplete_mex(sunsort,s,p,Delta,slackmargin);
 */
void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {


    if(nlhs>0) {
      
      /* variable initialization */
      double *sunsort,*s,*p,*Delta;
      char *slackmargin;
      double *alpha;
      double *delta;
      int lengthDelta;
      
      /* assigning input parameters */
      sunsort = mxGetPr(prhs[0]);
      s = mxGetPr(prhs[1]);
      p = mxGetPr(prhs[2]);
      Delta = mxGetPr(prhs[3]);
      lengthDelta = (int)(mxGetM(prhs[3])*mxGetN(prhs[3]));
      slackmargin = (char *)(mxGetChars(prhs[4]));
      
      /* create output array */
      plhs[0] = mxCreateNumericMatrix (mxGetM(prhs[0]), 1, mxDOUBLE_CLASS, 0);
      assert (plhs[0] != NULL);
      alpha = (double *) mxGetPr (plhs[0]);
      assert (alpha != NULL);
      /* mxCreateNumericMatrix guarantees all entries are already zero. */

      plhs[1] = mxCreateNumericMatrix (1, 1, mxDOUBLE_CLASS, 0);
      assert (plhs[1] != NULL);
      delta = (double *) mxGetPr (plhs[1]);
      assert (delta != NULL);

      SORCloopAllPairsKernel(alpha,delta,sunsort,s,p,Delta,lengthDelta,
		       *slackmargin);
    }

}


/*
 * [alpha, delta] = SORCloopAllPairsKernel(sunsort, s, p, Delta, lengthDelta, slackmargin)
 * 
 * output:
 *      alpha =
 *      delta =
 * input
 *      sunsort = scores unsort
 *      s = scores sorted
 *      p = permutation of the sunsort to get s
 *      Delta = 
 *      lengthDelta = length of the Delta array
 *      slackmargin = a char indicating which type of ranking loss is used (margin or slack)
 */
void SORCloopAllPairsKernel(double *alpha, double *delta, double *sunsort, double *s, double *p, double *Delta, int lengthDelta, char slackmargin) {
  // initialize variables
  double *p1,*p2,*s1,*s2,*alpha1,*alpha2,*Delta1,*Delta2,*sunsort1,*sunsort2;
  double delta1=0,delta2=0;
  int i;
  int ind1,ind2;
  int cutoff;
  // ????
  if(Delta[0]==Delta[lengthDelta-1]) {
    *delta = 0;
    return;
  }
  //
  cutoff = computeCutoff(Delta,lengthDelta);
  
  alpha1 = alpha;
  alpha2 = alpha+cutoff+1;
  Delta1 = Delta;
  Delta2 = Delta+cutoff+1;
  sunsort1 = sunsort;
  sunsort2 = sunsort+cutoff+1;
  p1 = (double *)malloc(sizeof(double)*(cutoff+1));
  p2 = (double *)malloc(sizeof(double)*(lengthDelta-cutoff-1));
  ind1 = ind2 = 0;
  for(i=0;i<lengthDelta;i++) {
    if(p[i]<=cutoff+1) {
      p1[ind1] = p[i];
      ind1++;
    } else {
      p2[ind2] = p[i]-cutoff-1;
      ind2++;
    }
  }

  s1 = (double *)malloc(sizeof(double)*(cutoff+1));
  for(i=0;i<cutoff+1;i++) {
    s1[i] = sunsort1[(int)(p1[i])-1];
  }
  s2 = (double *)malloc(sizeof(double)*(lengthDelta-cutoff-1));
  for(i=0;i<lengthDelta-cutoff-1;i++) {
    s2[i] = sunsort2[(int)(p2[i])-1];
  }

  /* try putting this function call in new thread */
  SORCloopAllPairsKernel(alpha1,&delta1,sunsort1,s1,p1,Delta1,
			 cutoff+1,slackmargin);

  /* try putting this function call in new thread */
  SORCloopAllPairsKernel(alpha2,&delta2,sunsort2,s2,p2,Delta2,
			 lengthDelta-cutoff-1,slackmargin);

  switch(slackmargin) {
  case 'm':
    /* fprintf(stderr,"entering margin rescaling case\n"); */
    SORCloopMarginKernel(alpha,delta,s1,p1,s2,p2,Delta1,Delta2,cutoff+1,lengthDelta-cutoff-1);
    break;
  case 'g':
    /* fprintf(stderr,"entering ground truth error case\n"); */
    //SORCloopGTKernel(alpha,delta,s1,p1,s2,p2,Delta1,Delta2,cutoff+1,lengthDelta-cutoff-1);
    break;
  default:
    /* fprintf(stderr,"entering slack rescaling case\n"); */
    SORCloopSlackKernel(alpha,delta,s1,p1,s2,p2,Delta1,Delta2,cutoff+1,lengthDelta-cutoff-1);
    break;
  }

  *delta = *delta+delta1+delta2;

  free(s2);
  free(s1);
  free(p2);
  free(p1);

}

void SORCloopMarginKernel(double *alpha, double *delta, double *spos, double *ppos, double *sneg, double *pneg, double *Deltapos, double *Deltaneg,int lengthspos,int lengthsneg) {
  int i,j,k;
  double deltacum;
  *delta = 0;
  j = 0;
  deltacum = 0;
  for(k=0;k<lengthsneg;k++) {
    int negind = (int)(pneg[k])-1;
    while(j<lengthspos && sneg[k]>spos[j]) {
      int posind = (int)(ppos[j])-1;
      alpha[posind] += lengthsneg-k;
      deltacum += Deltapos[posind];
      j++;
    }
    alpha[negind+lengthspos] -=j;
    *delta += j*Deltaneg[negind] - deltacum;
  }
}

void SORCloopGT(double *psi, double *delta, double *Xpos, double *spos, double *ppos, double *Xneg, double *sneg, double *pneg, double *Deltapos, double *Deltaneg,int lengthw,int lengthspos,int lengthsneg) {
  int i,j,k;
  double deltacum;
  double *phipos = (double *)malloc(sizeof(double)*2*lengthw);
  double *phipos2 = phipos+lengthw;
  for(i=0;i<lengthw;i++) {
    psi[i] = 0;
    phipos[i] = 0;
    phipos2[i] = 0;
  }
  *delta = 0;
  j = 0;
  deltacum = 0;
  for(k=0;k<lengthsneg;k++) {
    int negind = (int)(pneg[k])-1;
    while(j<lengthspos && sneg[k]>=spos[j]) {
      int posind = (int)(ppos[j])-1;
      for(i=0;i<lengthw;i++) {
	phipos[i] += Deltapos[posind]*Xpos[posind*lengthw+i];
	phipos2[i] += Xpos[posind*lengthw+i];
      }
      deltacum += Deltapos[posind];
      j++;
    }
    for(i=0;i<lengthw;i++) {
      psi[i] += Deltaneg[negind]*phipos2[i] - phipos[i] - 
	(j*Deltaneg[negind]-deltacum)*Xneg[negind*lengthw+i];
    }
    
    *delta += j*Deltaneg[negind] - deltacum;
  }
  free(phipos);
}

void SORCloopSlackKernel(double *alpha, double *delta, double *spos, double *ppos, double *sneg, double *pneg, double *Deltapos, double *Deltaneg,int lengthspos,int lengthsneg) {
  int i,j,k;
  double deltacum;
  double *deltaDescend;
  deltaDescend = (double *)malloc(sizeof(double)*lengthsneg);
  deltaDescend[lengthsneg-1] = Deltaneg[(int)(pneg[lengthsneg-1])-1];
  for(k=lengthsneg-2;k>=0;k--) {
    deltaDescend[k] = deltaDescend[k+1] + Deltaneg[(int)(pneg[k])-1];
  }
  *delta = 0;
  j = 0;
  deltacum = 0;
  for(k=0;k<lengthsneg;k++) {
    int negind = (int)(pneg[k])-1;
    while(j<lengthspos && sneg[k]+1>spos[j]) {
      int posind = (int)(ppos[j])-1;
      alpha[posind] += deltaDescend[k] - Deltapos[posind]*(lengthsneg-k);
      deltacum += Deltapos[posind];
      j++;
    }
    alpha[negind+lengthspos] -= j*Deltaneg[negind] - deltacum;
    *delta += j*Deltaneg[negind] - deltacum;
  }
  free(deltaDescend);
}

int computeCutoff(double *Delta,int lengthDelta) {
  int cutoff = (int)(lengthDelta*0.5 - 0.5); /* now we have 50% on either side */
  while(cutoff>=1 && Delta[cutoff]==Delta[cutoff+1]) {
    cutoff--;
  }
  if(Delta[cutoff]!=Delta[cutoff+1]) {
    return cutoff;
  }

  cutoff = (int)(lengthDelta*0.5 - 0.5); /* now we have 50% on either side */
  while(cutoff<lengthDelta-2 && Delta[cutoff]==Delta[cutoff+1]) {
    cutoff++;
  }
  return cutoff;
}

/* end of file */
