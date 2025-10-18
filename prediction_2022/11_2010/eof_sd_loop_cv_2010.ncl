load "/disk1/fhd/function/eof_prd.ncl"
begin
latS   =  45
latN   =  75
lonL   =  20
lonR   =  130


nyear  =  29
yrStrt = 1981
yrLast = 2010
neof =2
tstart= 35
tend=394

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sd_in11_6mon_wina_2010.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
ensemble_winter=dim_avg_n(var1,1)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)
;ensemble_winter=lonFlip(ensemble_winter)
ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)

vv    = ensemble_winter(:,{latS:latN},{lonL:lonR})
lat   = vv&latitude
lon   = vv&longitude
eof=new((/nyear+1,neof,dimsizes(lat),dimsizes(lon)/),typeof(vv))
var=new((/nyear+1,nyear,dimsizes(lat),dimsizes(lon)/),typeof(vv))
eof_ts=new((/nyear+1,neof,nyear/),typeof(vv))

      var(0,:,:,:)=vv(1:nyear,:,:)
      temp = eof_func_prd(var(0,:,:,:),latS,latN,lonL,lonR,nyear,neof)        
      eof(0,:,:,:) = temp 
      eof_ts(0,:,:)=reshape(temp@pc,(/neof,nyear/))
      
      var(nyear,:,:,:)=vv(0:nyear-1,:,:)
      temp = eof_func_prd(var(nyear,:,:,:),latS,latN,lonL,lonR,nyear,neof)        
      eof(nyear,:,:,:) = temp 
      eof_ts(nyear,:,:)=reshape(temp@pc,(/neof,nyear/))
      
      
   do i=1,nyear-1   
     var(i,0:(i-1),:,:)=vv(0:(i-1),:,:)
     var(i,i:nyear-1,:,:)=vv((i+1):nyear,:,:)
     temp = eof_func_prd(var(i,:,:,:),latS,latN,lonL,lonR,nyear,neof)        
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


t2m      = addfile("/disk1/fhd/winter_forecast/data/eof_sd_djf_2010.nc", "r")
t2m_eof=t2m->eof_ts
printVarSummary(t2m_eof)
cc1=escorc(t2m_eof(1:nyear),eof_ts(0,0,:))
print(cc1)

if( cc1.lt.0 ) then
		eof(0,0,:,:)=eof(0,0,:,:)*-1
		eof_ts(0,0,:)=eof_ts(0,0,:)*-1
end if 

cc2=escorc(t2m_eof(1:nyear),eof_ts(0,0,:))
print(cc2)

;do i=0,nyear
 ;  sst_t2m=escorc(eof_ts(0,0,:), eof_ts(i,0,:))
 ;  if( sst_t2m.lt.0 ) then
;		eof(i,0,:,:)=eof(i,0,:,:)*-1
;		eof_ts(i,0,:)=eof_ts(i,0,:)*-1
;	 end if 
;end do

eof=eof*-1
eof_ts=eof_ts*-1

		eof(0,0,:,:)=eof(0,0,:,:)*-1
		eof_ts(0,0,:)=eof_ts(0,0,:)*-1
               
                 eof(3:4,0,:,:)=eof(3:4,0,:,:)*-1
                eof_ts(3:4,0,:)=eof_ts(3:4,0,:)*-1;
;

		eof(11,0,:,:)=eof(11,0,:,:)*-1
		eof_ts(11,0,:)=eof_ts(11,0,:)*-1

		eof(14,0,:,:)=eof(14,0,:,:)*-1
		eof_ts(14,0,:)=eof_ts(14,0,:)*-1
;
		eof(22:23,0,:,:)=eof(22:23,0,:,:)*-1
		eof_ts(22:23,0,:)=eof_ts(22:23,0,:)*-1

                eof(28,0,:,:)=eof(28,0,:,:)*-1
                eof_ts(28,0,:)=eof_ts(28,0,:)*-1
;
		eof(18,0,:,:)=eof(18,0,:,:)*-1
		eof_ts(18,0,:)=eof_ts(18,0,:)*-1
;		eof(23:25,0,:,:)=eof(23:25,0,:,:)*-1
;		eof_ts(23:25,0,:)=eof_ts(23:25,0,:)*-1
;		eof(34:35,0,:,:)=eof(34:35,0,:,:)*-1
;		eof_ts(34:35,0,:)=eof_ts(34:35,0,:)*-1
;
		eof(26,0,:,:)=eof(26,0,:,:)*-1
		eof_ts(26,0,:)=eof_ts(26,0,:)*-1


;		eof(34,0,:,:)=eof(34,0,:,:)*-1
;		eof_ts(34,0,:)=eof_ts(34,0,:)*-1



system("rm -f /disk1/fhd/winter_forecast/data/eof_sd_cv_2010.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/eof_sd_cv_2010.nc", "c")
fout->eof=eof
fout->eof_ts=eof_ts



end
