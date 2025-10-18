
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
nyear  =  36
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "sd_ea_2017_obs"                       ; set plot name 
pltType = "ps" 

 ff=addfile ("/disk3/jra55/monthly/snow/snowd.mon.mean.nc", "r")
  TIME2   = ff->time
  YYYY2   = cd_calendar(TIME2,-2)/100                 
  season = "JFM" 

var2= ff->snowd(284:715,:,:) ;1981.09
lat=ff->lat
lon=ff->lon

;   obs=var2(0:nyear-1,:,:)
   obs1=month_to_season (var2, season)
   obs_cli1=dim_avg_n(obs1,0)
   SST1=new((/nyear,dimsizes(lat),dimsizes(lon)/),"float")
   ss=ff->snowd(716:718,:,:)
   sd_son=dim_avg_n(ss,0)
   sd_son_2017=sd_son-obs_cli1
   copy_VarCoords(ss(0,:,:), sd_son_2017)
   printVarSummary(sd_son_2017)
   printMinMax(sd_son_2017,False)
   sss=obs_cli1*1000.
   copy_VarCoords(ss(0,:,:), sss)
   sd_2017=sd_son_2017*1000.
   copy_VarCoords(ss(0,:,:), sd_2017)
   printMinMax(sd_2017, False)
 
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  ; latSd   =  45
  ; latNd   =  60
  ; lonLd   =  60
  ; lonRd   =  165
  latSd   =  24
  latNd   =  40
  lonLd   =  70
  lonRd   =  105   ;-1.81003

  sstd=sd_son_2017({latSd:latNd},{lonLd:lonRd})
  ;===========================================================================
  
  rad   = 4.*atan(1.)/180.
  lat4   = sstd&lat
  clat4  = lat4
  clat4  = sqrt( cos(rad*lat4) ) 
  area_d=wgt_areaave(sd_son_2017({latSd:latNd},{lonLd:lonRd}), clat4, 1.0, 0)*1000.
  print(area_d)     ; 0.6450729
  exit()
; sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/sd_ea_son_prd_raw.nc","r")
; sd_pc=sd_ea_pc->sic_index
; sdtp=new(37,"float")
; sdtp(0:35)=sd_pc
; sdtp(36)=area_d
; aaa=dim_standardize_Wrap(sdtp, 0)
; sds=dtrend(aaa,False)   ;-22.06571
;exit()
;print(sds)
;  sic_index_=dim_standardize_Wrap(area_d,0)
;system("rm -f /disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc", "c")
;fout->sic_index=sic_index
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
 res@mpMaxLonF=180
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

res1@cnLevelSpacingF   =2
res1@cnMinLevelValF    =-10
res1@cnMaxLevelValF    =10
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
res1@gsnLeftString  = " "
plot(0) = gsn_csm_contour_map_ce(wks,sd_2017,res1)
; res1@gsnLeftString  = "(b)"
; plot(1) = gsn_csm_contour_map_ce(wks,ec_forecast,res1)
; res1@gsnLeftString  = "(c)"
; plot(2) = gsn_csm_contour_map_ce(wks,recon(:,:,0),res1)
gsn_panel(wks,plot,(/1,1/),rtsP)     ; now draw as one plot

;res1@cnLevelSpacingF   =1
;res1@cnMinLevelValF    =-20
;res1@cnMaxLevelValF    =20
;plot(0) = gsn_csm_contour_map_ce(wks,ec_forecast,res1)
;gsn_panel(wks,plot(0),(/1,1/),rtsP)     ; now draw as one plot



end

