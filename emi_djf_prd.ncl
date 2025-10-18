

begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
   np   = 3        ; number of pictures
   varname1     = "winter_anom"
   varname2     = "sst"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   pltName = "emi_djf_prd"      
   pltType = "ps" 
   nrun=3
   tstart=""
   tend=""
   startyear=1981
   endyear=2016
   nyear= 36
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"      
   level  = " "
   ensemble = 25
                                                   
   file1 = addfile("/disk1/fhd/winter_forecast/data/sst_in11_6mon_wina.nc","r")
                ; set plot name 
   var1=file1->$varname1$
   ensemble_winter=dim_avg_n(var1,1)
   copy_VarCoords(var1(:,0,:,:), ensemble_winter)
  ; ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)

; modoki area 
   latSa   = -10.0
   latNa   =  10.0
   lonLa   = 165.0       ;a 
   lonRa   = 220.0
          
   latSb   = -15.0
   latNb   =  5.0
   lonLb   = 250.0       ;b
   lonRb   = 310.0

   latSc   = -10.0
   latNc   =  20.0
   lonLc   = 125.0       ;c 
   lonRc   = 145.0


   latSd   = -5.0
   latNd   =  5.0
   lonLd   = 190.0       ;nino3.4
   lonRd  = 240.0


   ssta=ensemble_winter(:,{latSa:latNa},{lonLa:lonRa})
   sstb=ensemble_winter(:,{latSb:latNb},{lonLb:lonRb})
   sstc=ensemble_winter(:,{latSc:latNc},{lonLc:lonRc})

   sstd=ensemble_winter(:,{latSd:latNd},{lonLd:lonRd})
  ;===========================================================================
  
  rad   = 4.*atan(1.)/180.
  lat1   = ssta&latitude 
  clat1  =lat1
  clat1  = sqrt( cos(rad*lat1) ) 
  
  lat2   = sstb&latitude
  clat2  =lat2
  clat2  = sqrt( cos(rad*lat2) ) 

  lat3   = sstc&latitude
  clat3  =lat3
  clat3  = sqrt( cos(rad*lat3) ) 

  lat4   = sstd&latitude
  clat4  = lat4
  clat4  = sqrt( cos(rad*lat4) ) 

  area_a=wgt_areaave(ensemble_winter(:,{latSa:latNa},{lonLa:lonRa}), clat1, 1.0, 0)
  area_b=wgt_areaave(ensemble_winter(:,{latSb:latNb},{lonLb:lonRb}), clat2, 1.0, 0)
  area_c=wgt_areaave(ensemble_winter(:,{latSc:latNc},{lonLc:lonRc}), clat3, 1.0, 0)
  area_d=wgt_areaave(ensemble_winter(:,{latSd:latNd},{lonLd:lonRd}), clat4, 1.0, 0)


  modoki_mod=area_a-0.5*area_b-0.5*area_c
  modoki_mod=dim_standardize_Wrap(modoki_mod,0)
  nino34=dim_standardize_Wrap(area_d,0)
  printVarSummary(modoki_mod)  
 ; copy_VarCoords(nino34,mod_nino34)
  
   fout=addfile("/disk1/fhd/winter_forecast/data/emi_djf_obs.nc", "r")
   emi_obs=fout->emi

  ; d_stz=new((/2,36/),"float")
  ; d_stz(0,:)=modoki_mod
  ; d_stz(1,:)=nino34
  ; year=ispan(1981,2016,1)
; ;  print(d_stz)

  aaa=escorc(modoki_mod, emi_obs)
  print(aaa)

system("rm -f /disk1/fhd/winter_forecast/data/emi_nino34_djf_prd_raw.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd_raw.nc", "c")
fout->emi=modoki_mod 
fout->nino34=area_d
 exit()  
; emi_reg=regCoef(nino34,modoki_mod)
; emi_res=modoki_mod-emi_reg*nino34
; system("rm -f /disk1/fhd/winter_forecast/data/emi_nino34_djf_prd.nc")
; fout=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd.nc", "c")
; fout->emi=emi_res
; fout->nino34=nino34


data = asciiread("/disk1/fhd/winter_forecast/data/emi.monthly.txt",(/1787,8/),"float")
aa=data(1343:1774,7)     
aa!0    = "time"
;a=abs(a)
;VAR=a(::12)      ;nov     
VAR1=aa(0::12)      ;dec     
VAR2=aa(1::12)    ;jan
VAR3=aa(2::12)     ;feb      
emi=(VAR1+VAR2+VAR3)/3
emi=dtrend(emi, False)
japan=escorc(emi, modoki_mod)
print(japan)
; obs modoki index
; ; ==============================================================
; ; Open the file: Read only the user specified period
; ; ==============================================================
; tStrt =1343   ; indices of selected times   1981.12
; tLast = 1774  ;2016.11

