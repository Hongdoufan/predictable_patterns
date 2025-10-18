  

begin
latS   =  0.
latN   =  90.
lonL   =  0.
lonR   =  360.

yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "sic.djf.cor.t2m"      
pltType = "pdf" 
varname1     = "winter_anom"

season = "JFM"    
;data = addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc","r")
;ao_prd=data->sic_index

; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  latSd   =  24
  latNd   =  40
  lonLd   =  70
  lonRd   =  105 
   varname1     = "winter_anom"
   varname2     = "sd"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/" 
   pltName = "obspc2.reg.t2m"                       ; set plot name 
   pltType = "pdf" 
                           ; directory for plot output
   startyear=1981
   endyear=2016
   nyear= 36
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"      
   level  = " "
   ensemble = 25
                                                   
  t=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")
  a=t->eof_ts



ff=addfile ("/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc","r")
var1=ff->$varname1$
ensemble_winter=dim_avg_n(var1,1)
ensemble_winter=dtrend_n(ensemble_winter,True,0)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)

  
  
     nyrs3  = dimsizes(a)
     b =ensemble_winter({latitude|:},{longitude|:},nyear|:)
     rc    = escorc_n(a,b,0,2)
     nrc=3
;printVarSummary(rc)

  rc!0 = "lat"
  rc!1 = "lon"
  rc&lat = var1&latitude
  rc&lon = var1&longitude
;  tval = onedtond(rc@tval , dimsizes(rc))
;  df   = onedtond(rc@nptxy, dimsizes(rc))
;;  df   = df/floattoint( max(T) )
;  df   = onedtond(rc@nptxy, dimsizes(rc)) - 2
;  bb    = tval  
;  bb=0.5
;  prob = ( 1. - betainc(df/(df+tval^2),df/2.0,bb) )
;  copy_VarCoords(rc, prob)
;  prob = where(rc.gt.0, prob, prob*-1.)
printMinMax(rc,False)
;  rc=where(abs(prob).lt.0.95,rc@_FillValue, rc)
;system("rm -f /disk1/fhd/winter_forecast/data/fig10b.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/fig10b.nc", "c")
;fout->10b=rc
;fout->10bp=prob
;============================================================
; PLOTS
;============================================================
  wks = gsn_open_wks(pltType,pltDir+pltName)
  gsn_define_colormap(wks,"temp_diff_18lev")       ; choose colormap
  plot = new(nrc,graphic)                ; create graphic array

  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnSpreadColors      = True         ; spread out color table


  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR
  res@mpCenterLonF         = 180.
  res@mpShapeMode = "FreeAspect"
;  res@vpHeightF = 0.4       ; Changes the aspect ratio
;  res@vpWidthF  = 0.85
  res@cnInfoLabelOn        = False
  res@gsnAddCyclic         = True
  res@tmXBTickSpacingF        =60

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False
  res@lbLabelBarOn         = False        ; turn off individual lb's
  
  res@gsnStringFontHeightF      = 0.025
  res@tmYLLabelFontHeightF      =0.023   ;×ø±ê×ÖÌå´óÐ¡
  res@tmXBLabelFontHeightF      = 0.023
  


  
  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF       = -0.9              ; set min contour level
  res@cnMaxLevelValF       =  0.9              ; set max contour level
  res@cnLevelSpacingF      =  0.1              ; set contour spacing
 ; symMinMaxPlt(rc, 16, True, res2)
  
                                          ; set symmetric plot min/max


; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@txString            = " "
  resP@gsnPanelLabelBar= True   
  resP@pmLabelBarParallelPosF = 0.001              ; label bar on panel
  resP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
  resP@pmLabelBarHeightF    = 0.04
  resP@pmLabelBarWidthF =0.7
  resP@lbLabelFontHeightF  =0.015

  res@gsnLeftString  = "(b)" 
  res@gsnRightString = "unit: "+"~S~o~N~C"
  plot(0)=gsn_csm_contour_map(wks,rc, res)
  resp=True
resp@gsLineThicknessF=3       ;polyline
resp@gsLineColor="black"
;=====================================
;
;=====================================
aa2=(/75,82.,82.,75.,75./)       ;pna
aa1=(/20,20.,60.,60.,20./)

l=new(4,graphic)
do i=0,3
l(i)=gsn_add_polyline(wks,plot(0),aa1(i:i+1),aa2(i:i+1),resp)
end do


;=====================================
;
;=====================================
aa2=(/59,69.,69.,59.,59./)       ;pna
aa1=(/180,180.,195.,195.,180./)

lf=new(4,graphic)
do i=0,3
lf(i)=gsn_add_polyline(wks,plot(0),aa1(i:i+1),aa2(i:i+1),resp)
end do

  gsn_panel(wks,plot,(/nrc,1/),resP)     ; now draw as one plot
  
  end
  