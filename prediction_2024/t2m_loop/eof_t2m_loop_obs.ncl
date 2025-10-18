load "/disk1/fhd/function/eof_era5_regrid.ncl"
begin
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
nyear  =  29
yrStrt = 1991
yrLast = 2020

tstart= 35
tend=394

decomposition_season="JFM"

unit= ""
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_wina_era5_regrid.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
neof   = 4        ; number of EOFs
   
;iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
variabl= varible_file->winter_anom
vv=variabl(:,{latS:latN},{lonL:lonR})
vv@_FillValue = 9.96921e+36
; ==============================================================
; compute desired global seasonal mean: month_to_season (contributed.ncl)
; ==============================================================
var=new((/nyear+1,nyear,69,360/),typeof(vv))
eof_ts=new((/nyear+1,neof,nyear/),typeof(vv))
eof=new((/nyear+1,neof,69,360/),typeof(vv))
    
      var(0,:,:,:)=vv(1:nyear,:,:)
      temp = eof_func(var(0,:,:,:),latS,latN,lonL,lonR,nyear,neof)        
      eof(0,:,:,:) = temp 
      eof_ts(0,:,:)=reshape(temp@pc,(/neof,nyear/))
      
      var(nyear,:,:,:)=vv(0:nyear-1,:,:)
      temp = eof_func(var(nyear,:,:,:),latS,latN,lonL,lonR,nyear,neof)        
      eof(nyear,:,:,:) = temp 
      eof_ts(nyear,:,:)=reshape(temp@pc,(/neof,nyear/))
      
      
   do i=1,nyear-1   
     var(i,0:(i-1),:,:)=vv(0:(i-1),:,:)
     var(i,i:nyear-1,:,:)=vv((i+1):nyear,:,:)
     temp = eof_func(var(i,:,:,:),latS,latN,lonL,lonR,nyear,neof)        
     eof(i,:,:,:) = temp 
     eof_ts(i,:,:)=reshape(temp@pc,(/neof,nyear/))
     
   end do
     
   
eof!0="leave_year"
eof&leave_year=ispan(yrStrt,yrLast,1)
printVarSummary(eof)
copy_VarCoords(eof(:,:,0,0),eof_ts(:,:,0))
eof_ts!2="time"
eof_ts@time=ispan(0,nyear-1,1)
printVarSummary(eof)
printVarSummary(eof_ts)
printMinMax(eof,False)
printMinMax(eof_ts,False)
;eof=eof*-1
;eof_ts=eof_ts*-1

;eof(0,1,:,:)=eof(0,1,:,:)*-1
;eof_ts(0,1,:)=eof_ts(0,1,:)*-1

 system("rm -f /disk1/fhd/degreepaper/data/eof_t2m_leave_obs_regrid.nc")
 fout=addfile("/disk1/fhd/degreepaper/data/eof_t2m_leave_obs_regrid.nc", "c")
 fout->eof=eof
 fout->eof_ts=eof_ts



end
