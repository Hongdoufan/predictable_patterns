begin

output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "cv_weight_matrix_1out1.nc" 

 nfactors=5
 nyear=36
 matrix=addfile("/disk1/fhd/winter_forecast/data/cv_matrix_1out1.nc","r")
 R=matrix->R
 r=matrix->r
 
 weight   = new( (/nyear,nfactors/), typeof(r))
 printVarSummary(R)
 printVarSummary(r) 
 
 do i=0,35
   weight(i,:)=(inverse_matrix(r(i,:,:))#R(i,:))
 end do
print(weight)
printVarSummary(weight)

 system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->weight=weight


end 
