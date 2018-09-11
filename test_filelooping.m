close all;
file_list = dir('I:\output\op\*.mat');
disp(numel(file_list));
fileID = fopen('output_discriminatory.txt','w');
fprintf(fileID,'%s %s %s %s %s %s\n','#FileName','#SliceNumber','MinIntensity','MaxIntensity','#MaskedVoxels','#FinalVoxels');
fclose(fileID);
for idx = 1:numel(file_list)
%	fclose('all'); % to avoid too many files open
    % clear dicom_tags,lung_img_3d,nodule_img_3d,nodule_info,pixelsize,thick
    load (file_list(idx,1).folder+"\"+file_list(idx,1).name);
    masked_img_3d=zeros(size(lung_img_3d));
    temp_img_3d=zeros(size(lung_img_3d));
  %  for sdx=1:size(lung_img_3d,3)
    for sdx=66:66
        store=zeros;
        kt=1;
        num_maskedvoxels=0;
        num_finalvoxels=0;
        if any(any(nodule_img_3d(:,:,sdx)) > 0)
            for j=1:512
                for k=1:512
                     if(nodule_img_3d(j,k,sdx)>0)
                        masked_img_3d(j,k,sdx)=lung_img_3d(j,k,sdx);
                        num_maskedvoxels=num_maskedvoxels+1;
                        temp_img_3d(j,k,sdx)=1;
                        store(kt,1)=lung_img_3d(j,k,sdx);
                        store(kt,2)=j;
                        store(kt,3)=k;
                        kt=kt+1;
                     else
                        masked_img_3d(j,k,sdx)=-2048;
                        temp_img_3d(j,k,sdx)=0;
                     end
                end
            end
            depth=max(max(masked_img_3d(:,:,sdx)))-min(min(masked_img_3d(:,:,sdx)))
            rangedepth=depth+1;
            histvalues=zeros(rangedepth+1,1)
            for j=1:512
                for k=1:512
                    rho=masked_img_3d(j,k,sdx)+2049;
                    histvalues(rho,1)=histvalues(rho,1)+1;
                end 
            end
            histvalues(1,1)=1
      %     bar(histvalues);
            A3 = unique(histvalues(:,1));
            out1 = A3(2);
            for i=2:size(histvalues(:,1))
                if(histvalues(i,1)>0)
                    owvalue=i;
                    break;
                end
            end
            for i=size(histvalues(:,1)):-1:2
                if(histvalues(i,1)>0)
                    ighvalue=i;
                    break;
                end
            end
            lowvalue=owvalue-2048;
            highvalue=ighvalue-2048;
            %i=42;  
            for j=1:512
                for k=1:512
                    if(lung_img_3d(j,k,sdx)>lowvalue && lung_img_3d(j,k,sdx)<highvalue )
                        final_img_3d(j,k,sdx)=1;
                        num_finalvoxels=num_finalvoxels+1;
                    else
                        final_img_3d(j,k,sdx)=0;
                    end
                end
            end
            fileID = fopen('output_discriminatory.txt','a');
        %    op= [file_list(idx,1).name '  ' sdx '  ' num_maskedvoxels '  ' num_finalvoxels];
            fprintf(fileID,'%s %d %d %d %d %d \n',file_list(idx,1).name,sdx,lowvalue,highvalue,num_maskedvoxels,num_finalvoxels);
            fclose(fileID);
        end  % end of processing a single nodule_img_3d slice to find if there is a nodule
    end  % end of iterating 9through all slices of a single .mat file
    figure,imshow(lung_img_3d(:,:,sdx));
    figure,imshow(masked_img_3d(:,:,sdx));
    figure,imshow(temp_img_3d(:,:,sdx));
    figure,imshow(nodule_img_3d(:,:,sdx));
    figure,imshow(final_img_3d(:,:,sdx));
%     for zindex = 1:133
%         imshow(lung_img_3d(:,:,zindex));
%         pause(0.125);
%     end

end  % end of iterating through all the .mat files