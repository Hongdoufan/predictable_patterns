begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================

   var     = "t2m"
   varname = "2T_GDS0_SFC_S123"                                                          ; create a plot [?]
   output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
;   outName = var+"_in11_6mon_wina.nc"                       ; set plot name 
   outName = var+"_wina_era5.nc"                       ; set plot name 
   tstart=""
   tend=""
   startyear=1991
   endyear=2020
   nyear= 30
   latitude="g0_lat_1"    ;lat name
   longitude="g0_lon_2"   ;lon name
   nlatitude= 181
   nlongitude=360

latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
yrStrt = 1991
yrLast = 2020
nyear  = 30        
tstart = 35
tend   = 394
season="JFM"


ynumber=ispan(1991,2021,1)
all_files = "/disk3/era5-1.0/monthly/surface/temperature/t2m." + ynumber + ".grib"
ff = addfiles (all_files, "r")
;---Read "pottmp" in "join" mode and print a summary of the variable
; Read variable(s) multiple data file. Here from CLM 
;===========================================================================
;---Read "pottmp" in "join" mode 
;   ListSetType (ff, "join")


vv = ff[:]->$varname$
air= vv(11:370,:,:)
lat=ff[0]->$latitude$
lon=ff[0]->$longitude$
  obs = month_to_season (air, season)
  obs_cli=dim_avg_n(obs,0)
   winter_anom=new((/nyear,dimsizes(lat),dimsizes(lon)/),"float")
   do i=0,nyear-1
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)
copy_VarCoords(obs(0,:,:), obs_cli)
printVarSummary(obs_cli)
printVarSummary(winter_anom)
;exit()


;2021/2022
f1=addfile("/disk3/era5-1.0/monthly/surface/temperature/t2m.2021.grib","r")
t2m_12=f1->2T_GDS0_SFC_S123(11,:,:)
f2=addfile("/disk3/era5-1.0/monthly/surface/temperature/t2m.2022.grib","r")
t2m_1_2=f2->2T_GDS0_SFC_S123
t2m_=(t2m_12+t2m_1_2(0,:,:)+t2m_1_2(1,:,:))/3.
t2m_2021=t2m_-obs_cli
copy_VarCoords(obs(0,:,:), t2m_2021)

 system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->winter_anom=winter_anom
 fout->winter_cli=obs_cli
 fout->t2m_2021=t2m_2021

end

