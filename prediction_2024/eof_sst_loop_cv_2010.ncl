load "/disk1/fhd/function/eof_prd.ncl"
begin
latS   =  -30
latN   =  30
lonL   =  110
lonR   =  290

nyear  =  29
yrStrt = 1991
yrLast = 2020
neof =2
tstart= 35
tend=394

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sst_in11_6mon_wina_sys51.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
ensemble_winter=dim_avg_n(var1,1)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)
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


t2m      = addfile("/disk1/fhd/winter_forecast/data/eof_sst_djf_sys51.nc", "r")
t2m_eof=t2m->eof_ts
printVarSummary(t2m_eof)
cc1=escorc(t2m_eof(0,1:nyear),eof_ts(0,0,:))
print(cc1)

cc2=escorc(t2m_eof(1,1:nyear),eof_ts(0,1,:))
print(cc2)



if( cc1.lt.0 ) then
		eof(0,0,:,:)=eof(0,0,:,:)*-1
		eof_ts(0,0,:)=eof_ts(0,0,:)*-1
end if 

if( cc2.lt.0 ) then
		eof(0,1,:,:)=eof(0,1,:,:)*-1
		eof_ts(0,1,:)=eof_ts(0,1,:)*-1
end if 

cc1=escorc(t2m_eof(0,1:nyear),eof_ts(0,0,:))
print(cc1)

cc2=escorc(t2m_eof(1,1:nyear),eof_ts(0,1,:))
print(cc2)

;exit()
do i=0,nyear
   sst_t2m=escorc(eof_ts(0,0,:), eof_ts(i,0,:))
   if( sst_t2m.lt.0 ) then
		eof(i,0,:,:)=eof(i,0,:,:)*-1
		eof_ts(i,0,:)=eof_ts(i,0,:)*-1
	 end if 
	 
	 sst_t2m1=escorc(eof_ts(0,1,:), eof_ts(i,1,:))
   if( sst_t2m1.lt.0 ) then
		eof(i,1,:,:)=eof(i,1,:,:)*-1
		eof_ts(i,1,:)=eof_ts(i,1,:)*-1
	 end if 

;exit()

end do


;ts=eof_ts
;cor1=new(36,"float")
;cor2=new(36,"float")
;do i=0,35
;  cor1(i)=escorc(ts(0,0,:),ts(i,0,:))
;  cor2(i)=escorc(ts(0,1,:),ts(i,1,:))
;end do

		eof(27:29,0,:,:)=eof(27:29,0,:,:)*-1
		eof_ts(27:29,0,:)=eof_ts(27:29,0,:)*-1

;		eof(33,0,:,:)=eof(33,0,:,:)*-1
;		eof_ts(33,1,:)=eof_ts(33,0,:)*-1

;		eof(34,0,:,:)=eof(34,0,:,:)*-1
;		eof_ts(34,0,:)=eof_ts(34,0,:)*-1

;		eof(35,0,:,:)=eof(35,0,:,:)*-1
;		eof_ts(35,0,:)=eof_ts(35,0,:)*-1



;print(cor1)
;print(cor2)

 system("rm -f /disk1/fhd/winter_forecast/data/eof_sst_cv_sys51.nc")
 fout=addfile("/disk1/fhd/winter_forecast/data/eof_sst_cv_sys51.nc", "c")
 fout->eof=eof
 fout->eof_ts=eof_ts



end
