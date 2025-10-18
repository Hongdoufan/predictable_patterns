begin
; ==============================================================
; User defined parameters that specify region of globe and years et
; ==============================================================
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360

label1= (/"(a)","(c)","(e)","(g)","(i)"/)
label2= (/"(b)","(d)","(f)","(h)","(j)"/)
eofp=2
nrc=2   
;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "fig_3"                      ; set plot name 
pltType = "ps" 


file1=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
eof_ts=file1->eof_ts
eof=file1->eof

file2=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc", "r")
;eof_ts_obs=file2->eof_ts
eof_obs=file2->eof
eof_obs=eof_obs*7
printMinMax(eof_obs, False)
;explained_variance=new(5,"float")
explained_variance=0.174
year=ispan(1,36,1)

file3 = addfile("/disk1/fhd/winter_forecast/data/fig3b.nc","r")
b=file3->data
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
; gsn_define_colormap(wks,"BlWhRe")       ; choose colormap
plot = new(nrc,graphic) 
res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = 20         ; zoom in on map
res@mpMaxLatF            = 89
res@mpCenterLonF         = 180.
;res@mpMinLonF=180
;res@mpMaxLonF=360
res@cnFillOn = True
res@cnLinesOn = False
;res@mpShapeMode = "FreeAspect"
res@vpHeightF = 0.25        ; Changes the aspect ratio
res@vpWidthF  = 0.5
res@gsnLeftStringFontHeightF = 0.015
res@gsnRightStringFontHeightF = 0.015
  

res1 = res
res1@gsnDraw = False
res1@gsnFrame = False
res1@cnLineLabelsOn    =False
res1@cnFillPalette       ="BlWhRe"          ; set color map
res1@cnInfoLabelOn            = False
res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res1@cnLevelSpacingF   =0.04
res1@cnMinLevelValF    =-0.2
res1@cnMaxLevelValF    =0.2
;res1@cnLevelSelectionMode        = "ExplicitLevels"
;res1@cnLevels = fspan(-3, 3, 16)
;symMinMaxPlt(eof_obs, 16, False, res1)       ; contributed.ncl

; res1@cnFillColors = (/"23", "28","33","38","43","48","59",\
;                       "62","67","72","77","82","87","92","94",\
;                       "98","102"/)
res1@gsnRightString  = "17.4%"
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
res1@lbLabelBarOn                   = True
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2
res1@lbLabelOffsetF = 0.25
res1@pmLabelBarOrthogonalPosF = 0.35       ; 0.05
 ; rtsP@pmLabelBarHeightF    = 0.04
res1@pmLabelBarWidthF =0.5
res1@lbLabelFontHeightF  =0.012
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.013
 res1@tmYLLabelFontHeightF = 0.013
; res1@tmXBLabelFont = 1
 
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 res1@tmXBTickSpacingF        =60
 res1@tmXTOn  = False
 res1@tmYROn  = False
; res1@tmXBLabelDeltaF =  0.5
 res1@tmXTMinorOn = False



 rtsP                      = True            ; modify the panel plot
 rtsP@gsnMaximize          = True            ; large format
 rtsP@txString             = " "

res1@gsnLeftString  = "(a) EOF2 of observed t2m"
plot(0) = gsn_csm_contour_map_ce(wks,eof_obs,res1)

  fig                      = res         
  fig@mpMinLatF            = 0         ; zoom in on map
  fig@mpMaxLatF            = 90

  fig@cnFillPalette       ="MPL_Reds"          ; set color map
  fig@cnLevelSelectionMode        = "ManualLevels"
  ; fig1@cnLevels = (/-0.99, -0.95, 0.95, 0.99/)
  ; fig1@cnFillColors = (/"6", "9", "transparent", "14", "17"/)
  fig@cnMinLevelValF       = 5.              ; set min contour level
  fig@cnMaxLevelValF       = 55.              ; set max contour level
  fig@cnLevelSpacingF      = 10              ; set contour spacing
  fig@lbLabelBarOn                   = True
  fig@lbBottomMarginF = 0.05
  fig@lbLeftMarginF = 0.08
  fig@lbTopMarginF = 0.2
  fig@lbLabelOffsetF = 0.25
  fig@pmLabelBarOrthogonalPosF = 0.3       ; 0.05
  fig@pmLabelBarWidthF =0.5
  fig@lbLabelFontHeightF  =0.012
  fig@gsnLeftString  = "(b) Explained VAR"
  fig@gsnRightString  = "Unit: %"
  fig@tmXBLabelFontHeightF = 0.013
  fig@tmYLLabelFontHeightF = 0.013
  fig@tmXBTickSpacingF        =60

  plot(1)=gsn_csm_contour_map(wks, b(0,:,:), fig)


gsn_panel(wks,plot,(/2,1/),rtsP)     ; now draw as one plot

end

