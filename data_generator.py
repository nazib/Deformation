######## Data generation Module ########
# This module generates synthetic 8000 Brain from 16 CUBIC brain dataset
# Applies flips in X, Y,Z and XYZ directions 
# Applies 100 random deformation iteratively on each flipped image and thus we get 8000 new synthetic image
import numpy as np
import cv2
import SimpleITK as sitk
import nibabel as nib
import scipy
import glob
from scipy.ndimage.filters import gaussian_filter
from scipy.interpolate import griddata
from measurment import*

data_dir="/home/n9614885/myvoxelmorph/data/vols/train/"
synthetic_dir="/home/n9614885/myvoxelmorph/data/vols/train/synthetic/"
'''
data_dir="/run/user/1000/gvfs/smb-share:server=hpc-fs.qut.edu.au,share=n9614885/myvoxelmorph/data/vols/train/"
synthetic_dir="/run/user/1000/gvfs/smb-share:server=hpc-fs.qut.edu.au,share=n9614885/myvoxelmorph/data/vols/train/synthetic/"
'''
maxdeform=2
Points=50
im_shape=[96,256,256]
sigmaD=[7,15,35]
Border=50
DistanceDeform=10
DistanceArea=10

im_list=list();
im_list_x=list();
im_list_y=list();
im_list_z=list();
im_list_xyz=list();

def volume_binarize(vol):
  [m,n,c]=vol.shape
  bwvol=np.zeros(vol.shape,dtype=float)
  
  for i in range(c):
    im=vol[:,:,i]
    #bwim=np.zeros(im.shape)
    level,bwim=cv2.threshold(im,500,1,cv2.THRESH_BINARY)
    bwvol[:,:,i]=bwim.astype(float)
    
  return bwvol

def data_read():
    file_names=glob.glob(data_dir+"/*.nii.gz")
    file_names.sort()
    itr=0
    
    for i in range(0,len(file_names)):
        if (i==4 or i==9 or i==14 or i==19):
            continue
        else:
            im_list.append([])
            im_list[itr].append(nib.load(file_names[i]))
            im_list[itr].append(file_names[i])
            itr=itr+1
            print " Image:"+file_names[i]
    return im_list

def change_ori(indt,d):
    
    comb_list=list();

    if (indt==0 or indt==1 or indt==2):
        
        for i in range(0,len(im_list)):
            obj=im_list[i][0].get_data()
            obj=np.flip(obj,axis=indt)
            img=nib.Nifti1Image(obj,im_list[i][0].affine)
            file_name=im_list[i][1]
            file_name=synthetic_dir+file_name[len(file_name)-18:].strip(".nii.gz")
            file_name=file_name+"_"+d+".nii.gz"
            nib.save(img,file_name)
            comb_list.append([])
            comb_list[i].append(img)
            comb_list[i].append(file_name)
    
    else:
        for i in range(0,len(im_list)):
            obj=im_list[i][0].get_data()
            obj=np.flip(obj,axis=0)
            obj=np.flip(obj,axis=1)
            obj=np.flip(obj,axis=2)
            img=nib.Nifti1Image(obj,im_list[i][0].affine)
            file_name=im_list[i][1]
            file_name=synthetic_dir+file_name[len(file_name)-18:].strip(".nii.gz")
            file_name=file_name+"_"+d+".nii.gz"
            nib.save(img,file_name)
            comb_list.append([])
            comb_list[i].append(img)
            comb_list[i].append(file_name)
    
    return comb_list
            
