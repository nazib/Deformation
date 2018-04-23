function [matrix]=get_deformation(lattice,l,m)

cp=(l+1)*(m+1);
B=zeros(256*256,cp);

for i=v:(256*256)
    vert.x = lattice(v,1);
    vert.y = lattice(v,2);
    
    stuVert = convert_to_stu(vert, ffd_coord);



