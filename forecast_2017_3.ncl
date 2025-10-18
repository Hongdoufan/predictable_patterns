
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360

yrStrt = 1981
yrLast = 2016

tstart= 35
tend=466
varname1     = "2T_GDS0_SFC"
decomposition_season="JFM"
season="JFM"

var     = "t2m"
unit= ""
files_dir    = "/disk4/mssfs/forecast/ecmwf/11/monthly/surface/t2m.2017.grib"                            ; input directory
varible_file      = addfile (files_dir, "r")
   
;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "forecast_2017_3"                       ; set plot name 
pltType = "ps" 

; output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
; outName = "trend_enso_sn_tp.nc"  
neof   = 3        ; number of EOFs
optEOF = True
optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

optETS = False
;==========================================================
;reconstruct t2m data
;==========================================================
t2m_eof=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc","r")
tren=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")
trend=tren->eof
pc2=tren->eof_ts
msn_t2m_rc=addfile("/disk1/fhd/winter_forecast/data/msn.t2m.reg.t2m.nc","r")
;eof=msn_t2m_rc->eof
file1 = addfile("/disk1/fhd/winter_forecast/data/t2m_in11_6mon_win_cli.nc","r")
cli=file1->winter_cli
cordinate=varible_file->$varname1$
cordi=cordinate(0,0,{20:89},{0:359})
eof=t2m_eof->eof
printVarSummary(cordi)
copy_VarCoords(cordi, eof(0,:,:))
printVarSummary(eof)
eof_ts=t2m_eof->eof_ts
; sic=sic_pc->sic_index
; sd_tp=tp_pc->sic_index
; sd_na=sd_na_pc->sic_index
; sd_ea=sd_ea_pc->sic_index
; pc4=sst_pc4->sic_index

; copy_VarCoords(eof_ts(0,:), sic)
; copy_VarCoords(eof_ts(0,:), sd_tp)
; copy_VarCoords(eof_ts(0,:), sd_na)
; copy_VarCoords(eof_ts(0,:), sd_ea)
; copy_VarCoords(eof_ts(0,:), nino)
; copy_VarCoords(eof_ts(0,:), emi)
; copy_VarCoords(eof_ts(0,:), pc4)



new_pc=new((/3,1/),"float")
new_pc(0,:)=0.87        ; obs pc1
new_pc(1,:)=-0.7129048; 0.3883877
new_pc(2,:)=0.6450729
;new_pc(3,:)=-12.08121
aaa=trend({20:89},:)

   Opt                = True
   Opt@ForceOverwrite = True
   Opt@DstGridType    = "1.0x1.0"
   Opt@DstLLCorner    = (/ -90,   0/)
   Opt@DstURCorner    = (/  90, 359/)
   
   var1_regri = ESMF_regrid(trend,Opt)
;   var1_regrid =var1_regrid(:,:,::-1,:)
   printVarSummary(var1_regri)   

;printVarSummary(aaa)
;exit()
;e=var1_regri({20:89},:)
eof(0,:,:)=var1_regri({20:89},:)*4
;eof(1,:,:)=eof(2,:,:)
;eof(2,:,:)=eof(3,:,:)

recon=eof2data(eof(0:2,:,:),new_pc)
var_winter=eof(1,{latS:latN},{lonL:lonR})
printVarSummary(eof)
printVarSummary(var_winter)
;exit()
area_lat=var_winter&g0_lat_2
;printVarSummary(area_lat)
;exit()
;area_lat=doubletofloat(var_winter&lat)
; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
rad    = 4.*atan(1.)/180.
clat   = area_lat
clat   = sqrt( cos(rad*clat) ) 
printVarSummary(clat)
do nl=0,dimsizes(clat)-1                  ; remove weighting
      if (clat(nl).ne.0.) then
          recon(nl,:,:)  = recon(nl,:,:)*20./clat(nl)   ; array syntax
      end if
end do

copy_VarCoords(eof(0,:,:), recon(:,:,0))
copy_VarCoords(new_pc(0,:), recon(0,0,:))

;==========================================================
;observed t2m data
;==========================================================
; f=addfile ("/disk1/fhd/winter_forecast/data/msn4_recon19_4_.nc","r")
; recon=f->recon(tyear,:,:)
   
ff=addfile ("/disk3/erainterim2.5/monthly/surface/t2m.mon.mean.nc","r")
TIME2   = ff->time
YYYY2   = cd_calendar(TIME2,-2)/100                 
air= short2flt(ff->t2m(35:466,:,:))
air_2017=short2flt(ff->t2m(467:469,:,:))
air_obs=dim_avg_n(air_2017, 0)
copy_VarCoords(air_2017(0,:,:), air_obs)