; x     = file2->sst(tStrt:tLast,{latS:latN},{lonl:lonr})
; ;printVarSummary(x)
; YYYYMM=cd_calendar(x&time,-2)/100             ; ALL dates on file
; ntim  = dimsizes(YYYYMM)

; ;*********************************
; ; time indices for base climatology
; ;*********************************
; ;iClmStrt = ind(YYYYMM.eq.clStrt)
; ;iClmLast = ind(YYYYMM.eq.clLast)
; ;print(date(iClmStrt:iClmLast))

; ;*********************************
; ; Climatology and anomalies from base climatology
; ;*********************************
; xClm     = clmMonTLL(x(:,:,:))
; ;printVarSummary(xClm)

; xAnom    = calcMonAnomTLL (x,  xClm )
; xAnom@long_name = "SST Anomalies"
; ;printVarSummary(xAnom)
; ;*********************************
; ; weighted areal average anomalies (time series)
; ; Small latitudinal extent so no need to weight
; ;*********************************
; ;  ddd=cor_pos(:,:,{latS:latN},:)
;   lat   = x&latitude 
;   rad   = 4.*atan(1.)/180.
;   clat  =lat
;   clat  = sqrt( cos(rad*lat) )   
  
  
; xAnom_avg = wgt_areaave(xAnom, clat, 1.0, 0)
; xAnom_avg@long_name = "areal avg anomalies"
; ;print(xAnom_avg)

; ;*********************************
; ; Perform an unweighted 'nrun' month running average
; ;*********************************

; ;xAnom_avg = runave_n_Wrap (xAnom_avg, nrun, 1, 0)
; ;print(xAnom_avg)
; ;xAnom_avg=dim_standardize_Wrap(xAnom_avg,0)
; xAnom_avg!0="time"
; xAnom_avg&time=x&time
; season = "JFM"
; nino34 = month_to_season (xAnom_avg, season)
; d_nino34=dim_standardize_Wrap(nino34,0)
; nino34=d_nino34
   
   
;   printVarSummary(f)
  

  
; ;************************************************
; ; create plot
; ;************************************************
; wks = gsn_open_wks(pltType,pltDir+pltName)
; res               = True                        ; plot mods desired
; res@gsnDraw= False
; res@gsnFrame= False

; res@tmXBMode          = "Explicit"              ; explicit labels
; ;res@tmXBValues        = x                       ; location of labels
; ;res@tmXBLabels        = warm_yrs                ; labels themselves
; res@tmLabelAutoStride = True                    ; nice stride on labels
; res@xyLineColors      = (/"black","red"/)  ; line colors
; res@xyLineThicknesses	 = (/5.,5./)      ; line thicknesses
; res@xyDashPatterns    = (/0.0,0.0/)        ; line patterns
; res@tiYAxisString    = "  "    ; y-axis label
; res@tiMainString      = " "; title
; res@vpHeightF = 0.40        ; Changes the aspect ratio
; res@vpWidthF  = 0.75

; ;res@gsnYRefLine           = 0.0
; ;res@gsnYRefLineThicknessF = 2.0
; ;res@txString             = "VWND: "+season+": "+yStrt+"-"+yLast
; ;
; res_text                    = True                  ; text mods desired
; res_text@txFontHeightF      = 0.011                 ; change text size
; res_text@txJust             = "CenterLeft"          ; text justification
; res_lines                   = True                  ; polyline mods desired
; res_lines@gsLineDashPattern = 0.                    ; solid line
; res_lines@gsLineThicknessF  = 5.                    ; line thicker
; ; panel plot only resources
; resP                     = True         ; modify the panel plot
; resP@gsnMaximize         = True         ; large format






; res@tiMainString      = "Modoki "; title
; res@xyLineColors      = (/"black","red"/)
; plota=new(1,graphic)
; plota(0)  = gsn_csm_xy(wks,year,d_stz,res)
; xx = (/1981,1985/)
; yy = (/-1,-1/)
; res_lines@gsLineColor       = "black"
; abbcd=new(2,graphic)
; abbcd(0) = gsn_add_polyline(wks,plota,xx,yy,res_lines)                ; add polyline
; res_lines@gsLineColor       = "red"
; yy = (/-1.2,-1.2/)
; abbcd(1) = gsn_add_polyline(wks,plota,xx,yy,res_lines)                ; add polyline
; dum6q = gsn_add_text(wks,plota,"modoki",1986,-1,res_text) ; add text
; dum6q = gsn_add_text(wks,plota,"nino34",1986,-1.2,res_text) ; add text
; gsn_panel(wks,plota,(/1,1/),resP)     ; now draw as one plot





end



     