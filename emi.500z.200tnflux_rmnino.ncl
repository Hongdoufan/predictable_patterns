
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
   np   = 2        ; number of pictures
   varname1     = "var_name"
   varname2     = "z"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   pltName = "emi.500z.200tnflux_rmnino"      
   pltType = "pdf" 

   season = "JFM"

   ;average reagion
   latS   =  0.
   latN   =  90.
   lonL   =  0.
   lonR   =  360.
   
; ==============================================================
; composite hgta
; ==============================================================
   
fout=addfile("/disk1/fhd/winter_forecast/data/emi.500z_rmnino.nc", "r")
hgta=fout->hgta
;hgtb=fout->hgtb
proba=fout->proba
;probb=fout->probb
;printMinMax(ZA_prd_pos,False)
;printMinMax(ZA_obs_pos,False)
;printMinMax(ZA_prd_neg,False)
;printMinMax(ZA_obs_neg,False)
; ==============================================================
; tn_fluxes
; ==============================================================

f      = addfile ("/disk1/fhd/winter_forecast/data/emi.200z_tn2d_rmnino.nc", "r")

    
tnx_a=f->tnx_a
;tnx_b=f->tnx_b


tny_a=f->tny_a
;tny_b=f->tny_b




printVarSummary(tnx_a)
printMinMax(tnx_a, False)
printMinMax(tnx_a({latS:latN},:),False)
;printMinMax(tnx_b({latS:latN},:),False)
printMinMax(tny_a({latS:latN},:),False)
;printMinMax(tny_b({latS:latN},:),False)


printMinMax(tnx_a({10:90},:),False)
;printMinMax(tnx_b({10:90},:),False)
printMinMax(tny_a({10:90},:),False)
;printMinMax(tny_b({10:90},:),False)

tnx_a({0:15},:)=1e+20
tny_a({0:15},:)=1e+20

printMinMax(tnx_a({0:10},:),False)
printMinMax(tny_a({0:10},:),False)



printMinMax(tnx_a({latS:latN},:),False)
printMinMax(tny_a({latS:latN},:),False)

system("rm -f /disk1/fhd/winter_forecast/data/fig7c.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/fig7c.nc", "c")
fout->7c=hgta
fout->7cp=proba
fout->7cx=tnx_a
fout->7cy=tny_a


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
res2@vcRefMagnitudeF         = 2             ; define vector ref mag
res2@vcRefLengthF            = 0.05            ; define length of vec ref
;res2@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
res2@vcMinDistanceF          = 0.021
res2@vcRefAnnoFontHeightF    = 0.010
res2@vcRefAnnoSide    = "Top"
res2@vcRefAnnoPerimOn    = False
res2@vcRefAnnoString1  = "2.0"
res2@vcRefAnnoString2On  = False
res2@vcRefAnnoOrthogonalPosF   =  0.2
res2@vcGlyphStyle    = "FillArrow"         ; turn on curly vectors
;res2@vcFillArrowMinFracWidthF   = 0.05
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
;res2@gsnPolar = "NH"





resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = False      ; add common colorbar
resP@lbLabelAutoStride   = False         ; auto stride on labels
resP@txString            = " "
resP@txFontHeightF       = 0.035


  plot(0)  =gsn_csm_vector_map(wks,tnx_a({latS:latN},:),tny_a({latS:latN},:),res2)
  delete(res2)
res = True
res@gsnDraw = False
res@gsnFrame = False
res@cnLinesOn       = True
res@cnFillOn        = False
res@cnLineLabelsOn  = False
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


res@gsnRightString = "CI:5gpm"
res@gsnRightStringOrthogonalPosF  =-0.4
res@gsnRightStringParallelPosF = 1
res@gsnStringFontHeightF = 0.07
res@gsnLeftString  = "(c)"
res@gsnLeftStringOrthogonalPosF  =-0.4 
;res@gsnLeftStringParallelPosF = 0.98
;res@gsnStringFontHeightF = 0.039

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

  plota(0)  =gsn_csm_contour(wks,hgta({latS:latN},:),res)
  plotb(0) =gsn_csm_contour(wks,proba({latS:latN},:),res1)
  overlay(plot(0),plota(0))
  overlay(plot(0),plotb(0))
 
;  res2@gsnLeftString  = "  "
;  plot(1)  =gsn_csm_vector_map(wks,tnx_b({latS:latN},:),tny_b({latS:latN},:),res2)
;  plota(1)  =gsn_csm_contour(wks,hgtb({latS:latN},:),res)
;  plotb(1) =gsn_csm_contour(wks,probb({latS:latN},:),res1)
;  overlay(plot(1),plota(1))
;  overlay(plot(1),plotb(1))
  
 

gsn_panel(wks,plot,(/2,1/),resP)     ; now draw as one plot

end



     