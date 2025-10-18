
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
pltName = "sd_ea_2017_prd"                       ; set plot name 
pltType = "ps" 

   var     = "sd"
   varname = "SD_GDS0_SFC"                                                       ; create a plot [?]
   diri = "/disk4/mssfs/forecast/ecmwf/9/monthly/surface/"
   fill = "sd.2017.grib"
   output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
   outName = var+"_in9_6mon_sona.nc"                       ; set plot name 
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"      
   level  = " "
   nensemble = 51
   nlatitude= 181
   nlongitude=360
   np   = 3        ; number of pictures
   son=addfile("/disk1/fhd/winter_forecast/data/sd_in9_cli.nc","r")
   cli=son->winter_anom
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================    

   f    = addfile(diri+fill,"r")   
   x      = f->$varname$
  ; print(x)
  

   ;exit()
   x = where(x.lt.0.000000001, x@_FillValue, x)
   x = x*1000.
   printVarSummary(x)
;   if(numsize.eq.5) then  
      winter_anom=new((/nensemble,nlatitude,nlongitude/),"float")     
      winter_mean=dim_avg_n(x(:,0:2,:,:),1)
      son_cli=dim_avg_n(cli,0)
      printVarSummary(son_cli)
      copy_VarCoords(x(0,0,:,:), son_cli)
      printVarSummary(son_cli)
      do i=0,nensemble-1
      winter_anom(i,:,:)=winter_mean(i,:,:)-son_cli
      end do

   sd_son_2017=dim_avg_n(winter_anom,0)
   copy_VarCoords(x(0,0,:,:),sd_son_2017)
   printVarSummary(sd_son_2017)
 ;  sd_son_2017 = where(abs(sd_son_2017).gt.100, sd_son_2017@_FillValue, sd_son_2017)

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
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  latSd   =  45
  latNd   =  60
  lonLd   =  60
  lonRd   =  165
   varname1     = "winter_anom"
   varname2     = "sd"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   startyear=1981
   endyear=2016
   nyear= 36
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"      
   level  = " "
   ensemble = 25
                                                   
;   ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)
  ; ensemble_winter=lonFlip(ensemble_winter)
   sstd=sd_son_2017({latSd:latNd},{lonLd:lonRd})
  ;===========================================================================
  
  rad   = 4.*atan(1.)/180.
  lat4   = sstd&g0_lat_2
  clat4  = lat4
  clat4  = sqrt( cos(rad*lat4) ) 
  area_d=wgt_areaave(sd_son_2017({latSd:latNd},{lonLd:lonRd}), clat4, 1.0, 0)
  print(area_d)     ; -1.945774
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
res1@gsnLeftString  =  " "
plot(0) = gsn_csm_contour_map_ce(wks,sd_son_2017,res1)
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

