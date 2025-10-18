load "/disk1/fhd/function/eof_prd.ncl"
begin
latS   =  40
latN   =  75
lonL   =  70
lonR   =  125
nyear  =  35
yrStrt = 1981
yrLast = 2016
neof =2
tstart= 35
tend=466

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sd_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
ensemble_winter=dim_avg_n(var1,1)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)
ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)

vv    = ensemble_winter(:,{latS:latN},{lonL:lonR})
lat   = vv&latitude
lon   = vv&longitude
eof=new((/36,neof,dimsizes(lat),dimsizes(lon)/),typeof(vv))
var=new((/36,nyear,dimsizes(lat),dimsizes(lon)/),typeof(vv))
eof_ts=new((/36,neof,nyear/),typeof(vv))

      var(0,:,:,:)=vv(1:35,:,:)
      temp = eof_func_prd(var(0,:,:,:),latS,latN,lonL,lonR,nyear,neof)        
      eof(0,:,:,:) = temp 
      eof_ts(0,:,:)=reshape(temp@pc,(/neof,nyear/))
      
      var(35,:,:,:)=vv(0:34,:,:)
      temp = eof_func_prd(var(35,:,:,:),latS,latN,lonL,lonR,nyear,neof)        
      eof(35,:,:,:) = temp 
      eof_ts(35,:,:)=reshape(temp@pc,(/neof,nyear/))
      
      
   do i=1,34   
     var(i,0:(i-1),:,:)=vv(0:(i-1),:,:)
     var(i,i:34,:,:)=vv((i+1):35,:,:)
     temp = eof_func_prd(var(i,:,:,:),latS,latN,lonL,lonR,nyear,neof)        
     eof(i,:,:,:) = temp 
     eof_ts(i,:,:)=reshape(temp@pc,(/neof,nyear/))
     
   end do
     
   
eof!0="leave_year"
eof&leave_year=ispan(yrStrt,yrLast,1)
printVarSummary(eof)
copy_VarCoords(eof(:,:,0,0),eof_ts(:,:,0))
eof_ts!2="time"
eof_ts@time=ispan(0,34,1)
printVarSummary(eof)
printVarSummary(eof_ts)

 system("rm -f /disk1/fhd/winter_forecast/data/eof_sd_cv.nc")
 fout=addfile("/disk1/fhd/winter_forecast/data/eof_sd_cv.nc", "c")
 fout->eof=eof
 fout->eof_ts=eof_ts



end