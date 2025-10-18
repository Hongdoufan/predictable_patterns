begin
season = "JFM"    
nyear=35     ; leave out 2008-2016 for test
nfactors= 7
testy= 0
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "mlr7_g36_1out" 
pltType = "ps" 
output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "mlr.coefficients7_g36_1out.nc" 
varname1     = "winter_anom"

;   read predictor indices
na=addfile("/disk1/fhd/winter_forecast/data/sd_na_djf_prd.nc", "r")
tp=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc", "r")
ea=addfile("/disk1/fhd/winter_forecast/data/sd_ea_son_prd.nc", "r")
sst=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd.nc", "r")
sic=addfile("/disk1/fhd/winter_forecast/data/sic_djf_prd.nc", "r")

sd_na=na->sic_index
sd_tp=tp->sic_index
sd_ea=ea->sic_index
nino=sst->nino34
emi=sst->emi
sic_a=sic->sic_index

x1=new(nyear,typeof(nino))
x2=new(nyear,typeof(nino))
x3=new(nyear,typeof(nino))
x4=new(nyear,typeof(nino))
x5=new(nyear,typeof(nino))
x6=new(nyear,typeof(nino))

 x1(0:nyear-1)=nino(1:nyear)
 x2(0:nyear-1)=emi(1:nyear)
 x3(0:nyear-1)=sd_tp(1:nyear)
 x4(0:nyear-1)=sd_na(1:nyear)
 x5(0:nyear-1)=sd_ea(1:nyear)
 x6(0:nyear-1)=sic_a(1:nyear)

;   read dynamical prediction as a facotr
   file1 = addfile("/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc","r")
   var1=file1->$varname1$
   ensemble_winter=dim_avg_n(var1,1)
   copy_VarCoords(var1(:,0,:,:), ensemble_winter)
   



ff=addfile("/disk1/fhd/data/t2m.mon.mean.1.0.nc","r")
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
 

   prd=new((/35,dimsizes(lat),dimsizes(lon)/),"float")
   prd(0:nyear-1,:,:)=ensemble_winter(1:nyear,:,:)

 x0=prd
 labels= (/"prd","ninonyear-1","emi","TP snow","NA snow","EA snow","sic"/)


   printVarSummary(winter_anom)
    b =winter_anom({latitude|:},{longitude|:},time|:)
    bb =new((/dimsizes(lat),dimsizes(lon),nyear/),"float")
    bb(:,:,0:nyear-1)=b(:,:,1:nyear)
    datab=new((/nfactors+1,dimsizes(lat),dimsizes(lon)/),"float")  
    databb=new(nfactors+1,"float")
    pval_raw=new((/nfactors+1,dimsizes(lat),dimsizes(lon)/),"float")
    fval_raw=new((/dimsizes(lat),dimsizes(lon)/),"float")

 
do i=0,180,1
   do j=0,359,1
     
 y=bb(i,j,:)
; printVarSummary(y)
 ;printVarSummary(olr)
 nrow=dimsizes(y)

   xp   = new( (/nrow,nfactors/), typeof(x1))  ; create an array to hold predictor variables   
   xp(:,0) = x0(:,i,j)
   xp(:,1) = x1
   xp(:,2) = x2
   xp(:,3) = x3
   xp(:,4) = x4
   xp(:,5) = x5
   xp(:,6) = x6
   
   opt = False
   opt@print_anova = False     ; optional
   opt@print_data  = False
   ba   =  reg_multlin_stats(y,xp,opt)
   ;printVarSummary(ba)
   datab(:,i,j)=ba
   databb(:)=datab(:,i,j)
   pval_raw(:,i,j)=databb@pval
   fval_raw(i,j)=databb@F_pval

   ;print(eee)
 end do
 end do
 
; printMinMax(pval_raw, False)
 

datab!0="even"
datab!1="lat"
datab!2="lon"
datab&even=ispan(0,nfactors,1)
datab&lat=b&latitude
datab&lon=b&longitude
printVarSummary(datab)
copy_VarCoords(datab, pval_raw)

prob=1-pval_raw
prob=where(datab.gt.0, prob, prob*-1)

probf=1-fval_raw
copy_VarCoords(datab(0,:,:), probf)

