load "/disk1/fhd/function/eof_prd.ncl"
begin
latS   =  70
latN   =  89
lonL   =  -180
lonR   =  180
;latS   =  70
;latN   =  85
;lonL   =  0
;lonR   =  90

nyear  =  35
yrStrt = 1981
yrLast = 2016
neof =2
tstart= 35
tend=466

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sic_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
ensemble_winter=dim_avg_n(var1,1)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)
ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)
ensemble_winter=lonFlip(ensemble_winter)


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


t2m      = addfile("/disk1/fhd/winter_forecast/data/eof_sic_nov.nc", "r")
t2m_eof=t2m->eof_ts

cc1=escorc(t2m_eof(0,1:35),eof_ts(0,0,:))
print(cc1)

if( cc1.lt.0 ) then
		eof(0,0,:,:)=eof(0,0,:,:)*-1
		eof_ts(0,0,:)=eof_ts(0,0,:)*-1
end if 


;do i=0,nyear
;   sst_t2m=escorc(eof_ts(0,0,:), eof_ts(i,0,:))
;   if( sst_t2m.lt.0 ) then
;		eof(i,0,:,:)=eof(i,0,:,:)*-1
;		eof_ts(i,0,:)=eof_ts(i,0,:)*-1
;	 end if 
;end do
;
;    eof=eof*-1
;    eof_ts=eof_ts*-1

;		eof(0,0,:,:)=eof(0,0,:,:)*-1
;		eof_ts(0,0,:)=eof_ts(0,0,:)*-1
;
;		eof(1,0,:,:)=eof(1,0,:,:)*-1
;		eof_ts(1,0,:)=eof_ts(1,0,:)*-1
;
;		eof(14,0,:,:)=eof(14,0,:,:)*-1
;		eof_ts(14,0,:)=eof_ts(14,0,:)*-1
;
;		eof(15,0,:,:)=eof(15,0,:,:)*-1
;		eof_ts(15,0,:)=eof_ts(15,0,:)*-1
;
;		eof(17,0,:,:)=eof(17,0,:,:)*-1
;		eof_ts(17,0,:)=eof_ts(17,0,:)*-1
;
;		eof(19,0,:,:)=eof(19,0,:,:)*-1
;		eof_ts(19,0,:)=eof_ts(19,0,:)*-1
;
;		eof(24,0,:,:)=eof(24,0,:,:)*-1
;		eof_ts(24,0,:)=eof_ts(24,0,:)*-1
;
;		eof(25,0,:,:)=eof(25,0,:,:)*-1
;		eof_ts(25,0,:)=eof_ts(25,0,:)*-1
;
;		eof(28,0,:,:)=eof(28,0,:,:)*-1
;		eof_ts(28,0,:)=eof_ts(28,0,:)*-1
;
;		eof(32,0,:,:)=eof(32,0,:,:)*-1
;		eof_ts(32,0,:)=eof_ts(32,0,:)*-1
;
;		eof(34,0,:,:)=eof(34,0,:,:)*-1
;		eof_ts(34,0,:)=eof_ts(34,0,:)*-1



 system("rm -f /disk1/fhd/winter_forecast/data/eof_sic_cv2.nc")
 fout=addfile("/disk1/fhd/winter_forecast/data/eof_sic_cv2.nc", "c")
 fout->eof=eof
 fout->eof_ts=eof_ts



end
