function nz_save_hdr(strc, fileprefix, machine)

% AVW_HDR_WRITE: Write Analyze header file (*.hdr)
% 
% avw_hdr_write(avw, fileprefix, machine)
% 
% avw        - a struct with .hdr field, which itself is a struct,
%              containing all fields of an Analyze header.
%              For details, see avw_hdr_read.m
% 
% fileprefix - a string, the filename without the .hdr extension.
%              If empty, may use avw.fileprefix
% 
% machine    - a string, see machineformat in fread for details.
%              The default here is 'ieee-le'.
% 
% See also AVW_IMG_WRITE
%

% Licence:  GNU GPL, no express or implied warranties
% History:  05/2002, Darren.Weber@flinders.edu.au
%                    The Analyze format and c code below is copyright 
%                    (c) Copyright, 1986-1995
%                    Biomedical Imaging Resource, Mayo Foundation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------------
% MAIN

fprintf('\nAVW_HDR_WRITE\n'); tic;
machine='ieee-le'

fid = fopen(sprintf('%s.hdr',fileprefix),'w');
if fid < 0,
    msg = sprintf('Cannot write to file %s.hdr\n',fileprefix);
    error(msg);
else
    fclose(fid);
    fprintf('...writing %s Analyze format.\n',machine);
    fid = fopen(sprintf('%s.hdr',fileprefix),'w',machine);
    write_header(fid,strc);
    fclose(fid);
end

return





%----------------------------------------------------------------------------

