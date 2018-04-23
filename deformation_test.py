import numpy as np
import cv2
import SimpleITK as sitk
import nibabel as nib
import scipy
import glob
from scipy.ndimage.filters import gaussian_filter
from scipy.stats import multivariate_normal
from scipy.interpolate import griddata
from matplotlib import pyplot as plt
from sklearn import preprocessing



def kernel(X,Y,mu,sigma):
    
    mvn = multivariate_normal(mu,sigma)
    m,n,c=X.shape
    
    X=np.reshape(X,[1,m*n*c])
    Y=np.reshape(Y,[1,m*n*c])
    #Z=np.reshape(Z,[1,m*n*c])
    

    d=np.concatenate((X,Y),axis=0)
    d=np.transpose(d)

    pdf=mvn.pdf(d)
    
    u=np.reshape(pdf,[m,n,c])
    
    return u

def volume_binarize(vol):
  [m,n,c]=vol.shape
  bwvol=np.zeros(vol.shape,dtype=float)
  
  for i in range(c):
    im=vol[:,:,i]
    #bwim=np.zeros(im.shape)
    level,bwim=cv2.threshold(im,500.0,1,cv2.THRESH_BINARY)
    bwvol[:,:,i]=bwim.astype(float)
    
  return bwvol

def select_pts(im,Pts,above_zero):

  m,n,c=im.shape
  RDFx=np.zeros([m,n,c],dtype=np.float64)
  RDFy=np.zeros([m,n,c],dtype=np.float64)
  RDFz=np.zeros([m,n,c],dtype=np.float64)

  k=0
  while((k<Pts) & (len(above_zero[0])>0)):
    voxel_idx=long(np.random.randint(0,len(above_zero[0])-1,1,dtype=np.int64))
    
    x=above_zero[0][voxel_idx]
    y=above_zero[1][voxel_idx]
    z=above_zero[1][voxel_idx]

    Dx = ((np.random.ranf([1]))[0]-0.5)*100
    Dy = ((np.random.ranf([1]))[0]-0.5)*100 
    Dz = ((np.random.ranf([1]))[0]-0.5)*100

    RDFx[x,y,z]=Dx
    RDFy[x,y,z]=Dy
    RDFy[x,y,z]=Dz


    print(" Dx="+str(Dx)+" Dy="+str(Dy))
    #print str(k)
    k+=1

  return RDFx,RDFy,RDFz

def normalize(vol):

  Min=np.min(vol)
  Max=np.max(vol)
  m,n,c=vol.shape
  amin=np.tile(Min,[m,n,c])

  nom=(vol-amin)/(Max-Min)

  return nom


  
def deform(im):
  im=im.T
  m,n,c=im.shape
  vol=volume_binarize(im)
  above_zero=np.where(vol==1)
  
  x=np.linspace(-1,1,m)
  y=np.linspace(-1,1,n)
  z=np.linspace(-1,1,c)
  
  cx,cy,cz=np.meshgrid(z,x,y)

  xx,yy,zz=select_pts(vol,150,above_zero)

  RDFxf=gaussian_filter(xx,sigma=10)
  RDFyf=gaussian_filter(yy,sigma=10)
  RDFzf=gaussian_filter(zz,sigma=10)
  
  RDF=np.zeros([m,n,c,3],dtype=np.float64)
  RDF[:,:,:,0]=RDFxf
  RDF[:,:,:,1]=RDFyf
  RDF[:,:,:,2]=RDFzf

  imgg=sitk.ReadImage('1-1_nuclear.nii.gz')

  RDFobj=sitk.GetImageFromArray(RDF,isVector=True)
  RDFobj.SetOrigin(imgg.GetOrigin())
  RDFobj.SetSpacing(imgg.GetSpacing())
  RDFobj.SetDirection(imgg.GetDirection())
  RDFobj=sitk.DisplacementFieldTransform(RDFobj)

  new_im=sitk.Resample(imgg,RDFobj)

  return new_im


img=nib.load("1-1_nuclear.nii.gz")
im=img.get_data()

for i in range(10):

  print("For image "+str(i+1))
  deformed=deform(im)
  file_name="1-1_nuclear_def_"+str(i+1)+".nii.gz"
  sitk.WriteImage(sitk.Cast(deformed, sitk.sitkVectorFloat32),file_name)

print "Done "

'''
  x=np.linspace(-1,1,m)
  y=np.linspace(-1,1,n)
  z=np.linspace(-1,1,c)

  xx,yy,zz=np.meshgrid(x,y,z)

  mu=np.array([0,0])
  sigma=np.array([0.7,0.7])

  u=kernel(xx,yy,mu,sigma)

  xx=xx+u*np.sin(30)
  yy=yy+u
  zz=zz+u

  xx=gaussian_filter(xx,sigma=35)
  yy=gaussian_filter(yy,sigma=35)
  zz=gaussian_filter(zz,sigma=35)
  '''












  




