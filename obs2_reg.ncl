
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  0
latN   =  90
lonL   =  0
lonR   =  360
yrStrt = 1981
yrLast = 2016
nyear  = 36        
tstart = 35
tend   = 466
varname1     = "winter_anom"
decomposition_season="JFM"
season="JFM"
nrc=3
var     = "t2m"
unit= ""
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "trendpattern_obs.nc" 

;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "trendpj_reg"                       ; set plot name 
pltType = "pdf" 
year=ispan(1981,2016,1)

;   var1=varible_file->$varname1$
;   Opt                = True
;   Opt@ForceOverwrite = True
;   Opt@DstGridType    = "2.5x2.5"
;   Opt@DstLLCorner    = (/ -90,   0/)
;   Opt@DstURCorner    = (/  90, 357.5/)
;   
;   var1_regrid = ESMF_regrid(var1,Opt)
;   var1_regrid =var1_regrid(:,:,::-1,:)
;   printVarSummary(var1_regrid)   
;   ensemble_winter=dim_avg_n(var1_regrid,1)
;   copy_VarCoords(var1_regrid(:,0,:,:), ensemble_winter)
;
;   aa_=ensemble_winter
;   tt=ispan(1,36,1)
;   slope_ec = regCoef_n(tt,ensemble_winter,0,0)
;   copy_VarCoords(var1_regrid(0,0,:,:), slope_ec)
;   yint_ec    = onedtond(slope_ec@yintercept, (/73,144/) )
;   copy_VarCoords(var1_regrid(0,0,:,:), yint_ec)
   
  t2m_avg=addfile("/disk1/fhd/winter_forecast/data/trend_prd_projection_index.nc","r")
  x=t2m_avg->prd_index

  t=addfile("/disk1/fhd/winter_forecast/data/trend_obs_projection_index.nc","r")
  y=t->prd_index
;      
;
tren=addfile("/disk1/fhd/degreepaper/data/eof_t2m_leave_obs.nc","r")
trend=tren->eof_ts(:,1,:)
      
   b=new(36,"float")
   coe=new(36,"float")
   
   coe1 = regCoef(x(1:35),y(1:35))
   b(0)=coe1@yintercept
   coe36 = regCoef(x(0:34),y(0:34))
   b(35)=coe36@yintercept

   coe(0)=coe1
   coe(35)=coe36
   xx=new((/36,35/),typeof(b))
   yy=new((/36,35/),typeof(b))

   do i=1,34   
     xx(i,0:(i-1))=x(0:(i-1))
     xx(i,i:34)=x((i+1):35)
     
     yy(i,0:(i-1))=y(0:(i-1))
     yy(i,i:34)=y((i+1):35)
     printVarSummary(xx)
     printVarSummary(yy)
     coe(i) = regCoef(xx(i,:),yy(i,:))      
     b(i) = coe@yintercept
     
   end do
print(b)
print(coe)


   fit=new((/36/),"float")
   do i=0,35
      fit(i)=b(i)+coe(i)*x(i)
   end do
   
   cor1=escorc(x,y)
   cor2=escorc(fit,y)
   print(cor1)
   print(cor2)
;exit()
data=new((/4,36/),typeof(b))
data(0,:)=x
data(1,:)=y
data(2,:)=fit

jk=escorc(data(1,:),data(2,:))
print(jk)
;exit()
data1=dtrend_n(data,True,1) 
print(data1@slope)  
; exit()
jj1=escorc(data1(0,:),data1(1,:))
jj2=escorc(data1(1,:),data1(2,:))
print(jj1)
print(jj2)


;************************************************
; create plot
;************************************************
wks = gsn_open_wks(pltType,pltDir+pltName)
res               = True                        ; plot mods desired
res@gsnDraw= False
res@gsnFrame= False

res@tmXBMode          = "Explicit"              ; explicit labels
;res@tmXBValues        = x                       ; location of labels
;res@tmXBLabels        = warm_yrs                ; labels themselves
res@tmLabelAutoStride = True                    ; nice stride on labels
;res@xyLineColors      = (/"white","red"/)  ; line colors


res@tiYAxisString    = "  "    ; y-axis label
res@tiMainString      = " "; title
res@vpHeightF = 0.40        ; Changes the aspect ratio
res@vpWidthF  = 0.75


res_text                    = True                  ; text mods desired
res_text@txFontHeightF      = 0.011                 ; change text size
res_text@txJust             = "CenterLeft"          ; text justification
res_lines                   = True                  ; polyline mods desired
res_lines@gsLineDashPattern = 0.                    ; solid line
res_lines@gsLineThicknessF  = 5.                    ; line thicker
; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format


res@tiMainString      = "area-weighted pattern correlation "; title
res@xyLineColors      = (/"red","green","blue","black"/)
res@xyDashPatterns    = (/0.0,0.0,0,0/)        ; line patterns
res@xyLineThicknesses =(/5.0,5.0,5,5/) 
;res@xyDashPatterns	 = (/5.,5./)      ; line thicknesses
plota=new(2,graphic)
plota(0)  = gsn_csm_xy(wks,year,data,res)
;plota(1)  = gsn_csm_xy(wks,year,data,res)
;xx = (/1981,1984/)
;yy = (/0.54,0.54/)
;res_lines@gsLineColor       = "red"
;abbcd=new(4,graphic)
;abbcd(0) = gsn_add_polyline(wks,plota,xx,yy,res_lines)                ; add polyline
;res_lines@gsLineColor       = "green"
;yy = (/0.5,0.5/)
;abbcd(1) = gsn_add_polyline(wks,plota,xx,yy,res_lines)                ; add polyline
;res_lines@gsLineColor       = "blue"
;yy = (/0.46,0.46/)
;abbcd(2) = gsn_add_polyline(wks,plota,xx,yy,res_lines)
;res_lines@gsLineColor       = "black"
;yy = (/0.42,0.42/)
;abbcd(3) = gsn_add_polyline(wks,plota,xx,yy,res_lines)
;
;dum6q = gsn_add_text(wks,plota,"dec 0.82",1985,0.54,res_text) ; add text
;dum6q = gsn_add_text(wks,plota,"jan 0.51",1985,0.5,res_text) ; add text
;dum6q = gsn_add_text(wks,plota,"feb 0.76",1985,0.46,res_text) ; add text
;dum6q = gsn_add_text(wks,plota,"winter",1985,0.42,res_text) ; add text
;


gsn_panel(wks,plota,(/1,1/),resP)     ; now draw as one plot



end