function write_header(fid,strc)
    
    header_key(fid,strc.key);
    image_dimension(fid,strc.dime);
    data_history(fid,strc.hist);
    
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function header_key(fid,hk)
    
	% Original header structures - ANALYZE 7.5
	% struct header_key                      /* header key      */ 
	%       {                                /* off + size      */
	%       int sizeof_hdr                   /*  0 +  4         */
	%       char data_type[10];              /*  4 + 10         */
	%       char db_name[18];                /* 14 + 18         */
	%       int extents;                     /* 32 +  4         */
	%       short int session_error;         /* 36 +  2         */
	%       char regular;                    /* 38 +  1         */
	%       char hkey_un0;                   /* 39 +  1         */
	%       };                               /* total=40 bytes  */
    
    fseek(fid,0,'bof');
    
    fwrite(fid, hk.sizeof_hdr,   'int32');    % must be 348!
    
    data_type = sprintf('%-10s',hk.data_type); % ensure it is 10 chars
    fwrite(fid, hk.data_type,    'uchar');
    
    db_name   = sprintf('%-18s',hk.db_name);   % ensure it is 18 chars
    fwrite(fid, db_name,         'uchar');
    
    fwrite(fid, hk.extents,      'int32');
    fwrite(fid, hk.session_error,'int16');
    
    regular   = sprintf('%1s',hk.regular);    % ensure it is 1 char
    fwrite(fid, regular,         'uchar');
    
    hkey_un0  = sprintf('%1s',hk.hkey_un0);   % ensure it is 1 char
    fwrite(fid, hkey_un0,        'uchar');
    
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function image_dimension(fid,dime)
	%struct image_dimension
	%       {                                /* off + size      */
	%       short int dim[8];                /* 0 + 16          */
	%       char vox_units[4];               /* 16 + 4          */
	%       char cal_units[8];               /* 20 + 8          */
	%       short int unused1;               /* 28 + 2          */
	%       short int datatype;              /* 30 + 2          */
	%       short int bitpix;                /* 32 + 2          */
	%       short int dim_un0;               /* 34 + 2          */
	%       float pixdim[8];                 /* 36 + 32         */
	%			/*
	%				pixdim[] specifies the voxel dimensions:
	%				pixdim[1] - voxel width
	%				pixdim[2] - voxel height
	%				pixdim[3] - interslice distance
	%					..etc
	%			*/
	%       float vox_offset;                /* 68 + 4          */
	%       float roi_scale;                 /* 72 + 4          */
	%       float funused1;                  /* 76 + 4          */
	%       float funused2;                  /* 80 + 4          */
	%       float cal_max;                   /* 84 + 4          */
	%       float cal_min;                   /* 88 + 4          */
	%       int compressed;                  /* 92 + 4          */
	%       int verified;                    /* 96 + 4          */
	%       int glmax;                       /* 100 + 4         */
	%       int glmin;                       /* 104 + 4         */
	%       };                               /* total=108 bytes */
    
	fwrite(fid, dime.dim,        'int16');
	fwrite(fid, dime.vox_units,  'uchar');
	fwrite(fid, dime.cal_units,  'uchar');
	fwrite(fid, dime.unused1,    'int16');
	fwrite(fid, dime.datatype,   'int16');
	fwrite(fid, dime.bitpix,     'int16');
	fwrite(fid, dime.dim_un0,    'int16');
	fwrite(fid, dime.pixdim,     'float32');
	fwrite(fid, dime.vox_offset, 'float32');
    
    % Ensure compatibility with SPM (according to MRIcro)
    if dime.roi_scale == 0, dime.roi_scale = 0.00392157; end
	fwrite(fid, dime.roi_scale,  'float32');
    
	fwrite(fid, dime.funused1,   'float32');
	fwrite(fid, dime.funused2,   'float32');
	fwrite(fid, dime.cal_max,    'float32');
	fwrite(fid, dime.cal_min,    'float32');
	fwrite(fid, dime.compressed, 'int32');
	fwrite(fid, dime.verified,   'int32');
	fwrite(fid, dime.glmax,      'int32');
	fwrite(fid, dime.glmin,      'int32');
	
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data_history(fid,hist)
	% Original header structures - ANALYZE 7.5
	%struct data_history       
	%       {                                /* off + size      */
	%       char descrip[80];                /* 0 + 80          */
	%       char aux_file[24];               /* 80 + 24         */
	%       char orient;                     /* 104 + 1         */
	%       char originator[10];             /* 105 + 10        */
	%       char generated[10];              /* 115 + 10        */
	%       char scannum[10];                /* 125 + 10        */
	%       char patient_id[10];             /* 135 + 10        */
	%       char exp_date[10];               /* 145 + 10        */
	%       char exp_time[10];               /* 155 + 10        */
	%       char hist_un0[3];                /* 165 + 3         */
	%       int views                        /* 168 + 4         */
	%       int vols_added;                  /* 172 + 4         */
	%       int start_field;                 /* 176 + 4         */
	%       int field_skip;                  /* 180 + 4         */
	%       int omax;                        /* 184 + 4         */
	%       int omin;                        /* 188 + 4         */
	%       int smax;                        /* 192 + 4         */
	%       int smin;                        /* 196 + 4         */
	%       };                               /* total=200 bytes */
	
	fwrite(fid, hist.descrip,    'uchar');
	fwrite(fid, hist.aux_file,   'uchar');
	fwrite(fid, hist.orient,     'uchar');
	fwrite(fid, hist.originator, 'uchar');
	fwrite(fid, hist.generated,  'uchar');
	fwrite(fid, hist.scannum,    'uchar');
	fwrite(fid, hist.patient_id, 'uchar');
	fwrite(fid, hist.exp_date,   'uchar');
	fwrite(fid, hist.exp_time,   'uchar');
	fwrite(fid, hist.hist_un0,   'uchar');
	fwrite(fid, hist.views,      'int32');
	fwrite(fid, hist.vols_added, 'int32');
	fwrite(fid, hist.start_field,'int32');
	fwrite(fid, hist.field_skip, 'int32');
	fwrite(fid, hist.omax,       'int32');
	fwrite(fid, hist.omin,       'int32');
	fwrite(fid, hist.smax,       'int32');
	fwrite(fid, hist.smin,       'int32');
	
return
