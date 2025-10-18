
begin
latS   =  0.
latN   =  90.
lonL   =  0.
lonR   =  160.
np=2
yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "sdtp"      
pltType = "pdf" 
nrc=1
season = "JFM"    
f      = addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc", "r")
eof_ts=f->sic_index
;============================================================
; regression onto uwind
;============================================================

varname1     = "winter"
files_dir    = "/disk1/fhd/winter_forecast/data/uwnd500_in11_6mon_wina.nc.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
ensemble_winter=dim_avg_n(var1,1)
;ensemble_winter=dtrend_n(ensemble_winter,True,0)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)
printVarSummary(ensemble_winter)
printVarSummary(var1(:,0,:,:))



  ;nyrs2   = dimsizes(ensemble_winter&nyear)
     a = eof_ts
     nyrs3  = dimsizes(a)
     b =ensemble_winter({latitude|:},{longitude|:},nyear|:)
     rc    = regCoef(a,b)
;     rc=rc/9.8
     
;printVarSummary(rc)
  rc!0 = "lat"
  rc!1 = "lon"
  rc&lat = var1&latitude
  rc&lon = var1&longitude
  tval = onedtond(rc@tval , dimsizes(rc))
  df   = onedtond(rc@nptxy, dimsizes(rc))
;  df   = df/floattoint( max(T) )
  df   = onedtond(rc@nptxy, dimsizes(rc)) - 2
  bb    = tval  
  bb=0.5
  prob = ( 1. - betainc(df/(df+tval^2),df/2.0,bb) )
  copy_VarCoords(rc, prob)
;  prob = where(rc.gt.0, prob, prob*-1.)
printMinMax(rc,False)
;============================================================
; regression onto vwind
;============================================================

files_dir1    = "/disk1/fhd/winter_forecast/data/vwnd500_in11_6mon_wina.nc.nc"                            ; input directory
varible_file1      = addfile (files_dir1, "r")
var11=varible_file1->$varname1$
ensemble_winter1=dim_avg_n(var11,1)
;ensemble_winter1=dtrend_n(ensemble_winter1,True,0)
copy_VarCoords(var11(:,0,:,:), ensemble_winter1)
printVarSummary(ensemble_winter1)

printVarSummary(var11(:,0,:,:))



     b1 =ensemble_winter1({latitude|:},{longitude|:},nyear|:)
     rc1    = regCoef(a,b1)
;     rc=rc/9.8
     
;printVarSummary(rc)
  rc1!0 = "lat"
  rc1!1 = "lon"
  rc1&lat = var1&latitude
  rc1&lon = var1&longitude
  tval1 = onedtond(rc1@tval , dimsizes(rc1))
  df1   = onedtond(rc1@nptxy, dimsizes(rc1))
;  df   = df/floattoint( max(T) )
  df1   = onedtond(rc1@nptxy, dimsizes(rc1)) - 2
  bb1    = tval1  
  bb1=0.5
  prob1 = ( 1. - betainc(df1/(df1+tval1^2),df1/2.0,bb1) )
  copy_VarCoords(rc1, prob1)
;  prob1 = where(rc1.gt.0, prob1, prob1*-1.)
  printMinMax(rc1,False)
  prob=where(abs(prob).ge.abs(prob1),prob,prob1)
  printMinMax(prob, False)
  rc=where(prob.ge.0.95,rc,0)
  rc1=where(prob.ge.0.95,rc1,0)
  
;============================================================
; read 500z
;============================================================

fout=addfile("/disk1/fhd/winter_forecast/data/sdtp_son_500z.nc", "r")
hgta=fout->hgta
pro=fout->prob


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
res2@mpMinLatF            = latS         ; zoom in on map
res2@mpMaxLatF            = latN
res2@mpMinLonF            = lonL
res2@mpMaxLonF            = lonR

res2@gsnSpreadColors = True
res2@gsnRightString = " "
;res2@gsnStringFontHeightF = 0.03
res2@mpCenterLonF         = 180.
res2@vcRefMagnitudeF         = 1            ; define vector ref mag
res2@vcRefLengthF            = 0.05            ; define length of vec ref
;res2@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
res2@vcMinDistanceF          = 0.021
res2@vcRefAnnoFontHeightF    = 0.01
res2@vcRefAnnoSide    = "Top"
res2@vcRefAnnoPerimOn    = False
res2@vcRefAnnoString1  = "1.0"
res2@vcRefAnnoString2On  = False
res2@vcRefAnnoOrthogonalPosF   =  0.1
;res2@vcLabelFontHeightF = 0.3
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



resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = False      ; add common colorbar
resP@lbLabelAutoStride   = False         ; auto stride on labels
resP@txString            = " "
resP@txFontHeightF       = 0.035


  plot(0)  =gsn_csm_vector_map(wks,rc({latS:latN},{lonL:lonR}),rc1({latS:latN},{lonL:lonR}),res2)
;  delete(res2)
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
res@cnLevelSpacingF      = 1    ; Spacing
res@cnInfoLabelOn=False
res@gsnSpreadColors = True
res@cnLineColor= "1"
res@gsnContourZeroLineThicknessF = 0


res@gsnRightString = "CI:1gpm"
res@gsnRightStringOrthogonalPosF  = -0.18
res@gsnRightStringParallelPosF = 1
res@gsnStringFontHeightF = 0.032
res@gsnLeftString  = "(d)"
res@gsnLeftStringOrthogonalPosF  = -0.18
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

  plota(0)  =gsn_csm_contour(wks,hgta({latS:latN},{lonL:lonR}),res)
  plotb(0) =gsn_csm_contour(wks,pro({latS:latN},{lonL:lonR}),res1)
  overlay(plot(0),plota(0))
  overlay(plot(0),plotb(0))
 

gsn_panel(wks,plot,(/2,1/),resP)     ; now draw as one plot

end



     