def deformation(loaded_list,d):

    RDF=np.zeros([im_shape[0],im_shape[1],im_shape[2],3],dtype=np.float64)
    RDFx=np.zeros(im_shape,dtype=np.float64)
    RDFy=np.zeros(im_shape,dtype=np.float64)
    RDFz=np.zeros(im_shape,dtype=np.float64)
    RDFxf=np.zeros(im_shape,dtype=np.float64)
    RDFyf=np.zeros(im_shape,dtype=np.float64)
    RDFzf=np.zeros(im_shape,dtype=np.float64)
    BorderMask= np.zeros(im_shape,dtype=np.float64)
    
    for i in range(len(loaded_list)-15):
        img=loaded_list[i][0].get_data()
        img=img.T
        imgbw=volume_binarize(img)
        above_zero=np.where(imgbw>0)
        #below_zero=np.where(img<=1000)
        
        for j in range(10):

            if j<60:
                sigma=sigmaD[0]
            elif j<80:
                sigma=sigmaD[1]
            else:
                sigma=sigmaD[2]
                
            #BorderMask[Border:im_shape[0] - Border + 1, Border:im_shape[1] - Border + 1, Border:im_shape[2] - Border + 1] = 1
            #above_zero=np.where(BorderMask>0)
            k=0
            while(k<Points):
                voxel_idx=long(np.random.randint(0,len(above_zero[0])-1,1,dtype=np.int64))
                z=above_zero[0][voxel_idx]
                y=above_zero[1][voxel_idx]
                x=above_zero[2][voxel_idx]
                
                Dx = ((np.random.ranf([1]))[0] - 0.5) * maxdeform * 2
                Dy = ((np.random.ranf([1]))[0] - 0.5) * maxdeform * 2
                Dz = ((np.random.ranf([1]))[0] - 0.5) * maxdeform * 2
                '''
                Dx=np.random.uniform(np.min(img),np.max(img))
                Dy=np.random.uniform(np.min(img),np.max(img))
                Dz=np.random.uniform(np.min(img),np.max(img))
                '''
                RDFx[z,y,x]=Dx
                RDFy[z,y,x]=Dy
                RDFz[z,y,x]=Dz

                #print "Point:"+str(k)
                k += 1
            
            #del BorderMask

            RDFxf= gaussian_filter(RDFx, sigma=sigma)
            RDFyf= gaussian_filter(RDFy, sigma=sigma)
            RDFzf= gaussian_filter(RDFz, sigma=sigma)
            

            ####################################### Normalization #############################################
            IXp = np.where(RDFxf > 0)
            IXn = np.where(RDFxf < 0)
            IYp = np.where(RDFyf > 0)
            IYn = np.where(RDFyf < 0)
            IZp = np.where(RDFzf > 0)
            IZn = np.where(RDFzf < 0)

            
            #### Normalizing x-direction ###
            RDFxf[IXp] = (
            (np.max(RDFx) - 0) / (np.max(RDFxf[IXp]) - np.min(RDFxf[IXp])) * (RDFxf[IXp] - np.min(RDFxf[IXp])) + 0)
            RDFxf[IXn] = (
            (0 - np.min(RDFxf[IXn])) / (0 - np.min(RDFxf[IXn])) * (RDFxf[IXn] - np.min(RDFxf[IXn])) + np.min(RDFxf[IXn]))

            #### Normalizing y-direction ####
            RDFyf[IYp] = (
            (np.max(RDFy) - 0) / (np.max(RDFyf[IYp]) - np.min(RDFyf[IYp])) * (RDFyf[IYp] - np.min(RDFyf[IYp])) + 0)
            RDFyf[IYn] = (
            (0 - np.min(RDFyf[IYn])) / (0 - np.min(RDFyf[IYn])) * (RDFyf[IYn] - np.min(RDFyf[IYn])) + np.min(RDFyf[IYn]))

            #######Normalizing z-direction ####
            RDFzf[IZp] = (
            (np.max(RDFz) - 0) / (np.max(RDFzf[IZp]) - np.min(RDFzf[IZp])) * (RDFzf[IZp] - np.min(RDFzf[IZp])) + 0)
            RDFzf[IZn] = (
            (0 - np.min(RDFzf[IZn])) / (0 - np.min(RDFzf[IZn])) * (RDFzf[IZn] - np.min(RDFzf[IZn])) + np.min(RDFzf[IZn]))
            
            RDF[:,:,:,0]=RDFxf
            RDF[:,:,:,1]=RDFyf
            RDF[:,:,:,2]=RDFzf
            
            
            RDFobj = sitk.GetImageFromArray(RDF, isVector=True)
            #RDFobj = sitk.AdditiveGaussianNoise(RDFobj,5, 0, 0)
            imgObj = sitk.ReadImage(loaded_list[i][1])
            RDFobj.SetOrigin(imgObj.GetOrigin())
            RDFobj.SetSpacing(imgObj.GetSpacing())
            RDFobj.SetDirection(imgObj.GetDirection())
	    
	    
            RDFtr= sitk.DisplacementFieldTransform(RDFobj)
            DefomedIm = sitk.Resample(imgObj,RDFtr)
            DefomedIm = sitk.AdditiveGaussianNoise(DefomedIm,5, 0, 0)
            
            #DefomedIm = sitk.GetArrayFromImage(DefomedIm)
            #DefomedIm = DefomedIm.T
            #deformedimg=nib.Nifti1Image(DefomedIm,loaded_list[i][0].affine)
            
            file_name=loaded_list[i][1]
            file_name=synthetic_dir+file_name[len(file_name)-20:].strip(".nii.gz")
            def_name=file_name+"_"+str(sigma)+"_"+str(j)+"def.nii.gz"
            file_name=file_name+"_"+str(sigma)+"_"+str(j)+".nii.gz"
            #nib.save(deformedimg,file_name)
            sitk.WriteImage(sitk.Cast(DefomedIm, sitk.sitkVectorFloat32), file_name)

            T_RDF=np.zeros([im_shape[1],im_shape[2],im_shape[0],3],dtype=np.float64)
            T_RDF[:,:,:,0]=RDF[:,:,:,0].T
            T_RDF[:,:,:,1]=RDF[:,:,:,1].T
            T_RDF[:,:,:,2]=RDF[:,:,:,2].T            
            deform=nib.Nifti1Image(T_RDF,loaded_list[i][0].affine)
            nib.save(deform,def_name)
            
            RDFxf[:,:,:]=0.0
            RDFyf[:,:,:]=0.0
            RDFzf[:,:,:]=0.0
            RDFx[:,:,:]=0.0
            RDFy[:,:,:]=0.0
            RDFz[:,:,:]=0.0
            DefomedIm = sitk.GetArrayFromImage(DefomedIm)
            DefomedIm = DefomedIm.T
            cc=volume_cross(img.T,DefomedIm)
            mi=mutual_info(img.T,DefomedIm,30)
            print ("cc "+str(cc)+" mi "+str(mi))
            #sitk.WriteImage(sitk.Cast(RDFobj, sitk.sitkVectorFloat32), def_name)
            

            
            

if __name__=="__main__":
    
    im_list=data_read()
    ### Direction Changes ###
    im_list_x=change_ori(0,"x")
    #im_list_y,y_names=change_ori(1,"y")
    #im_list_z,z_names=change_ori(2,"z")
    #im_list_z,z_names=change_ori(3,"xyz")
    deformation(im_list_x,"x")

    

    

    
