
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
;latS   =  70
;latN   =  85
;lonL   =  0
;lonR   =  90
latS   =  70
latN   =  89
;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
  varname = "CI_GDS0_SFC"                                                          ; create a plot [?]
   diri = "/disk4/mssfs/hindcast/ecmwf/11/monthly/surface/" 

neof=1
   fill = systemfunc("cd "+diri+" ; ls sic.*")
   nfill= dimsizes(fill)
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "sic"                       ; set plot name 
pltType = "pdf"   
tstart=""
   tend=""
   startyear=1991
   endyear=2020
   nyear= 30
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"
   level  = " "
   nensemble = 25
   nlatitude= 181
   nlongitude=360

; ==============================================================
 prediction = addfile ("/disk1/fhd/winter_forecast/data/prediction_raw_2020.nc", "r")
   var=prediction->sic({latS:latN},:)
var@_FillValue=9.96921e+36
; Open the file: Read only the user specified period
; ==============================================================

;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
gsn_define_colormap(wks,"BlRe")       ; choose colormap
plot = new(neof,graphic)                ; create graphic array
; only needed if paneling
; EOF patterns

res                      = True
res@gsnDraw              = False        ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@gsnSpreadColors      = True         ; spread out color table
res@gsnAddCyclic         = True        ; plotted dataa are not cyclic
res@gsnPolar   = "NH"  

res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
;res@mpMinLonF            = lonL
;res@mpMaxLonF            = lonR
res@mpCenterLonF         = 0.

res@cnFillOn             = True         ; turn on color fill
res@cnLinesOn            = False        ; True is default
;res@cnLineLabelsOn       = False        ; True is default
res@cnFillPalette        = "BlWhRe"     ; set color map
res@lbLabelBarOn         = False        ; turn off individual lb's
;res@vpHeightF            = 2       ; Changes the aspect ratio
;res@vpWidthF             = 0.85
; res@mpCenterLonF         = 180.
res@tmYLLabelFontHeightF      =0.020  ;
res@tmXBLabelFontHeightF      = 0.020
res@gsnLeftStringFontHeightF  = 0.01
res@gsnRightStringFontHeightF  = 0.01

res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF       = -0.3             ; set min contour level
res@cnMaxLevelValF       =  0.3           ; set max contour level
res@cnLevelSpacingF      =  0.05              ; set contour spacing

; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = True         ; add common colorbar


resP@txString            =""

;*******************************************
; first plot
;*******************************************
;do n=0,neof-1
res@gsnLeftString  = "anomaly "
;res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
;plot(0)=gsn_csm_contour_map(wks,cli2,res)
;plot(0)=gsn_csm_contour_map(wks,ensemble2,res)
plot(0)=gsn_csm_contour_map(wks,var,res)


gsn_panel(wks,plot,(/neof,1/),resP)     ; now draw as one plot

;*******************************************
; second plot
;*******************************************
; EOF time series  [bar form]

rts           = True
rts@gsnDraw   = False       ; don't draw yet
rts@gsnFrame  = False       ; don't advance frame yet
rts@gsnScale  = True        ; force text scaling

; these four rtsources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

rts@vpHeightF = 0.40        ; Changes the aspect ratio
rts@vpWidthF  = 0.85
rts@vpXF      = 0.10        ; change start locations
rts@vpYF      = 0.75        ; the plot


rts@tiYAxisString = "unit:degC"                    ; y-axis label

rts@gsnYRefLine           = 0.              ; reference line
rts@gsnXYBarChart         = True            ; create bar chart
rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; panel plot only resources
rtsP                      = True            ; modify the panel plot
rtsP@gsnMaximize          = True            ; large format
;rtsP@txString             = var +decomposition_season +yrStrt+"-"+yrLast
; polyline parameters used on both plots
;*********************************
polyres                  = True
polyres@gsLineThicknessF = 3.0

year = ispan(1981,2016,1)

; create individual plots
plotb = new(neof,graphic)                ; create graphic array
plota=new(neof,graphic)
;do n=0,neof-1
;rts@gsnLeftString  = "EOF "+(n+1)
;rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
;plotb(n) = gsn_csm_xy (wks,year,eof_ts(n,:),rts)
;plota(n)=gsn_add_polyline(wks,plotb(n),year,y(n,:),polyres)
;end do
;draw(plotb)
;gsn_panel(wks,plotb,(/neof,1/),rtsP)     ; now draw as one plot


;printVarSummary(eof)

end



