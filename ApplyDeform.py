import numpy as np 
import nibabel as nb 
import glob
from scipy.interpolate import griddata
from PIL import Image
from scipy.stats import multivariate_normal
#from matplotlib import pyplot as plt

def kernel(X,Y,mu,sigma):
    mvn = multivariate_normal(mu,sigma)
    
    m,n=X.shape
    X=np.reshape(X,[1,m*n])
    Y=np.reshape(Y,[1,m*n])

    d=np.concatenate((X,Y),axis=0)
    d=np.transpose(d)

    pdf=mvn.pdf(d)
    u=np.reshape(pdf,[m,n])
    v=np.transpose(u)
    return u,v


######## Directory structure ######
#reg_scale="15%"
#data_folder=reg_scale+"_data/"
data_dir="/media/nazib/Store/imagedeformation/data/"

nfiles=glob.glob(data_dir+"*.nii.gz")

for i in range(len(nfiles)):

    vol=nb.load(nfiles[i])
    img=vol.get_data()

    m,n,c=img.shape

    for s in range(c):
        slice=img[:,:,s]
        slice=Image.fromarray(slice)
        slice=slice.resize((500,500),Image.BICUBIC)
        H=slice.height
        
        xcor=np.linspace(-1,1,slice.width/2)
        ycor=np.linspace(-1,1,slice.height/2)
        X,Y=np.meshgrid(xcor,ycor)
        

        ###### Applying Gaussian Distribution #####
        mu=np.zeros(2)
        sigma=np.zeros(2)
        sigma[0]=0.1
        sigma[1]=0.1
        u,v=kernel(X,Y,mu,sigma)
	    
        k=slice.height/2
        slice=np.asarray(slice)

        #1st quadrent
        xcor=np.linspace(-1,1,k)
        ycor=np.linspace(-1,1,k)
        X,Y=np.meshgrid(xcor,ycor)
        

        sigma[0]=0.1
        sigma[1]=0.1
        u1,v1=kernel(X,Y,mu,sigma)
        im1=slice[0:k,0:k]
        nX=X-u1
        nY=Y-v1

        new_im1=griddata((nX.flatten(),nY.flatten()),im1.flatten(),(X.flatten(),Y.flatten()),method='cubic',fill_value=0)
        new_im1=np.reshape(new_im1,(k,k))

        #2nd quadrent
        im2=slice[0:k,k:H]
        nX=X+u1
        nY=Y-v1
        new_im2=griddata((nX.flatten(),nY.flatten()),im2.flatten(),(X.flatten(),Y.flatten()),method='cubic',fill_value=0)
        new_im2=np.reshape(new_im2,[k,k])
        
        #3rd quadrent
        im3=slice[k:H,0:k]
        nX=X-u1
        nY=Y+v1
        new_im3=griddata((nX.flatten(),nY.flatten()),im3.flatten(),(X.flatten(),Y.flatten()),method='cubic',fill_value=0)
        new_im3=np.reshape(new_im3,[k,k])

        #4th Quadrent
        im4=slice[k:H,k:H]
        nX=X+u1
        nY=Y+v1
        new_im4=griddata((nX.flatten(),nY.flatten()),im4.flatten(),(X.flatten(),Y.flatten()),method='cubic',fill_value=0)
        new_im4=np.reshape(new_im4,[k,k])
        
        
        m1=np.concatenate((new_im1,new_im2),axis=1)
        m2=np.concatenate((new_im3,new_im4),axis=1)
        newim=np.concatenate((m1, m2),axis=0)

        newim=Image.fromarray(newim)
        newim=newim.resize((n,m),Image.BICUBIC)
        newim=np.asarray(newim)
    
        img[:,:,s]=newim
        print "Slice:"+str(s)


    name=nfiles[i]
    d_name=name[0:len(name)-11]+"_deform.nii.gz"
    nvol=nb.Nifti1Image(img,vol.affine,vol.header)
    nb.save(nvol,d_name)
    print "Done "+str(i)

    









        







