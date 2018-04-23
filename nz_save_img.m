function nz_save_img(strc, filename)


machine='ieee-le';
switch double(strc.dime.datatype)
case   1
    strc.dime.bitpix = int16( 1); precision = 'bit1';
case   2,
    strc.dime.bitpix = int16( 8); precision = 'uchar';
case   4,
    strc.dime.bitpix = int16(16); precision = 'int16';
case   8,
    strc.dime.bitpix = int16(32); precision = 'int32';
case  16,
    strc.dime.bitpix = int16(32); precision = 'single';
case  32,
    fprintf('...complex not yet supported.\n'); return;
case  64,
    strc.dime.bitpix = int16(64); precision = 'double';
case 128,
    fprintf('...RGB not yet supported.\n'); return;
otherwise
    fprintf('...unknown datatype, using type 16 (32 bit floats).\n');
    strc.dime.bitpix = int16(32); precision = 'single';
end


% write the .img file, depending on the .img orientation
fprintf('...writing %s precision Analyze image (%s).\n',precision,machine);
fid = fopen(sprintf('%s.img',filename),'w',machine);
if fid < 0,
    msg = sprintf('Cannot open file %s.img\n',filename);
    error(msg);
else
    write_image(fid,strc,filename,machine,precision);
end


end

function write_image(fid,strc,fileprefix,machine,precision)


fseek(fid,0,'bof');

% The standard image orientation is axial unflipped
if double(strc.hist.orient),
    msg = sprintf('...This function assumes the input avw.img is\n',...
                  '   in axial unflipped orientation in memory.  This is\n',...
                  '   created by the avw_img_read function, which converts\n',...
                  '   any input file image to axial unflipped in memory.\n');
    warning(msg);
end

 fprintf('...writing axial unflipped\n');
    
    strc.hist.orient = char(0);
    
    SliceDim = double(strc.dime.dim(4)); % z
    RowDim   = double(strc.dime.dim(3)); % y
    PixelDim = double(strc.dime.dim(2)); % x
    SliceSz  = double(strc.dime.pixdim(4));
    RowSz    = double(strc.dime.pixdim(3));
    PixelSz  = double(strc.dime.pixdim(2));
    
    x = 1:PixelDim;
    for z = 1:SliceDim,
        for y = 1:RowDim,
            fwrite(fid,strc.vol(x,y,z),precision);
        end
    end
fclose(fid);

% Update and Write the file header
strc.dime.dim(2) = PixelDim;
strc.dime.dim(3) = RowDim;
strc.dime.dim(4) = SliceDim;

strc.dime.pixdim(2) = PixelSz;
strc.dime.pixdim(3) = RowSz;
strc.dime.pixdim(4) = SliceSz;

nz_save_hdr(strc,fileprefix);

end