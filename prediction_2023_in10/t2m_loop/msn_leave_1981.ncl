load "/disk1/fhd/function/msneof.ncl"
begin
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
nyear=29           ; leave 1 year out
neof   = 29        ; number of EOFs
eofp   = 4           ;number of eof being plotted
nensemble=25

;decomposition_season="DJF"   the first time is Dec 

;var     = "t2m"
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in10_6mon_wina_sys51.nc"                            ; input directory
yrStrt = 1991
yrLast = 2020
varname1     = "winter_anom"

tstart= 35
tend=394
varname1     = "winter_anom"
decomposition_season="DJF"
label1= (/"(a)","(c)","(e)","(g)"/)
label2= (/"(b)","(d)","(f)","(h)"/)

unit= ""
varible_file      = addfile (files_dir, "r")
   
;   level   =  17                                        ; 300hPa
;PLOT    = True                            ; create a plot [?]
;pltDir  =  "/disk1/fhd/degreepaper/result/"                            ; directory for plot output
;pltName = "msn_eof_"+var+"_35"                       ; set plot name 
;pltType = "pdf" 

vv=varible_file->$varname1$

t2m_msn=new((/nyear+1,eofp,70,360/),typeof(vv))
var=new((/nyear,nensemble,180,360/),typeof(vv))
;var(0,:,:,:,:)= vv(1:35,:,:,:)
;var(1,0,:,:,:)= vv(0,:,:,:)
;var(1,2:35,:,:,:)= vv(2:35,:,:,:)
;var(1,0,:,:,:)= vv(0,:,:,:)
;var(1,2:35,:,:,:)= vv(2:35,:,:,:)

;	if( (max(Lev).gt.50000) ) then
;		print("the unit of level is Pa")					
;		Z=-1.*H*log(Lev/100000.);
;	else
;		print("the unit of level is hPa")		
;		Z=-1.*H*log(Lev/1000.);		
;	end if	



      var=vv(1:29,:,:,:)
      temp = msn_eof(var,nensemble,latS,latN,lonL,lonR,nyear,neof,eofp)        

 system("rm -f /disk1/fhd/degreepaper/data/msn_t2m_leave1981_10_sys51.nc")
 fout=addfile("/disk1/fhd/degreepaper/data/msn_t2m_leave1981_10_sys51.nc", "c")
 fout->msn_t2m=temp

      


end
