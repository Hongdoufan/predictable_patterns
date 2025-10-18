load "/disk1/fhd/function/eof.ncl"
begin
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
nyear  =  29
yrStrt = 1981
yrLast = 2010

tstart= 35
tend=394

decomposition_season="JFM"

unit= ""
files_dir    = "/disk1/fhd/data/t2m.mon.mean.1.0.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
neof   = 4        ; number of EOFs
   
TIME   = varible_file->time
YYYY   = cd_calendar(TIME,-2)/100                 ; entire file
;iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
variabl= short2flt(varible_file->t2m)
vare=variabl(tstart:tend,{latS:latN},{lonL:lonR})
; ==============================================================
; compute desired global seasonal mean: month_to_season (contributed.ncl)
; ==============================================================

variable =vare
;copy_VarCoords(vare,variable)
xClm      = clmMonTLL(variable)
ariable  = calcMonAnomTLL (variable, xClm)    ; replace with anonamlies
n_variable  =ariable({latitude|:},{longitude|:},time|:)
;n_variable = wgt_runave_Wrap(n_variable, (/0.25, 0.50, 0.25/), 0)
;n_variable@long_name = "ANOMALIES: "+n_variable@long_name
aaa=n_variable(time|:,{latitude|:},{longitude|:})
vv    = month_to_season (aaa, decomposition_season)
eof=new((/nyear+1,neof,70,360/),typeof(vv))
var=new((/nyear+1,nyear,70,360/),typeof(vv))
eof_ts=new((/nyear+1,neof,nyear/),typeof(vv))

    
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

eof=eof*-1
eof_ts=eof_ts*-1

eof(0,1,:,:)=eof(0,1,:,:)*-1
eof_ts(0,1,:)=eof_ts(0,1,:)*-1

 system("rm -f /disk1/fhd/degreepaper/data/eof_t2m_leave_obs_2010.nc")
 fout=addfile("/disk1/fhd/degreepaper/data/eof_t2m_leave_obs_2010.nc", "c")
 fout->eof=eof
 fout->eof_ts=eof_ts



end
