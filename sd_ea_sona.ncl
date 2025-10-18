
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
pltName = "sd_ea_sona_dtrend"                       ; set plot name 
pltType = "ps" 
   varname1     = "winter_anom"

   son=addfile("/disk1/fhd/winter_forecast/data/sd_in9_cli.nc","r")
   cli=son->winter_anom
   son_cli=dim_avg_n(cli,0)
   printVarSummary(cli)
   copy_VarCoords(cli(0,:,:), son_cli)
   printVarSummary(son_cli)

   file1 = addfile("/disk1/fhd/winter_forecast/data/sd_in9_6mon_sona.nc","r")
               
   var1=file1->$varname1$
   ensemble_winter=dim_avg_n(var1,1)
   copy_VarCoords(var1(:,0,:,:), ensemble_winter)
 ;  SST1 = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)
   printVarSummary(ensemble_winter)
 ;  exit()

;    var     = "sd"
;    varname = "SD_GDS0_SFC"                                                       ; create a plot [?]
;    diri = "/disk4/mssfs/hindcast/ecmwf/9/monthly/surface/"
;    fill = systemfunc("cd "+diri+" ; ls sd.*")
;    nfill= dimsizes(fill)
;    output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
; ;   outName = var+"_in9_6mon_sona.nc"                       ; set plot name 
;    outName  = var+"_in9_cli.nc"
;    tstart=""
;    tend=""
;    startyear=1981
;    endyear=2016
;    nyear= 36
;    latitude="g0_lat_2"    ;lat name
;    longitude="g0_lon_3"   ;lon name
;    levelname   = "lv_ISBL2"      
;    level  = " "
;    nensemble = 25
;    nlatitude= 181
;    nlongitude=360
;    f    = addfiles(diri+fill,"r") 
;    ListSetType (f, "join") 
   
;    lat  = f[0]->$latitude$                ; (lndgrid)); same for all files
;    lon  = f[0]->$longitude$               ;              "             "
; ;   topo = f[0]->lev                      ; 
;    indat = f[:]->$varname$
   
;    datasizes    = dimsizes(indat)
;    numsize  = dimsizes(datasizes)
;    x      = indat
;    printVarSummary(x)
;    x = where(x.lt.0.000001, x@_FillValue, x)
;    x = x*1000.
; ;  x = where(x.gt.5, x@_FillValue, x)
;       winter_anom=new((/nyear,nensemble,nlatitude,nlongitude/),"float")     
;       winter_mean=dim_avg_n(x(:,:,0:2,:,:),2)
;       winter_cli=dim_avg_n(winter_mean,0)
;       cli=dim_avg_n(winter_cli, 0)
;       do i=0,nyear-1
;          winter_anom(i,:,:,:)=winter_mean(i,:,:,:)-winter_cli
;       end do
;       winter_anom!2="latitude"
;       winter_anom!3="longitude"
;     winter_anom!0="nyear"
;    winter_anom!1="nensemble"
;    winter_anom&nyear=ispan(startyear,endyear,1)
;    winter_anom&nensemble=ispan(0,nensemble-1,1)
;    winter_anom&latitude=lat
;    winter_anom&longitude=lon
;    copy_VarCoords(x(0,0,0,:,:), cli)
;    printVarSummary(cli)

system("rm -f /disk1/fhd/winter_forecast/data/son_snow.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/son_snow.nc", "c")
fout->snow=ensemble_winter 
exit()
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"temp_diff_18lev")       ; choose colormap
  plot = new(25,graphic) 
  
res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = 20         ; zoom in on map
res@mpMaxLatF            = 75
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
;plot(0) = gsn_csm_contour_map_ce(wks,son_cli,res1)
; res1@gsnLeftString  = "(b)"
do i=0,24
plot(i) = gsn_csm_contour_map_ce(wks,ensemble_winter(i,:,:),res1)
end do
gsn_panel(wks,plot,(/5,5/),rtsP)     ; now draw as one plot

;res1@cnLevelSpacingF   =1
;res1@cnMinLevelValF    =-20
;res1@cnMaxLevelValF    =20
;plot(0) = gsn_csm_contour_map_ce(wks,ec_forecast,res1)
;gsn_panel(wks,plot(0),(/1,1/),rtsP)     ; now draw as one plot
end