lat=ff->latitude(:)
lon=ff->longitude(:)
  obs = month_to_season (air, season)
  obs_cli=dim_avg_n(obs,0)
   winter_anom=new((/36,dimsizes(lat),dimsizes(lon)/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)
   air_obs=air_obs-obs_cli

;exit()
;air_obs=dim_standardize_n(air_obs, 0, 0)
;recon=dim_standardize_n(recon, 0, 0)
;==========================================================
;ec forecast t2m data
;==========================================================
 
 
 
   var1=varible_file->$varname1$
   printVarSummary(var1)

   Opt1                = True
   Opt1@ForceOverwrite = True
   Opt1@DstGridType    = "2.5x2.5"
   Opt1@DstLLCorner    = (/ -90,   0/)
   Opt1@DstURCorner    = (/  90, 357.5/)
   
   
   var1_regridd = ESMF_regrid(var1,Opt1)
   var1_regridd =var1_regridd(:,:,::-1,:)
   cli_ec= ESMF_regrid(cli,Opt1)
   cli_ec= cli_ec(::-1,:)
   printVarSummary(cli_ec)
;  exit()
   ensemble_winted=dim_avg_n(var1_regridd,0)
   ensemble_winterd=dim_avg_n(ensemble_winted(1:3,:,:), 0)
   printVarSummary(ensemble_winterd)
   copy_VarCoords(cli_ec, ensemble_winterd) 

   printVarSummary(ensemble_winterd)
   printVarSummary(cli_ec)
   ec_forecast=ensemble_winterd-cli_ec
   copy_VarCoords(var1_regridd(0,0,:,:), ec_forecast)
   
   printMinMax(air_obs, False)
   printMinMax(recon, False)
   printMinMax(ec_forecast,False)







;exit()
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"temp_diff_18lev")       ; choose colormap
  plot = new(3,graphic) 
  
res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = 20         ; zoom in on map
res@mpMaxLatF            = 89
;res@mpCenterLonF         = 140.
 res@mpMinLonF=0
 res@mpMaxLonF=140
res@cnFillOn = True
res@cnLinesOn = False
;res@mpShapeMode = "FreeAspect"
res@vpHeightF = 0.25        ; Changes the aspect ratio
res@vpWidthF  = 0.5
  

res1 = res
;res1@gsnDraw = False
;res1@gsnFrame = False
res1@cnLineLabelsOn    =False
;res1@cnLineLabelFontHeightF   = 0.012
res1@cnInfoLabelOn            = False
res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
;symMinMaxPlt(air_obs, 16, False, res1)       ; contributed.ncl

res1@cnLevelSpacingF   =0.5
res1@cnMinLevelValF    =-4
res1@cnMaxLevelValF    =4
;res1@cnLevelSelectionMode        = "ExplicitLevels"
; res1@cnLevels = (/0,0.5,1,1.5,2,2.5,3,3.5,4,4.5/)
;res1@cnFillColors = (/"75", "66","50","146","156",\
;                      "161","166","171","176","181","186","191","255"/)                     
; res1@gsnRightString  = " "
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = False
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.018
 res1@tmYLLabelFontHeightF = 0.018
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.023
 res1@gsnRightStringFontHeightF = 0.023
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 res1@tmXBTickSpacingF        =30
 res1@tmYLTickSpacingF        =20

 res1@tmXTOn  = False
 res1@tmYROn  = False
; res1@tmXBLabelDeltaF =  0.5
 res1@tmXTMinorOn = False
 rtsP                      = True            ; modify the panel plot
 rtsP@gsnMaximize          = True            ; large format
 rtsP@txString             = " "
 rtsP@gsnPanelLabelBar= True                 ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.04
 rtsP@pmLabelBarWidthF =0.4
 rtsP@lbLabelFontHeightF  =0.015
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
res1@gsnLeftString  = "(a) OBS"
plot(0) = gsn_csm_contour_map_ce(wks,air_obs,res1)
res1@gsnLeftString  = "(b) SEAS5"
plot(1) = gsn_csm_contour_map_ce(wks,ec_forecast,res1)
res1@gsnLeftString  = "(c) Improved forecast"
plot(2) = gsn_csm_contour_map_ce(wks,recon(:,:,0),res1)
gsn_panel(wks,plot,(/3,1/),rtsP)     ; now draw as one plot

;res1@cnLevelSpacingF   =1
;res1@cnMinLevelValF    =-20
;res1@cnMaxLevelValF    =20
;plot(0) = gsn_csm_contour_map_ce(wks,ec_forecast,res1)
;gsn_panel(wks,plot(0),(/1,1/),rtsP)     ; now draw as one plot



end
