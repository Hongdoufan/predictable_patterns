
; initial time is november, prediction time is the next december,jan,feb,mar,apr,may
;model:
;(0)  10
;(3)    100
;(5)  300
;(10)   925
;erainterim2.5:
;(5)  10
;(10)   100
;(17)  300
;(33)   925
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
   np   = 3        ; number of pictures
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   pltName = "fig7"      
   pltType = "ps" 

   ;average reagion
   latS   =  0.
   latN   =  90.
   lonL   =  0.
   lonR   =  360.
   
; ==============================================================
; 
; ==============================================================
   
   file1 = addfile("/disk1/fhd/winter_forecast/data/msn.t2m.reg.z500.nc","r")
   file1tn=addfile("/disk1/fhd/winter_forecast/data/msn.t2m.pc2.200z.tn2d.nc","r")
   file2 = addfile("/disk1/fhd/winter_forecast/data/fig7b.nc","r")
   file2tn=addfile("/disk1/fhd/winter_forecast/data/msn.sst.pc1.200z.tn2d.nc","r")   
   file3 = addfile("/disk1/fhd/winter_forecast/data/fig7c.nc","r")

   a=file1->hgta(1,:,:)
   ap=file1->pro(1,:,:)
   ax=file1tn->tnx
   ay=file1tn->tny

   b=file2->7b
   bp=file2->7bp
   bx=file2tn->tnx
   by=file2tn->tny
   
   c=file3->7c
   cp=file3->7cp
   cx=file3->7cx
   cy=file3->7cy

   printMinMax(bx, False)
   printMinMax(by, False)


   ax({0:20},:)=1e+20
   ay({0:20},:)=1e+20

   bx({0:20},:)=1e+20
   by({0:20},:)=1e+20

   cx({0:20},:)=1e+20
   cy({0:20},:)=1e+20

; ==============================================================
; plot
; ==============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")       ;  BkBlAqGrYeOrReViWh200
  plot = new(np,graphic)
  plota=new(np,graphic) 
  plotb=new(np,graphic)



res2 =True
res2@gsnDraw = False
res2@gsnFrame = False

res2@gsnSpreadColors = True
;res2@gsnLeftString  = "300hPa Velocity Potential & Divergent Wind"
res2@gsnRightString = " "
;res2@gsnLeftStringOrthogonalPosF  =-0.2
res2@gsnStringFontHeightF = 0.02
res2@mpCenterLonF         = 180.
res2@vcRefMagnitudeF         = 4             ; define vector ref mag
res2@vcRefLengthF            = 0.05            ; define length of vec ref
;res2@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
res2@vcMinDistanceF          = 0.021
res2@vcRefAnnoFontHeightF    = 0.010
res2@vcRefAnnoSide    = "Top"
res2@vcRefAnnoPerimOn    = True
res2@vcRefAnnoString1  = "4.0"
res2@vcRefAnnoString2On  = False
res2@vcRefAnnoOrthogonalPosF   =  -0.25
res2@vcGlyphStyle    = "FillArrow"         ; turn on curly vectors
res2@vpHeightF = 0.4        ; Changes the aspect ratio
res2@vpWidthF  = 0.7
;res2@vcFillArrowHeadYF = 0.07
;res2@vcFillArrowHeadXF = 0.3
res2@vcMinAnnoPerimOn = True
res2@vcFillArrowEdgeThicknessF = 1.0
res2@vcFillArrowWidthF =0.07
res2@mpFillOn = False
res2@mpMinLatF            = 0.         ; zoom in on map
res2@mpMaxLatF            = 90.
res2@tmYLLabelFontHeightF      =0.015
res2@tmXBLabelFontHeightF      = 0.015
res2@mpGreatCircleLinesOn = False
res2@gsnLeftString  = " "
res2@gsnRightString = " "
res2@tmXBTickSpacingF        =60
res2@tmYLLabelFontHeightF      =0.016  ;×ø±ê×ÖÌå´óÐ¡
res2@tmXBLabelFontHeightF      = 0.016





resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = False      ; add common colorbar
resP@lbLabelAutoStride   = False         ; auto stride on labels
resP@txString            = " "
resP@txFontHeightF       = 0.035


