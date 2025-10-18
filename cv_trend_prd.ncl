load "/disk1/fhd/function/cv_trend.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  0
latN   =  90
lonL   =  0
lonR   =  360
yrStrt = 1981
yrLast = 2016
nyear  = 35        
tstart = 35
tend   = 466
varname1     = "winter_anom"
decomposition_season="JFM"
season="JFM"
nrc=3
unit= ""
files_dir    = "/disk1/fhd/winter_forecast/data/cv_trend_obs.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "cv_trend_prd.nc" 

   
varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
   var1=varible_file->$varname1$
   winter_anom=dim_avg_n(var1,1)
   copy_VarCoords(var1(:,0,:,:), winter_anom)
   lat=winter_anom&latitude
   lon=winter_anom&longitude


      time=ispan(1,36,1)
      ts=new((/36,nyear/),"float")
      var=new((/36,nyear,dimsizes(lat),dimsizes(lon)/),typeof(winter_anom))
      trend_cv=new((/36,dimsizes(lat),dimsizes(lon)/),typeof(winter_anom))
      yint_cv=new((/36,dimsizes(lat),dimsizes(lon)/),typeof(winter_anom))
   
      ts(0,:)=time(1:35)
      var(0,:,:,:)=winter_anom(1:35,:,:)
      temp = trend(ts(0,:),var(0,:,:,:))        
      trend_cv(0,:,:) = temp 
      yint_cv(0,:,:)= onedtond(temp@yintercept, (/dimsizes(lat),dimsizes(lon)/) )
      
   do i=1,34  
     ts(i,0:(i-1))= time(0:(i-1))
     ts(i,i:34)=time((i+1):35)
     var(i,0:(i-1),:,:)=winter_anom(0:(i-1),:,:)
     var(i,i:34,:,:)=winter_anom((i+1):35,:,:)
     temp = trend(ts(i,:),var(i,:,:,:))         
     trend_cv(i,:,:) = temp   ;  slope
     yint_cv(i,:,:)= onedtond(temp@yintercept, (/dimsizes(lat),dimsizes(lon)/) )
     
   end do

      ts(35,:)=time(0:34)
      var(35,:,:,:)=winter_anom(0:34,:,:)
      temp = trend(ts(35,:),var(35,:,:,:))        
      trend_cv(35,:,:) = temp 
      yint_cv(35,:,:)= onedtond(temp@yintercept, (/dimsizes(lat),dimsizes(lon)/) )



trend_cv!0="leave_year"
trend_cv&leave_year=ispan(yrStrt,yrLast,1)
copy_VarCoords(trend_cv, yint_cv)

   
; ; ==============================================================
; ; forecast the trend in winter_anomervation
; ; ==============================================================
   
   y_trend_prd=new((/36,dimsizes(lat),dimsizes(lon)/),"float")
   do i=0,35
      y_trend_prd(i,:,:)=yint_cv(i,:,:)+trend_cv(i,:,:)*time(i)  ;trend_cv is slope
   end do
   copy_VarCoords(winter_anom,y_trend_prd)
   printVarSummary(y_trend_prd)
; ; ==============================================================
; ; output the y value associated with trend for every year
; ; ==============================================================
  system("rm -f $output$+$outName$.nc")
  fout=addfile(output+outName, "c")
  fout->y_trend=y_trend_prd
  fout->slope=trend_cv
end

