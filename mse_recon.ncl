
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
nyear  = 36        
tstart = 35
tend   = 466
varname1     = "winter_anom"
decomposition_season="JFM"
season="JFM"

var     = "t2m"
unit= ""
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")

;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "mse_recon"                       ; set plot name 
pltType = "pdf" 

;==========================================================
;reconstruct t2m data
;==========================================================
f=addfile ("/disk1/fhd/winter_forecast/data/test5_recon_arcavg_new.nc","r")
cv_t2m=f->recon
   
ff=addfile ("/disk1/fhd/data/t2m.mon.mean.1.0.nc","r")
TIME2   = ff->time
YYYY2   = cd_calendar(TIME2,-2)/100                 
air= short2flt(ff->t2m(35:466,:,:))
lat=ff->latitude(:)
lon=ff->longitude(:)
  obs = month_to_season (air, season)
  obs_cli=dim_avg_n(obs,0)
   winter_anom=new((/36,dimsizes(lat),dimsizes(lon)/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)

   var1_regrid=varible_file->$varname1$
   printVarSummary(var1_regrid)   
   ensemble_winter=dim_avg_n(var1_regrid,1)
   copy_VarCoords(var1_regrid(:,0,:,:), ensemble_winter)

 
    bb = winter_anom(:,{latS:latN},{lonL:lonR})
    printVarSummary(bb)
    printVarSummary(cv_t2m)
    
    cv_t2m_=cv_t2m({time|:},{latitude|:},{longitude|:})
 ;   printMinMax(ccc,False)
 ;   printMinMax(dim_avg_n((cv_t2m-bb)^2, 0),False)
 ;   exit()
    mse_mlr=sqrt(dim_avg_n((cv_t2m_-bb)^2, 0))
   copy_VarCoords(bb(0,:,:),mse_mlr)  
   printVarSummary(mse_mlr)

;======
; mse for ec hindcast
;=======
   mse_ec=sqrt(dim_avg_n((ensemble_winter(:,{latS:latN},{lonL:lonR})-bb)^2, 0))
   copy_VarCoords(bb(0,:,:),mse_ec)  
   printVarSummary(bb)
 ;  exit()
   printVarSummary(mse_ec)
   mse_diff=mse_ec-mse_mlr
   copy_VarCoords(bb(0,:,:),mse_diff)  
    printMinMax(mse_ec, False)
    printMinMax(mse_mlr, False)
    printMinMax(mse_diff, False)
    
system("rm -f /disk1/fhd/winter_forecast/data/fig13bdf.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/fig13bdf.nc", "c")
fout->13b=mse_ec
fout->13d=mse_mlr
fout->13f=mse_diff
exit()
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")       ; choose colormap
  plot = new(3,graphic) 
  
res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = 20         ; zoom in on map
res@mpMaxLatF            = 85
;res@mpCenterLonF         = 180.
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
;res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
; res1@cnLevelSpacingF   =0.2
; res1@cnMinLevelValF    =0
; res1@cnMaxLevelValF    =3.4
res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/0,0.5,1,1.5,2,2.5,3,3.5,4,4.5/)
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

 res1@tmXBLabelFontHeightF = 0.013
 res1@tmYLLabelFontHeightF = 0.013
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.018
 res1@gsnRightStringFontHeightF = 0.01
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
 rtsP@pmLabelBarWidthF =0.6
 rtsP@lbLabelFontHeightF  =0.015
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
res1@gsnLeftString  = "(b) SEAS5"
plot(0) = gsn_csm_contour_map_ce(wks,mse_ec,res1)
res1@gsnLeftString  = "(d) Improved"
plot(1) = gsn_csm_contour_map_ce(wks,mse_mlr,res1)
res1@gsnLeftString  = "(f) Diff"
plot(2) = gsn_csm_contour_map_ce(wks,mse_diff,res1)

;draw(plot)
;frame(wks)
gsn_panel(wks,plot,(/3,1/),rtsP)     ; now draw as one plot


end
