;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
year = 30
yrStrt = 1991
yrLast = 2020

varname1     = "winter_anom"

   
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "msn_cv_pattern_sys51"                       ; set plot name
neof =30
pltType = "pdf"

output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "msn_t2m_cv_sys51.nc"  

;==========================================================
;read predicable patterns
;==========================================================
ynumber=ispan(yrStrt,yrLast,1)
all_files = "/disk1/fhd/degreepaper/data/msn_t2m_leave" + ynumber + "_sys51.nc"
patterns = addfiles (all_files, "r")
;---Read "pottmp" in "join" mode and print a summary of the variable
   ListSetType (patterns, "join") 
   
   mode=patterns[:]->msn_t2m  ; note syntax [:]
   printVarSummary(mode) 

mode(27,2,:,:)=mode(27,2,:,:)*-1
mode(29,2,:,:)=mode(29,2,:,:)*-1
mode(:,3,:,:)=mode(:,3,:,:)*-1
mode(23:29,3,:,:)=mode(23:29,3,:,:)*-1
  eof=mode(:,3,:,:)
   
   
  system("rm -f $output$+$outName$.nc")
  fout=addfile(output+outName, "c")
  fout->msn_t2m=mode
 exit()
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
gsn_define_colormap(wks,"BlRe")       ; choose colormap
plot = new(year,graphic)                ; create graphic array
; only needed if paneling
; EOF patterns

res                      = True
res@gsnDraw              = False        ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@gsnSpreadColors      = True         ; spread out color table
res@gsnAddCyclic         = False        ; plotted dataa are not cyclic

res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
res@mpMinLonF            = lonL
res@mpMaxLonF            = lonR

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

symMinMaxPlt(mode(0,0:3,:,:), 16, False, res)       ; contributed.ncl

; res@cnMinLevelValF       = -0.08             ; set min contour level
; res@cnMaxLevelValF       =  0.08           ; set max contour level
; res@cnLevelSpacingF      =  0.01              ; set contour spacing

; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = True         ; add common colorbar


resP@txString            =""

;*******************************************
; first plot
;*******************************************
do n=0,year-1
res@gsnLeftString  = "EOF "+(n+1)
;res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
plot(n)=gsn_csm_contour_map(wks,eof(n,:,:),res)
end do
gsn_panel(wks,plot,(/6,5/),resP)     ; now draw as one plot

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
; polyline parameters used on both plots
;*********************************
polyres                  = True
polyres@gsLineThicknessF = 3.0

year1 = ispan(1,35,1)
;printVarSummary(eof_ts)
; create individual plots
plotb = new(neof,graphic)                ; create graphic array
plota=new(neof,graphic)
;do n=0,year-1
;rts@gsnLeftString  = "EOF "+(n+1)
;;rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
;plotb(n) = gsn_csm_xy (wks,year1,eof_ts(n,:),rts)
;;plota(n)=gsn_add_polyline(wks,plotb(n),year,y(n,:),polyres)
;end do
;;draw(plotb)
;gsn_panel(wks,plotb,(/6,6/),rtsP)     ; now draw as one plot


;printVarSummary(eof)

end