;  delete(res2)
res = True
res@gsnDraw = False
res@gsnFrame = False
res@cnLinesOn       = True
res@cnFillOn        = False
res@cnLineLabelsOn  = False
res@mpFillOn             = False 
res@mpMinLatF            = 0         ; zoom in on map
res@mpMaxLatF            = 90
res@mpCenterLonF         = 180.
; res@mpMinLonF=180
; res@mpMaxLonF=360
res@vpHeightF = 0.4        ; Changes the aspect ratio
res@vpWidthF  = 0.7

res@cnLineThicknessF     = 0.7
res@cnLineLabelFontHeightF = 0.01
res@gsnContourNegLineDashPattern = 1    ; sets negative contours to dash pattern 1
res@gsnContourLineThicknessesScale = 1.5
res@cnInfoLabelOn = False
res@cnLevelSelectionMode = "ManualLevels"
;res@cnMinLevelValF       = -50     ; Min contour
;res@cnMaxLevelValF       =  100     ; Max contour
res@cnLevelSpacingF      = 5    ; Spacing
res@cnInfoLabelOn=False
res@gsnSpreadColors = True
res@cnLineColor= "1"
res@gsnContourZeroLineThicknessF = 0
res@tmYLLabelFontHeightF      =0.016   ;×ø±ê×ÖÌå´óÐ¡
res@tmXBLabelFontHeightF      = 0.016
res@tmXBTickSpacingF        =60



;res@mpCenterLonF         = 180.
res@cnExplicitLineLabelsOn = False


res1 = True
res1@gsnDraw = False
res1@gsnFrame = False
res1@gsnAddCyclic= True
res1@cnFillOn = True
res1@cnLinesOn =False
res1@cnLineLabelsOn  =False
res1@cnInfoLabelOn=False
res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/-0.99, -0.95, 0.95, 0.99/)
res1@cnFillColors = (/"77", "92", "transparent", "121", "139"/)
res1@cnFillDrawOrder = "Predraw"
;res1@lbBottomMarginF = 0.1
;res1@lbLeftMarginF = 0.1
;res1@lbTopMarginF = 0.4
res1@lbLabelBarOn                   = False
;res1@gsnLeftStringParallelPosF = 0.98
res1@gsnStringFontHeightF = 0.08
res1@gsnLeftString  = "(a) 500HGT & 200TN-flux"
res1@gsnRightString  = "CI:5gpm"
res1@gsnRightStringOrthogonalPosF  =0.05
; res1@gsnRightStringParallelPosF = 1
; res1@gsnStringFontHeightF = 0.07
res1@gsnLeftStringOrthogonalPosF  =0.05
;res@gsnLeftStringParallelPosF = 0.98
;res@gsnStringFontHeightF = 0.039
  plot(0)  =gsn_csm_vector_map(wks,ax({latS:latN},:),ay({latS:latN},:),res2)
  plota(0)  =gsn_csm_contour(wks,a({latS:latN},:),res)
  plotb(0) =gsn_csm_contour(wks,ap({latS:latN},:),res1)
  overlay(plot(0),plota(0))
  overlay(plot(0),plotb(0))

  res1@gsnLeftString  = "(b) 500HGT & 200TN-flux"
  plot(1)  =gsn_csm_vector_map(wks,bx({latS:latN},:),by({latS:latN},:),res2)
  plota(1)  =gsn_csm_contour(wks,b({latS:latN},:),res)
  plotb(1) =gsn_csm_contour(wks,bp({latS:latN},:),res1)
  overlay(plot(1),plota(1))
  overlay(plot(1),plotb(1))
  
  res2@vcRefMagnitudeF         = 2             ; define vector ref mag
  res2@vcRefAnnoString1  = "2.0"

  res1@gsnLeftString  = "(c) 500HGT & 200TN-flux"
  plot(2)  =gsn_csm_vector_map(wks,cx({latS:latN},:),cy({latS:latN},:),res2)
  plota(2)  =gsn_csm_contour(wks,c({latS:latN},:),res)
  plotb(2) =gsn_csm_contour(wks,cp({latS:latN},:),res1)
  overlay(plot(2),plota(2))
  overlay(plot(2),plotb(2))


gsn_panel(wks,plot,(/np,1/),resP)     ; now draw as one plot

end



     