;probf=where(datab.lt.0, probf, probf*-1)
printMinMax(probf, False)
copy_VarCoords(datab, prob)

do i=0,nfactors
   printMinMax(datab(i,:,:), False)
end do


 system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->coe0=datab(0,:,:)
 fout->coe1=datab(1,:,:)
 fout->coe2=datab(2,:,:)
 fout->coe3=datab(3,:,:)
 fout->coe4=datab(4,:,:)
 fout->coe5=datab(5,:,:)
 fout->coe6=datab(6,:,:)
 fout->coe7=datab(7,:,:)

 fout->prob=probf
exit()

 ;============================================================

  wks = gsn_open_wks(pltType,pltDir+pltName)
  gsn_define_colormap(wks,"temp_diff_18lev")       ; choose colormap
  plot = new(nfactors,graphic)
  res                      = True         
 ; res@gsnDraw              = False        ; don't draw yet
 ; res@gsnFrame             = False        ; don't advance frame yet
  res@gsnSpreadColors      = True         ; spread out color table

latS   =  0.
latN   =  90.
lonL   = 0.
lonR   =  360.

  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
 ; res@mpMinLonF            = lonL
 ; res@mpMaxLonF            = lonR
  res@mpCenterLonF         = 180.
  res@mpShapeMode = "FreeAspect"
  
  res@cnInfoLabelOn        = False
  res@gsnAddCyclic         = True
  
  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False
  res@lbLabelBarOn         = False        ; turn off individual lb's
  
  res@gsnStringFontHeightF = 0.025
 res@tmYLLabelFontHeightF      =0.02   ;×ø±ê×ÖÌå´óÐ¡
   res@tmXBLabelFontHeightF      = 0.02
  


;  symMinMaxPlt(rc, 16, False, res)       ; contributed.ncl
  
  res1 = res
  res1@gsnDraw              = False        ; don't draw yet
  res1@gsnFrame             = False        ; don't advance frame yet
  res1@cnLevelSelectionMode        = "ExplicitLevels"
  res1@cnLevels = (/-0.99, -0.95, 0.95, 0.99/)
  res1@cnFillColors = (/"6", "9", "transparent", "14", "17"/)
  
  
  
  res2 = True
  res2@cnLineLabelsOn       = True
  res2@cnLineLabelFontHeightF = 0.02
  res2@gsnContourZeroLineThicknessF = 0.    ; doubles thickness of zero contour
  res2@gsnContourNegLineDashPattern = 1     ; sets negative contours to dash pattern 1
  res2@gsnContourLineThicknessesScale = 1.5
  res2@cnInfoLabelOn = False
  
  res2@cnLevelSelectionMode        = "ManualLevels"
;  res2@cnMinLevelValF       = -1.              ; set min contour level
;  res2@cnMaxLevelValF       =  1.              ; set max contour level
  res2@cnLevelSpacingF      =  0.4              ; set contour spacing
 ; symMinMaxPlt(rc, 16, True, res2)
  
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = False      ; add common colorbar
resP@lbLabelAutoStride   = False         ; auto stride on labels
resP@txString            = " " ;Partial regression onto t2m "                                   ; set symmetric plot min/max
resP@tiMainString = " "
res1@tiMainString = " "
res2@tiMainString = " "


  res1@gsnLeftString  = "  "
  res1@gsnRightString = "CI:0.4K"
do i=0,nfactors-1
  res1@gsnLeftString  = labels(i)
  plot(i)=gsn_csm_contour_map_overlay(wks, probf, datab(i+1,:,:), res1, res2)
  ; plot(1)=gsn_csm_contour_map(wks,  datab(2,:,:),  res2)
end do
  gsn_panel(wks,plot,(/nfactors,1/),resP)  

do i=0,nfactors-1
  res1@gsnLeftString  = labels(i)
  plot(i)=gsn_csm_contour_map_overlay(wks, prob(i+1,:,:), datab(i+1,:,:), res1, res2)
  ; plot(1)=gsn_csm_contour_map(wks,  datab(2,:,:),  res2) 
end do
  gsn_panel(wks,plot,(/nfactors,1/),resP)  


end 