import nibabel as nib
import numpy as np
import numpy.matlib
#import matplotlib.pyplot as plt
import os 
import glob
import time
from time import localtime, strftime
from subprocess import call
import sys
#import cv2

def mean_square(vol1,vol2):
  m=vol1.shape[2]
  n=vol2.shape[2]
  
  if m>n:
    d=m-n
    slices=np.zeros([vol1.shape[0],vol2.shape[1],d+n])
    slices[:,:,0:n]=vol2
    vol2=slices
  else:
    d=n-m
    slices=np.zeros([vol1.shape[0],vol2.shape[1],d+m])
    slices[:,:,0:m]=vol1
    vol1=slices
    m,n,c=vol1.shape
    
  diff=vol2-vol1
  diff=np.power(diff,2)
  #div=m*n*c

  #meansq=sum(sum(sum(diff)))/div
  mse=np.mean(np.mean(np.mean(diff)))
  #mse2=((vol1 -vol2) ** 2).mean(axis=None)
  
  return mse

def mean_vol(vol):
  [r,c,s]=vol.shape
  mean_im=np.zeros([r,c])
  
  for i in range(s):
    mean_im=mean_im+vol[:,:,i]
 
  mean_vol=np.divide(mean_im,s)
  mean_vol=mean_vol[:,:,np.newaxis] ## This is for similarity of matlab function repmat()
  mean_vol=np.tile(mean_vol,(1,s))
  return mean_vol

def volume_cross(vol1,vol2):
  m=vol1.shape[2]
  n=vol2.shape[2]
  
  if m>n:
    d=m-n
    slices=np.zeros([vol1.shape[0],vol2.shape[1],d+n])
    slices[:,:,0:n]=vol2
    vol2=slices
  else:
    d=n-m
    slices=np.zeros([vol1.shape[0],vol2.shape[1],d+m])
    slices[:,:,0:m]=vol1
    vol1=slices

  m_vol1=mean_vol(vol1)
  m_vol2=mean_vol(vol2)

  diff1=vol1-m_vol1
  diff2=vol2-m_vol2
  nom=sum(sum(sum(np.multiply(diff1,diff2))))
  p1=sum(sum(sum(np.power(diff1,2))))
  p2=sum(sum(sum(np.power(diff2,2))))
  dnom=np.sqrt(np.multiply(p1,p2))
  CC=nom/dnom
  return CC
      

def volume_binarize(vol):
  [m,n,c]=vol.shape
  bwvol=np.zeros(vol.shape)
  
  for i in range(c):
    im=np.uint8(vol[:,:,i])
    #bwim=np.zeros(im.shape)
    level,bwim=cv2.threshold(im,0,255,cv2.THRESH_BINARY)
    bwvol[:,:,i]=bwim
    
  return bwvol

def volume_dice(vol1,vol2):
  m=vol1.shape[2]
  n=vol2.shape[2]
  
  if m>n:
    d=m-n
    slices=np.zeros([vol1.shape[0],vol2.shape[1],d+n])
    slices[:,:,0:n]=vol2
    vol2=slices
  else:
    d=n-m
    slices=np.zeros([vol1.shape[0],vol2.shape[1],d+m])
    slices[:,:,0:m]=vol1
    vol1=slices
    
  bwvol1=volume_binarize(vol1)
  bwvol2=volume_binarize(vol2)
  
#  inter=(np.uint8(bwvol1) & np.uint8(bwvol2))
#  [ri,ci,vi]=np.where(inter>0)
#  common_region=sum(ri);
#  [r1,c1,v1]=np.where(bwvol1>0);
#  vol1_region=sum(r1); 
#  [r2,c2,v2]=np.where(bwvol2>0);
#  vol2_region=sum(r2);
#  denom=np.abs(vol1_region)+np.abs(vol2_region)
  
  dice=np.sum(bwvol1[bwvol2>0])*2.0 / (np.sum(bwvol1)+np.sum(bwvol2))
  
  return dice

def dim_check(vol):
  if (len(vol.shape)>3):
      vol=vol[:,:,:,0]
      vol[np.isnan(vol)]=0.0
  else:
      vol=vol
      vol[np.isnan(vol)]=0.0

    
  return vol

def mutual_info(vol1,vol2,bin):
  m=vol1.shape[2]
  n=vol2.shape[2]
  
  if m>n:
    d=m-n
    slices=np.zeros([vol1.shape[0],vol2.shape[1],d+n])
    slices[:,:,0:n]=vol2
    vol2=slices
  else:
    d=n-m
    slices=np.zeros([vol1.shape[0],vol2.shape[1],d+m])
    slices[:,:,0:m]=vol1
    vol1=slices
  
  h,x_edges,y_edges=np.histogram2d(vol1.ravel(),vol2.ravel(),bins=bin)
  pxy=h/np.sum(h)
  px = np.sum(pxy, axis=1) 
  py = np.sum(pxy, axis=0) # marginal for y over x
  px_py = px[:, None] * py[None, :] # Broadcast to multiply marginals
  # Now we can do the calculation using the pxy, px_py 2D arrays
  nzs = pxy > 0 # Only non-zero pxy values contribute to the sum
  return np.sum(pxy[nzs] * np.log(pxy[nzs] / px_py[nzs]))



def measurment(nifti1,nifti2):
  
  im1=nib.load(nifti1)
  im2=nib.load(nifti2)

  vol1=im1.get_data()
  vol2=im2.get_data()
  
  vol1=dim_check(vol1)
  vol2=dim_check(vol2)
  
  cross=volume_cross(vol1,vol2)
  #dice=volume_dice(vol1,vol2)
  #mse=mean_square(vol1,vol2)
  mi=mutual_info(vol1,vol2,30)
  return cross,mi
  #print("Cross=",cross,"Dice=",dice)
  

















