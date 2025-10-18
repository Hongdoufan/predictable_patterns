load "/disk1/fhd/function/msneof.ncl"
begin
year = 2015
yrStrt = 1991
m = year-yrStrt+1 ; th yr
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
nyear=29           ; leave 1 year out
neof   = 29        ; number of EOFs
eofp   = 4           ;number of eof being plotted
nensemble=25

output  =  "/disk1/fhd/degreepaper/data/"                            ; directory for plot output
outName = "msn_t2m_leave"+year+"_sys51.nc"  

;decomposition_season="DJF"   the first time is Dec 

;var     = "t2m"
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina_sys51.nc"                            ; input directory
yrStrt = 1981
yrLast = 2010
varname1     = "winter_anom"

tstart= 35
tend=394
varname1     = "winter_anom"
decomposition_season="DJF"

unit= ""
varible_file      = addfile (files_dir, "r")
   

vv=varible_file->$varname1$
t2m_msn=new((/nyear+1,eofp,70,360/),typeof(vv))
var=new((/nyear,nensemble,180,360/),typeof(vv))
     
     var(0:m-2,:,:,:)=vv(0:m-2,:,:,:)
     var(m-1:28,:,:,:)=vv(m:29,:,:,:)
     temp = msn_eof(var,nensemble,latS,latN,lonL,lonR,nyear,neof,eofp)        

 system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->msn_t2m=temp
;system("rm -f /disk1/fhd/degreepaper/data/msn_t2m_leave1985_2010.nc")
;fout=addfile("/disk1/fhd/degreepaper/data/msn_t2m_leave1985_2010.nc", "c")
;fout->msn_t2m=temp
     
   





end
