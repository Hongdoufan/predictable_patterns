
begin
; ==============================================================
; User defined parameters that specify region of globe and years et
; ==============================================================
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360

label1= (/"(a)","(b)","(c)","(d)","(e)","e"/)
label2= (/"(e)","(f)","(g)","(h)","(i)","e"/)
label3= (/"(i)","(j)","(k)","(l)","(m)","e"/)

eofp=12
   
;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "fig_2"                      ; set plot name 
pltType = "pdf" 


file1=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
eof_ts=file1->eof_ts
eof=file1->eof

file2=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs.nc", "r")
eof_ts_obs=file2->eof_ts
eof_obs=file2->eof

file3 = addfile("/disk1/fhd/winter_forecast/data/fig3b.nc","r")
b=file3->data

printMinMax(eof_obs(1,:,:), False)
explained_variance=new(eofp,"float")
explained_variance(0)=0.532
explained_variance(1)=0.159
explained_variance(2)=0.093
explained_variance(3)=0.051
explained_variance(4)=0.174
;year=ispan(1,36,1)
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
gsn_define_colormap(wks,"BlRe")       ; choose colormap
plot = new(eofp,graphic)                ; create graphic array
plot1 = new(eofp,graphic)                ; create graphic array

; only needed if paneling
; EOF patterns

res                      = True
res@gsnDraw              = False        ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@gsnSpreadColors      = True         ; spread out color table
res@gsnAddCyclic         = True        ; plotted dataa are not cyclic

res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
res@mpMinLonF            = lonL
res@mpMaxLonF            = lonR

res@cnFillOn             = True         ; turn on color fill
res@cnLinesOn            = False        ; True is default
res@cnLineLabelsOn       = False        ; True is default
res@cnFillPalette        = "BlWhRe"     ; set color map
res@lbLabelBarOn         = False        ; turn off individual lb's
;res@vpHeightF            = 2       ; Changes the aspect ratio
;res@vpWidthF             = 0.85
res@mpCenterLonF         = 180.
res@tmYLLabelFontHeightF      =0.018  ;
res@tmXBLabelFontHeightF      = 0.018
res@tmXBTickSpacingF        =60

res@gsnLeftStringFontHeightF  = 0.021
res@gsnRightStringFontHeightF  = 0.021

; set symmetric plot min/max
symMinMaxPlt(eof(0:3,:,:), 16, False, res)       ; contributed.ncl

; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = True         ; add common colorbar
resP@pmLabelBarParallelPosF = -0.232
resP@txString            = " "

 resP@pmLabelBarOrthogonalPosF = -0.02       ; 0.05
 resP@pmLabelBarHeightF    = 0.032
 resP@pmLabelBarWidthF =0.4
 resP@lbLabelFontHeightF  =0.012


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

rts@vpHeightF = 0.15        ; Changes the aspect ratio
rts@vpWidthF  = 0.4
; rts@vpXF      = 0.30        ; change start locations
; rts@vpYF      = 0.3        ; the plot
rts@tmYLLabelFontHeightF      =0.02  ;
rts@tmXBLabelFontHeightF      = 0.02
rts@gsnLeftStringFontHeightF  = 0.021
rts@gsnRightStringFontHeightF  = 0.021


rts@tiYAxisString = " "                    ; y-axis label
rts@tiYAxisFontHeightF  = 0.02
rts@gsnYRefLine           = 0.              ; reference line
rts@gsnXYBarChart         = True            ; create bar chart
rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
rts@trYMaxF        =3
rts@trYMinF        =-2
rts@tmYLMode                = "Explicit"
rts@tmYLValues              = (/"-2.0","-1.0","0.0","1.0","2.0"/)
rts@tmYLLabels              = (/"-2.0","-1.0","0.0","1.0","2.0"/)
; panel plot only resources

;*******************************************
;resource for the third plot
;*******************************************

  fig                      = res         
  fig@mpMinLatF            = 20         ; zoom in on map
  fig@mpMaxLatF            = 89

  fig@cnFillPalette       ="MPL_Reds"          ; set color map
  fig@cnLevelSelectionMode        = "ManualLevels"
  ; fig1@cnLevels = (/-0.99, -0.95, 0.95, 0.99/)
  ; fig1@cnFillColors = (/"6", "9", "transparent", "14", "17"/)
  fig@cnMinLevelValF       = 5.              ; set min contour level
  fig@cnMaxLevelValF       = 55.              ; set max contour level
  fig@cnLevelSpacingF      = 10              ; set contour spacing
  fig@lbLabelBarOn                   = False
  fig@lbBottomMarginF = 0.05
  fig@lbLeftMarginF = 0.08
  fig@lbTopMarginF = 0.2
  fig@lbLabelOffsetF = 0.25
  fig@pmLabelBarOrthogonalPosF = 0.3       ; 0.05
  fig@pmLabelBarWidthF =0.5
  fig@lbLabelFontHeightF  =0.012
  fig@gsnRightString  =" " ; "Unit: %"
  fig@tmXBLabelFontHeightF = 0.013
  fig@tmYLLabelFontHeightF = 0.013
  fig@tmXBTickSpacingF        =60
;  fig@tmXBBorderOn        = False

rtsP                      = True            ; modify the panel plot
;rtsP@gsnMaximize          = True            ; large format
rtsP@txString             = " "
; polyline parameters used on both plots
;*********************************
polyres                  = True
polyres@gsLineThicknessF = 3.0

year = ispan(1981,2016,1)
;*******************************************
;first and second plot
;*******************************************
do n=0,eofp-1
    do j=0,3
res@gsnLeftString  = label1(j)+" MSN EOF"+ (j+1)
res@gsnRightString = sprintf("%5.1f", 100.*explained_variance(j)) +"%"
plot(3*j)=gsn_csm_contour_map_ce(wks,eof(j,:,:),res)
rts@gsnLeftString  = label2(j)
plot(3*j+1) = gsn_csm_xy (wks,year,eof_ts(j,:),rts)
fig@gsnLeftString  = label3(j)
plot(3*j+2) = gsn_csm_contour_map(wks, b(j,:,:), fig)

    end do
end do



gsn_panel(wks,plot,(/4,3/),resP)     ; now draw as one plot


end





