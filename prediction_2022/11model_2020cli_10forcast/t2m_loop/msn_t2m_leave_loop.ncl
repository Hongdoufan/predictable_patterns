load "/disk1/fhd/function/msneof.ncl"
begin
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
nyear=35           ; leave 1 year out
neof   = 30        ; number of EOFs
eofp   = 4           ;number of eof being plotted
nensemble=25

;decomposition_season="DJF"   the first time is Dec 

;var     = "t2m"
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
yrStrt = 1981
yrLast = 2016
varname1     = "winter_anom"

tstart= 35
tend=466
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

t2m_msn=new((/36,eofp,70,360/),typeof(vv))
var=new((/36,nyear,nensemble,181,360/),typeof(vv))
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



      var(0,:,:,:,:)=vv(1:35,:,:,:)
      temp = msn_eof(var(0,:,:,:,:),nensemble,latS,latN,lonL,lonR,nyear,neof,eofp)        
      t2m_msn(0,:,:,:) = temp 
      
   do i=1,35   
     var(i,0:(i-1),:,:,:)=vv(0:(i-1),:,:,:)
     var(i,i:34,:,:,:)=vv((i+1):35,:,:,:)
     temp = msn_eof(var(i,:,:,:,:),nensemble,latS,latN,lonL,lonR,nyear,neof,eofp)        
     t2m_msn(i,:,:,:) = temp 
   end do
     
   
t2m_msn!0="leave_year"
t2m_msn&leave_year=ispan(yrStrt,yrLast,1)
printVarSummary(t2m_msn)

 system("rm -f /disk1/fhd/degreepaper/data/msn_t2m_leave.nc")
 fout=addfile("/disk1/fhd/degreepaper/data/msn_t2m_leave.nc", "c")
 fout->msn_t2m=t2m_msn




end
